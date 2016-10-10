//
//  ViewController.m
//  ABBCoreDataManager
//
//  Created by beyondsoft-聂小波 on 16/8/26.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self example1];
}

#pragma mark - 存取 数据
- (void)example1 {
    
 //********1************
    
    //1 模型 转 字典
    Person* person = [[Person alloc] init];
    person.name = @"小明";
    person.age  = @25;
    
    NSDictionary* personDic = [person toDictionary];
    NSLog(@"==personDic===%@==",personDic);
    
    
 //*********2***********
    
    //2 字典 转 模型
    NSDictionary* personDic2 = @{@"id":@1, @"name":@"person3",@"age":@"46" ,@"house":@{ @"name":@"house1"}};
    Person* person2 = [Person fromDictionary:personDic2];
    NSLog(@"Model data: name : %@ - age: %@ ", person2.name, person2.age);
    
 //*********3***********
    
    //保存数据模型 到 coredata
    [person save];
    [person2 save];

//**********4**********
    
    //搜索存储的数据，且年龄为10 ：返回模型（多个相同值时 处理 ？）
    Person *foundModel = [Person find:@10];
    NSLog(@"Person foundModel: %@",foundModel);

 //*********5***********
    
    //搜索存储的全部Person模型数据
    NSArray* personResult = [Person all];
    for(Person *person in personResult){
        NSLog(@"%@",[person toDictionary]);
        
        //删除该数据
        [person destroy];
    }
    
 //**********6**********
    
    //保存数据模型 到 coredata
    Person* person3 = [Person createWith:@{@"id":@1, @"name":@"person3"         ,@"age":@"46"}];
    House* house = [House createWith:@{@"id":@1, @"name":@"house1"}];
    person3.house = house;
    
//    Person* person4 = [Person createWith:@{@"id":@2, @"name":@"person4"         ,@"age":@"47",@"house":@{@"id":@1, @"name":@"house2"}}];
//    Person* person5 = [Person createWith:@{@"id":@3, @"name":@"person5"         ,@"age":@"48",@"house":@{@"id":@1, @"name":@"house3"}}];
//    Person* person6 = [Person createWith:@{@"id":@4, @"name":@"person6"         ,@"age":@"49",@"house":@{@"id":@1, @"name":@"house4"}}];
    NSArray* Result = [Person all];
    for(Person *person in Result){
        NSLog(@"person.house==%@==",person.house);
        
    }
    
    //删除该数据
    [person3 destroy];
//    [person4 destroy];
//    [person5 destroy];
//    [person6 destroy];
    
    
}

@end
