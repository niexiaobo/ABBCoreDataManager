//
//  Person.h
//  ABBCoreDataManager
//
//  Created by beyondsoft-聂小波 on 16/8/26.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import "CoreDataBase.h"

@interface Person : CoreDataBase
@property (strong,nonatomic) NSString* name;
@property (strong,nonatomic) NSNumber* age;
@end
