//
//  CoreDataBase.m
//  ABBCoreDataManager
//
//  Created by beyondsoft-聂小波 on 16/8/26.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import "CoreDataBase.h"



@implementation CoreDataBase
//==================================================================
#pragma mark - Create / Save / Update / Destroy
//==================================================================
+(id)create:(CoreDataBase*)toCreate{
    
    if(toCreate.id == nil){
        NSLog(@"model without id");
        return nil;
    }
    
    CoreDataBase* previous = [self.class find:toCreate.id];
    if(previous) {
        NSLog(@"Model already exists with id: %@, returning the one from the DB",toCreate.id);
        return previous;
    }
    
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:self.class.entityName inManagedObjectContext:[self.class managedObjectContext]];
    
    [toCreate valuesToManaged:object];
    [self.class saveCoreData];
    
    return toCreate;
}
-(bool)save{
    CoreDataBase* previous = [self.class find:self.id];
    if(previous) {
        return [self update];
    }
    else{
        return [self.class create:self];
    }
}

-(bool)update{
    if(_managed){
        [self valuesToManaged:_managed];
        return [self.class saveCoreData];
    }
    else{
        CoreDataBase* previous = [self.class find:self.id];
        if(!previous){
            NSLog(@"Model not in database");
            return false;
        }
        else{
            [previous destroy];
            [self save];
        }
        
    }
    return true;
}


-(bool)destroy{
    if(_managed){
        [[self.class managedObjectContext] deleteObject:_managed];
        return [self.class saveCoreData];
    }
    else{
        CoreDataBase *toDelete = [self.class find:self.id];
        return [toDelete destroy];
    }
}

//==================================================================
#pragma mark - Convenience methods
#pragma mark -
//==================================================================
+(bool)updateWith:(NSDictionary*)dict{
    CoreDataBase* object = [self.class fromDictionary:dict];
    return [object update];
}

+(id)createWith:(NSDictionary*)dict{
    CoreDataBase* object = [self.class fromDictionary:dict];
    return [self.class create:object];
}

+(bool)destroyWith:(NSNumber*)id{
    CoreDataBase * object = [self.class find:id];
    return [object destroy];
}

+(void)destroyWithArray:(NSArray*)idsArray{
    for(NSNumber* objectId in idsArray){
        [self.class destroyWith:objectId];
    }
}

//==================================================================
#pragma mark - Active record
#pragma mark -
//==================================================================
+(id)find:(NSNumber*)id{
    if(id == nil) return nil;
    return [self.query where:@"id" is:id].first;
}

+(NSArray*)findIn:(NSArray*)identifiers{
    return [self.query where:@"id" in:identifiers].get;
}

+(id)first{
    return [self first:@"id"];
}
+(id)first:(NSString*)sort{
    return [self.query orderBy:sort].first;
}

+(NSArray*)all{
    return [self all:nil];
}

+(NSArray*)all:(NSString*)sort{
    return [self.query orderBy:sort].get;
}

-(CoreDataBase*)belongsTo:(NSString*)model localKey:(NSString*)localKey{
    return [NSClassFromString(model) find:[self valueForKey:localKey]];
}

-(NSArray*)hasMany:(NSString*)model foreignKey:(NSString*)foreignKey{
    return [self hasMany:model foreignKey:foreignKey sort:nil];
}

-(NSArray*)hasMany:(NSString*)model foreignKey:(NSString*)foreignKey sort:(NSString *)sort{
    return [[NSClassFromString(model).query where:foreignKey is:self.id] orderBy:sort].get;
}

-(NSArray*)belongsToMany:(NSString*)model pivot:(NSString*)pivotModel localKey:(NSString*)localKey foreignKey:(NSString*)foreingKey{
    
    return [self belongsToMany:model pivot:pivotModel localKey:localKey foreignKey:foreingKey pivotSort:nil];
}

-(NSArray*)belongsToMany:(NSString*)model pivot:(NSString*)pivotModel localKey:(NSString*)localKey foreignKey:(NSString*)foreingKey pivotSort:(NSString *)pivotSort{
    
    //Pivots
    NSArray *pivots = [[NSClassFromString(pivotModel).query where:localKey is:self.id] orderBy:pivotSort].get;
    
    //Objects (attaching pivots)
    NSMutableArray* finalResults = [[NSMutableArray alloc] init];
    for(id pivot in pivots){
        id object = [NSClassFromString(model) find:[pivot valueForKey:foreingKey]];
        [object setPivot:pivot];
        [finalResults addObject:object];
    }
    
    return finalResults;
}

+(CoreDataQuery*)query{
    return [CoreDataQuery query:NSStringFromClass(self.class)];
}


//==================================================================
#pragma mark - HELPERS
//==================================================================
-(void)valuesToManaged:(NSManagedObject*)managedObject{
    
    [managedObject setValue:[self valueForKey:@"id"] forKey:@"id"];
    
    [self propertiesClass:self.class ToManaged:managedObject];
    
}

- (void)propertiesClass:(id)className ToManaged:(NSManagedObject*)managedObject {
    
    [className properties:^(NSString *name, objc_property_t property) {
        
        id value    = [self valueForKey:name];
        
        if([value isKindOfClass:[NSString class]]){
            [managedObject setValue:value forKey:name];
        }
        else if([value isKindOfClass:[NSNumber class]]){
            [managedObject setValue:value forKey:name];
            
        } else if([value isKindOfClass:[NSArray class]]){
            
            
            
        } else if([value class]){
             NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:[value class].entityName inManagedObjectContext:[[value class] managedObjectContext]];
            [[value class] propertiesClass:self.class ToManaged:object];
            
        }
        
        
    }];
    
}








+(id)fromManaged:(NSManagedObject*)managedObject{
    CoreDataBase *newObject = [[[self class ]alloc] init];
    
    [newObject setValue:[managedObject valueForKey:@"id"] forKey:@"id"];
    
    [self.class properties:^(NSString *name, objc_property_t property) {
        @try{
            id value = [managedObject valueForKey:name];
            
            if([value isKindOfClass:[NSString class]]){
                [newObject setValue:value forKey:name];
            }
            else if([value isKindOfClass:[NSNumber class]]){
                [newObject setValue:value forKey:name];
            }
        }@catch (NSException * e) {
            //NSLog(@"Model value not in core data entity: %@", e);
        }
    }];
    [newObject setManaged:managedObject];
    return newObject;
}

+(NSArray*)managedArrayToCoreDataBaseArray:(NSArray*)results{
    NSMutableArray* CoreDataBaseObjects = [[NSMutableArray alloc] init];
    for(NSManagedObject* managed in results){
        [CoreDataBaseObjects addObject:[self.class fromManaged:managed]];
    }
    return CoreDataBaseObjects;
}

-(void)setManaged:(NSManagedObject *)managed{
    _managed = managed;
}

-(CoreDataBase*)pivot{
    return self.pivot;
}

-(void)setPivot:(CoreDataBase*)pivot{
    self.pivot = pivot;
}

//==================================================================
#pragma mark - Core data
//==================================================================
+(NSString*)entityName{
    NSString* entityName = NSStringFromClass(self.class);
    if(self.class.usesPrefix){
        return [entityName substringFromIndex:2];
    }
    return entityName;
}

+(NSManagedObjectContext*)managedObjectContext{
    NSManagedObjectContext * context = [CoreDataContex manager].managedObjectContext;
    return context;
}

+(BOOL)usesPrefix{
    return false;
}

+(BOOL)saveCoreData{
    NSError* error = nil;
    if(![[self.class managedObjectContext] save:&error]){
        NSLog(@"Error: %@", [error localizedDescription]);
        return false;
    }
    return true;
}

@end
