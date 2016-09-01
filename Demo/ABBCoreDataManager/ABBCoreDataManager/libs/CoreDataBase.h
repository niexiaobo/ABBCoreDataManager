//
//  CoreDataBase.h
//  ABBCoreDataManager
//
//  Created by beyondsoft-聂小波 on 16/8/26.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoreDataQuery.h"
#import "CoreDataJson.h"
#import "CoreDataContex.h"

@interface CoreDataBase : CoreDataJson
@property (nonatomic, strong) NSManagedObject *managed;
@property (nonatomic, strong) CoreDataBase *pivot;

@property(strong,nonatomic) NSNumber* id;

/**
 * Creates a new object to de database
 * It MUST have the id field filled or it won't be inserted
 * If the object already exists, the db one will be returned
 */
+(id)create:(CoreDataBase*)object;

/**
 * The save function uses the model ID for checking if it already
 * exists so it will do an update, or if model ID is null or can't
 * find the object, it will create a new one and save it to the
 * database
 */
-(bool)save;

/**
 * Updates the object in the database (needs the id the be filled)
 */
-(bool)update;

/**
 * Deletes the object from the database. Id field is required
 */
-(bool)destroy;

// -----------------------------------------
// Convenience methods
// -----------------------------------------
+(id)createWith:(NSDictionary*)dict;
+(bool)updateWith:(NSDictionary*)dict;
+(bool)destroyWith:(NSNumber*)id;
+(void)destroyWithArray:(NSArray*)idsArray;

// -----------------------------------------
// Eloquent like
// -----------------------------------------
/**
 * Returns a base CoreDataQuery instance for the model that can be used to add query filters
 */

#warning 未修复报错
+ (CoreDataQuery *)query;

/**
 * Returns the model in the database that matches the id or `nil` if not found
 */
+(id)find:(NSNumber*)id;

/**
 * Returns all the models that the id is in the identifiers array
 */
+(NSArray*)findIn:(NSArray*)identifiers;

/**
 * Returns the first model found
 */
+(id)first;

/**
 * Returns the first model found sorted by
 */
+(id)first:(NSString*)sort;

/**
 * Returns all the models in the database
 */
+(NSArray*)all;

/**
 * Returns all the models in the database sorted by key
 */
+(NSArray*)all:(NSString*)sort;

/**
 * Returns the parent model related with the localKey
 */
-(CoreDataBase*)belongsTo:(NSString*)model localKey:(NSString*)localKey;

/**
 * Retuns all the models that have self as parent with the foreingKey
 */
-(NSArray*)hasMany:(NSString*)model foreignKey:(NSString*)foreignKey;

/**
 * Retuns all the models that have self as parent with the foreingKey
 */
-(NSArray*)hasMany:(NSString*)model foreignKey:(NSString*)foreignKey sort:(NSString*)sort;

/**
 * Get the related models when there is a pivot table between them,
 * you can acces the pivot information with the `pivot` method of the returning results
 */
-(NSArray*)belongsToMany:(NSString*)model pivot:(NSString*)pivotModel localKey:(NSString*)localKey foreignKey:(NSString*)foreingKey;

/**
 * Get the related models when there is a pivot table between them,
 * you can acces the pivot information with the `pivot` method of the returning results
 * sorted by sort
 */
-(NSArray*)belongsToMany:(NSString*)model pivot:(NSString*)pivotModel localKey:(NSString*)localKey foreignKey:(NSString*)foreingKey pivotSort:(NSString*)pivotSort;


/**
 * In `belongsToMany` relationships you can access to the pivot model with
 * this method, otherwise, it will be nil
 */
-(CoreDataBase*)pivot;
-(void)setPivot:(CoreDataBase*)pivot;

/**
 * Overridable function so each model can define its managedObjectContext
 * By default it returns the CoreDataBaseCoredata.manager
 */
+(NSManagedObjectContext*)managedObjectContext;

@end
