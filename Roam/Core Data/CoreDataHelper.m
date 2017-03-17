//
//  CoreDataHelper.m
//  Roam
//
//  Created by 黄文鸿 on 2017/3/16.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

static CoreDataHelper *instance = nil;

#pragma mark - File Name
NSString *storeFileName = @"WebInfo.sqlite";

#pragma mark - Paths
- (NSString *)applicationDocumentDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL *)applicationStoreDictory {
    NSURL *storeDirectory = [[NSURL fileURLWithPath:[self applicationDocumentDirectory]] URLByAppendingPathComponent:@"Stores"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:[storeDirectory path]]) {
        NSError *error = nil;
        if(![fileManager createDirectoryAtPath:storeDirectory.path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Fail to create store dictory: %@", error);
            return nil;
        }
    }
    
    return storeDirectory;
}

- (NSURL *)storeURL {
    return [[self applicationStoreDictory] URLByAppendingPathComponent:storeFileName];
}


#pragma mark - Set Up

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CoreDataHelper alloc] initPrivate];
        [instance setUpCoreData];
    });
    return instance;
}

- (instancetype)initPrivate {
    self = [super init];
    if(self) {
        _model = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]];
        _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_context setPersistentStoreCoordinator:_coordinator];
    }
    return self;
}

- (void)loadStore {
    if(_store) {
        return;
    }
    
    NSError *error = nil;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:options error:&error];
    if(!_store) {
        NSLog(@"Fail to create store: %@", error);
        abort();
    }
}

- (void)setUpCoreData {
    [self loadStore];
}

- (void)saveContext {
    if([_context hasChanges]) {
        NSError *error = nil;
        if(![_context save:&error]) {
            NSLog(@"Fail to save changes %@", error);
        } else {
            NSLog(@"Save changes successfully!");
        }
    } else {
        NSLog(@"No change is to be saved!");
    }
}


#pragma mark - Singleton Operation
- (instancetype)copy {
    return instance;
}

- (instancetype)init {
    return instance;
}

@end
