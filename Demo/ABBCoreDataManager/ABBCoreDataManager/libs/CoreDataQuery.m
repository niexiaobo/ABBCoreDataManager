//
//  CoreDataQuery.m
//  ABBCoreDataManager
//
//  Created by beyondsoft-聂小波 on 16/8/26.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import "CoreDataQuery.h"
#import "CoreDataBase.h"

@implementation CoreDataQuery
-(id)initWithModel:(NSString*)model{
    if(self= [super init]){
        _model          = model;
        _predicates     = [[NSMutableArray alloc] init];
        _sortPredicates = [[NSMutableArray alloc] init];
    }
    return self;
}

+(CoreDataQuery*)query:(NSString*)model{
    CoreDataQuery* query = [[self alloc] initWithModel:model];
    return query;
}

//============================================================
#pragma mark - Where
//============================================================
-(CoreDataQuery*)where:(NSString*)field is:(id)value{
    return [self where:field operator:@"=" value:value];
}
-(CoreDataQuery*)where:(NSString*)field operator:(NSString*)operator value:(id)value{
    
    if([operator isEqualToString:@"="]){
        [_predicates addObject:[NSPredicate predicateWithFormat:@"%K = %@",field, value]];
    }
    else if([operator isEqualToString:@">"]){
        [_predicates addObject:[NSPredicate predicateWithFormat:@"%K > %@",field, value]];
    }
    else if([operator isEqualToString:@"<"]){
        [_predicates addObject:[NSPredicate predicateWithFormat:@"%K < %@",field, value]];
    }
    else if([operator isEqualToString:@"like"]){
        [_predicates addObject:[NSPredicate predicateWithFormat:@"%K contains[c] %@",field, value]];
    }
    else if([operator isEqualToString:@"in"] || [operator isEqualToString:@"IN"]){
        [_predicates addObject:[NSPredicate predicateWithFormat:@"%K IN %@",field, value]];
    }
    return self;
}

-(CoreDataQuery*)where:(NSString*)field in:(NSArray*)values{
    [_predicates addObject:[NSPredicate predicateWithFormat:@"id IN %@", values]];
    return self;
}

//============================================================
#pragma mark - Sort
//============================================================
-(CoreDataQuery*)orderBy:(NSString*)key{
    if(key != nil){
        return [self orderBy:key ascendig:YES];
    }
    return self;
}

-(CoreDataQuery*)orderBy:(NSString*)key ascendig:(BOOL)ascending{
    if(key != nil){
        [_sortPredicates addObject:[[NSSortDescriptor alloc] initWithKey:key ascending:ascending]];
    }
    
    return self;
}


//============================================================
#pragma mark - Raw
//============================================================
-(CoreDataQuery*)raw:(NSString*)raw{
    [_predicates addObject:[NSPredicate predicateWithFormat:raw]];
    return self;
}

//============================================================
#pragma mark - Execute query
//============================================================
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

-(NSArray*)doQuery{
    
    NSFetchRequest *request;
    
    Class modelClass        = NSClassFromString(_model);
    NSString* entityName    = [modelClass performSelector:@selector(entityName)];
    request                 = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    
    NSPredicate *compoundPredicate  = [NSCompoundPredicate andPredicateWithSubpredicates:_predicates];
    [request setPredicate:compoundPredicate];
    
    [request setSortDescriptors:_sortPredicates];
    
    NSError *error   = nil;
    
    NSArray *results = [[modelClass managedObjectContext] executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    return results;
}

-(NSArray*)get{
    Class modelClass = NSClassFromString(_model);
    return [modelClass performSelector:@selector(managedArrayToCoreDataBaseArray:) withObject:[self doQuery]];
}

-(id)first{
    Class modelClass = NSClassFromString(_model);
    NSArray* results = [self doQuery];
    
    if([results count] > 0){
        CoreDataBase *mo = [modelClass performSelector:@selector(fromManaged:) withObject:results[0]];
        return mo;
    }
    return nil;
}

@end
