//
//  GlobalPersistantStoreCoordinator.h
//
//  Created by Ben Ford on 8/26/10.
//  Copyright 2010 Ben Ford All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kDatastoreName @"MakeItReal_v2"

@interface GlobalPersistantStoreCoordinator : NSObject 

+ (GlobalPersistantStoreCoordinator *)sharedService;
- (void)reinitializeSharedService;

- (id)initWithStorePath:(NSString *)storePath;

@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, readonly) NSString *datastorePath;

- (NSManagedObjectModel *)model;

- (NSManagedObjectContext *)allocContextUsingGlobalPersistentStore;

- (BOOL)dataFileExists;
- (void)deleteDatastoreFile;

+ (NSString *)globalDatastoreFilePath;
@end
