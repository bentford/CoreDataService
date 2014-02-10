//
//  GlobalPersistantStoreCoordinator.h
//
//  Created by Ben Ford on 8/26/10.
//  Copyright 2010 Ben Ford All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface GlobalPersistantStoreCoordinator : NSObject 

/*
 Initialize global singleton.
 **/
+ (void)setGlobalDatastoreFileName:(NSString *)fileName;

+ (GlobalPersistantStoreCoordinator *)singleton;
- (void)reinitializeSingleton;




- (id)initWithStorePath:(NSString *)storePath;

@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, readonly) NSString *datastorePath;

- (NSManagedObjectModel *)model;

- (NSManagedObjectContext *)allocContextUsingGlobalPersistentStore;
- (NSManagedObjectContext *)allocManagedObjectContext;

- (BOOL)dataFileExists;
- (void)deleteDatastoreFile;

@end
