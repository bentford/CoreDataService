//
//  GlobalPersistantStoreCoordinator.h
//
//  Created by Ben Ford on 8/26/10.
//  Copyright 2010 Ben Ford All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kDatastoreName @"Model"

@interface GlobalPersistantStoreCoordinator : NSObject 

+ (GlobalPersistantStoreCoordinator *)sharedService;
- (void)reinitializeSharedService;

- (id)initWithStorePath:(NSString *)storePath;

@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, readonly) NSString *datastorePath;

- (NSManagedObjectModel *)model;

- (NSManagedObjectContext *)allocContextUsingGlobalPersistentStore;
- (NSManagedObjectContext *)allocManagedObjectContext;

- (BOOL)dataFileExists;
- (void)deleteDatastoreFile;

+ (NSString *)globalDatastoreFilePath;
@end
