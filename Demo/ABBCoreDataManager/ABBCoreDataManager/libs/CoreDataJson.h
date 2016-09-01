//
//  CoreDataJson.h
//  ABBCoreDataManager
//
//  Created by beyondsoft-聂小波 on 16/8/26.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CoreDataObject.h"
@interface CoreDataJson : CoreDataObject
/**
 * 通过字典创建数据模型
 */
+(id)fromDictionary:(NSDictionary*)dict;

/**
 *  通过字典 字符串 创建数据模型
 */
+(id)fromDictionaryString:(NSString*)string;

/**
 * Creates a dictionary from the model
 *  数据模型 转 字典
 */
-(NSDictionary*)toDictionary;

/**
 * 空数组（不可变）
 */
-(NSArray*)toDictionaryIgnore;

@end
