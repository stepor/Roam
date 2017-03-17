//
//  CoreDataHelper.h
//  Roam
//
//  Created by 黄文鸿 on 2017/3/16.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, strong, readonly) NSPersistentStore *store;
@property (nonatomic, strong, readonly) NSManagedObjectModel *model;
@property (nonatomic, strong, readonly) NSManagedObjectContext *context;

+ (instancetype)shareInstance;
//- (void)setUpCoreData;
- (void)saveContext;
@end
