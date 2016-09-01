//
//  CoreDataObject.h
//  ABBCoreDataManager
//
//  Created by beyondsoft-聂小波 on 16/8/26.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface CoreDataObject : NSObject <NSCopying>

+(void)properties:(void (^)(NSString* name, objc_property_t property))block;
@end
