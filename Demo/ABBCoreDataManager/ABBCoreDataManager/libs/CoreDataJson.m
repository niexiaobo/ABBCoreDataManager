//
//  CoreDataJson.m
//  ABBCoreDataManager
//
//  Created by beyondsoft-聂小波 on 16/8/26.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import "CoreDataJson.h"


@implementation CoreDataJson

#pragma mark - 通过字典创建数据模型
+(id)fromDictionary:(NSDictionary*)dict{
    
    if([dict isKindOfClass:NSDictionary.class]){
        CoreDataJson* model = [[self.class alloc] init];
        
        for(NSString* key in dict.allKeys){
            
            id value = dict[key];
            id valueConverted = [model valueConverted:value forKey:key];
            if(valueConverted != nil){
                [model setValue:valueConverted forKey:key];
            }
        }
        return model;
    }
    if([self.class isNull:dict] || [@"null" isEqualToString:(NSString*)dict] || [@"" isEqualToString:(NSString*)dict] ){
        return nil;
    }
    
    [NSException raise:@"Not a NSDictionary" format:@"Trying to create a Daikiri model from a non dictionary object"];
    return nil;
}

#pragma mark - 通过字典 字符串 创建数据模型
+(id)fromDictionaryString:(NSString*)string{
    NSData *data        = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* dict  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [self.class fromDictionary:dict];
}

#pragma mark - 数据模型 转 字典
-(NSDictionary*)toDictionary{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    [self.class properties:^(NSString *name, objc_property_t property) {
        
        if(![self shouldIgnoreKey:name]){
            
            id value = [self valueForKey:name];
            if([self.class isNull:value]){
                dict[name] = NSNull.null;
            }
            else if([value isKindOfClass:NSString.class]){
                dict[name] = [self convertoNSString:value];
            }
            else if([value isKindOfClass:NSNumber.class]){
                dict[name] = [self convertToNSNumber:value];
            }
            else if([value isKindOfClass:NSArray.class]){
                NSMutableArray* dictArray = [[NSMutableArray alloc] init];
                for(id child in value){
                    if([child isKindOfClass:CoreDataJson.class])
                        [dictArray addObject:[child toDictionary]];
                    else
                        [dictArray addObject:child];
                }
                dict[name] = dictArray;
            }
            else{
                id subValue = [value toDictionary];
                dict[name] = subValue;
            }
        }
    }];
    
    return dict;
}

#pragma mark - 忽略对象
-(BOOL)shouldIgnoreKey:(NSString*)key{
    return [self.toDictionaryIgnore containsObject:key];
}

#pragma mark - 空数组（不可变）
-(NSArray*)toDictionaryIgnore{
    return @[];
}

//==================================================================
#pragma mark - HELPERS
//==================================================================
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
-(id)valueConverted:(id)value forKey:(NSString*)key{
    
    if([self.class isNull:value]){
        return nil;
    }
    if([key isEqualToString:@"id"]){
        return [self convertToNSNumber:value];
    }
    if ([self classForKeyPath:key] == NSString.class){
        return [self convertoNSString:value];
    }
    if ([self classForKeyPath:key] == NSNumber.class){
        return [self convertToNSNumber:value];
    }
    else if([value isKindOfClass:NSArray.class]){
        NSString* methodName        = [NSString stringWithFormat:@"%@_DaikiriArray",key];
        SEL s                       = NSSelectorFromString(methodName);
        
        if ([self respondsToSelector:s]) {
            Class childClass            = [self performSelector:s];
            NSMutableArray* newArray    = [[NSMutableArray alloc] init];
            for(id arrayDict in value){
                id childModel = [childClass fromDictionary:arrayDict];
                [newArray addObject:childModel];
            }
            return newArray;
        }
        else{
            return value;
        }
    }
    else{
        id subValue = [[self classForKeyPath:key] fromDictionary:value];
        return subValue;
    }
    return nil;
}

#pragma clang diagnostic pop
-(Class)classForKeyPath:(NSString*)keyPath {
    
    __block Class class = 0;
    [self.class properties:^(NSString *name, objc_property_t property) {
        
        if ( [keyPath isEqualToString:name] ){
            const char* attributes = property_getAttributes(property);
            if (attributes[1] == '@') {
                NSMutableString* className = [NSMutableString new];
                
                for (int j=3; attributes[j] && attributes[j]!='"'; j++){
                    [className appendFormat:@"%c", attributes[j]];
                }
                class = NSClassFromString(className);
            }
        }
    }];
    return class;
}

-(NSNumber*)convertToNSNumber:(NSNumber*)value{
    if([value isKindOfClass:NSString.class]){
        return @([value floatValue]);
    }
    return value;
}

-(NSString*)convertoNSString:(NSString*)value{
    if([value isKindOfClass:NSNumber.class]){
        return ((NSNumber*)value).stringValue;
    }
    return value;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

+(BOOL)isNull:(id)value{
    return (value == nil || [value isKindOfClass:[NSNull class]]);
}


@end
