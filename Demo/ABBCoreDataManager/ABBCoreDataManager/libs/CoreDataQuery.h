//
//  CoreDataQuery.h
//  ABBCoreDataManager
//
//  Created by beyondsoft-聂小波 on 16/8/26.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreDataQuery : NSObject
@property (nonatomic, strong) NSMutableArray *predicates;
@property (nonatomic, strong) NSMutableArray *sortPredicates;
@property (nonatomic, strong) NSString *model;

+(CoreDataQuery*)query:(NSString*)model;

-(CoreDataQuery*)where:(NSString*)field is:(id)value;
-(CoreDataQuery*)where:(NSString*)field operator:(NSString*)operator value:(id)value;
-(CoreDataQuery*)where:(NSString*)field in:(NSArray*)values;

-(CoreDataQuery*)orderBy:(NSString*)key;
-(CoreDataQuery*)orderBy:(NSString*)key ascendig:(BOOL)ascending;

-(CoreDataQuery*)raw:(NSString*)raw;

-(NSArray*)get;
-(id)first;

@end
