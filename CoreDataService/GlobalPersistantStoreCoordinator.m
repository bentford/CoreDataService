//
//  GlobalPersistantStoreCoordinator.m
//
//  Created by Ben Ford on 8/26/10.
//  Copyright 2010 Ben Ford.  All rights reserved
//

#import "GlobalPersistantStoreCoordinator.h"
#import "GCDSingleton.h"


#define kDebugCoordinator NO
#define kEnableAutomaticMigration YES
#define kEnableProgressiveMigration NO

@interface GlobalPersistantStoreCoordinator(PrivateMethods)
- (BOOL)progressivelyMigrateURL:(NSURL*)sourceStoreURL ofType:(NSString*)type toModel:(NSManagedObjectModel*)finalModel error:(NSError**)error;
@end

static NSString *globalDatastoreFilename;

@implementation GlobalPersistantStoreCoordinator
{
    NSManagedObjectModel *model;
    NSString *datastorePath;
}

+ (void)setGlobalDatastoreFileName:(NSString *)fileName
{
    globalDatastoreFilename = fileName;
}

+ (NSString *)globalDatastoreFileName
{
    return globalDatastoreFilename;
}

+ (NSString *)globalDatastoreFilePath
{
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filename = [GlobalPersistantStoreCoordinator globalDatastoreFileName];
    NSString *databaseFilename = [NSString stringWithFormat:@"%@.sqlite", filename];
	return [cachesDirectory stringByAppendingPathComponent:databaseFilename];
}

- (id)initWithStorePath:(NSString *)newStorePath {
    if( self = [super init] ) {
        [self initializeCoordinatorWithPath:newStorePath];
        
    }
    return self;
}

#pragma mark Singleton
+ (GlobalPersistantStoreCoordinator *)singleton {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] initWithStorePath:[GlobalPersistantStoreCoordinator globalDatastoreFilePath]];
    });
}
#pragma mark -

- (void)reinitializeSingleton {
    [self initializeCoordinatorWithPath:[GlobalPersistantStoreCoordinator globalDatastoreFilePath]];
}

- (NSString *)datastorePath {
    return datastorePath;
}

- (NSManagedObjectModel *)model
{
    if (model != nil)
        return model;
    
    NSString *modelPath;
    if ([self isRunningInOCUnit])
        modelPath = [[NSBundle bundleForClass:[self class]] pathForResource:globalDatastoreFilename ofType:@"momd"];
    else
        modelPath = [[NSBundle mainBundle] pathForResource:globalDatastoreFilename ofType:@"momd"];
    
    NSURL *modelURL = [[NSURL alloc] initFileURLWithPath:modelPath];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return model;
}

- (NSManagedObjectContext *)allocContextUsingGlobalPersistentStore {	
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:[GlobalPersistantStoreCoordinator singleton].coordinator];
    
    return context;
}

- (NSManagedObjectContext *)allocManagedObjectContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:self.coordinator];

    return context;
}

- (BOOL)dataFileExists {
    return [[NSFileManager defaultManager] fileExistsAtPath:datastorePath];
}


- (void)deleteDatastoreFile {
    
    if( [[NSFileManager defaultManager] isDeletableFileAtPath:datastorePath] == NO )
        NSLog(@"file not deletable, but trying anyway");
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:datastorePath error:&error];
    
    if( error != nil )
        NSLog(@"could not delete file. Error: %@", [error localizedDescription]);
    else
        NSLog(@"SUCCESSFULLY DELETED DATAFILE");
}
#pragma mark PrivateMethods

- (void)initializeCoordinatorWithPath:(NSString *)newStorePath
{
    datastorePath = newStorePath;
    NSURL *storeUrl = [NSURL fileURLWithPath:datastorePath];
    
    NSError *error = nil;
    if( kDebugCoordinator )
        NSLog(@"model version identifiers: %@", [self model].versionIdentifiers);
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];
    
    NSDictionary *options;
    if( kEnableAutomaticMigration )
        options = [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                   [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                   nil];
    else
        options = [NSDictionary dictionary];
    
    NSError *metadataError = nil;
    NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeUrl error:&metadataError];
    
    if( kDebugCoordinator )
        NSLog(@"store meta data: %@", storeMetadata);
    
    
    BOOL isCompatible = [_coordinator.managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:storeMetadata];
    
    if( kDebugCoordinator )
        NSLog(@"using datafile: %@", globalDatastoreFilename);
    
    if( kEnableAutomaticMigration == NO && isCompatible == NO ) {
        NSLog(@"CoreData: persistent store is not compatible with current model. Auto migration is disabled so I'm aborting.");
        abort();
    }
    
    
    if( kEnableAutomaticMigration == YES && isCompatible == NO )
        NSLog(@"CoreData: persistent store is not compatible with current model.  Will attempt auto-migration.");
    
    if( kEnableAutomaticMigration == YES && kEnableProgressiveMigration == YES && isCompatible == NO ) {
        NSLog(@"CoreData: attempting progressive migration");
        
        NSError *progressiveMigrationError = nil;
        [self progressivelyMigrateURL:storeUrl ofType:NSSQLiteStoreType toModel:_coordinator.managedObjectModel error:&progressiveMigrationError];
        
        if( progressiveMigrationError != nil ) {
            NSLog(@"CoreData: Error progressively migrating persistent store: %@", [progressiveMigrationError localizedDescription]);
            abort();
        }
    }
    
    if( [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error] == nil ) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible
         * The schema for the persistent store is incompatible with current managed object model
         Check the error message to determine what the actual problem was.
         */
        NSLog(@"Unresolved error %@, %@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

- (BOOL)progressivelyMigrateURL:(NSURL*)sourceStoreURL ofType:(NSString*)type toModel:(NSManagedObjectModel*)finalModel error:(NSError**)error {
    
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type URL:sourceStoreURL error:error];
    if( !sourceMetadata ) 
        return NO;
    
    if ([finalModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata] == YES) {
        // check for null dereference before clearing
        if (*error != nil)
            *error = nil;
        
        return YES;
    }
    
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];
    NSAssert(sourceModel != nil, ([NSString stringWithFormat:@"Failed to find source model\n%@", sourceMetadata]));
    
    //Find all of the mom and momd files in the Resources directory
    NSMutableArray *modelPaths = [NSMutableArray array];
    NSArray *momdArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd" inDirectory:nil];
    
    for( NSString *momdPath in momdArray ) {
        NSString *resourceSubpath = [momdPath lastPathComponent];
        NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:resourceSubpath];
        
        [modelPaths addObjectsFromArray:array];
    }
    
    NSArray *otherModels = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:nil];
    [modelPaths addObjectsFromArray:otherModels];
    
    if( !modelPaths || ![modelPaths count] ) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"No models found in bundle" forKey:NSLocalizedDescriptionKey];

        // prevent null dereference
        if (*error != nil)
            *error = [NSError errorWithDomain:@"Zarra" code:8001 userInfo:dict];
        return NO;
    }
    
    NSMappingModel *mappingModel = nil;
    NSManagedObjectModel *targetModel = nil;
    NSString *modelPath = nil;
    for (modelPath in modelPaths) {
        
        targetModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];        
        mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:targetModel];
        
        if( mappingModel ) 
            break;
        
        targetModel = nil;
    }
    
    // We have tested every model, if nil here we failed
    if( !mappingModel ) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"No models found in bundle" forKey:NSLocalizedDescriptionKey];

        // prevent null dereference
        if (*error != nil)
            *error = [NSError errorWithDomain:@"Zarra" code:8001 userInfo:dict];
        return NO;
    }
    
    // We have a mapping model and a destination model.  Time to migrate
    
    NSMigrationManager *manager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:targetModel];
    
    NSString *modelName = [[modelPath lastPathComponent] stringByDeletingPathExtension];
    NSString *storeExtension = [[sourceStoreURL path] pathExtension];
    NSString *storePath = [[sourceStoreURL path] stringByDeletingPathExtension];
    
    // Build a path to write the new store
    storePath = [NSString stringWithFormat:@"%@.%@.%@", storePath, modelName, storeExtension];
    
    NSURL *destinationStoreURL = [NSURL fileURLWithPath:storePath];
    
    if( ![manager migrateStoreFromURL:sourceStoreURL type:type options:nil withMappingModel:mappingModel toDestinationURL:destinationStoreURL destinationType:type destinationOptions:nil error:error] ) 
        return NO;
    
    
    // Migration was successful, move the files around to preserve the source
    
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    guid = [guid stringByAppendingPathExtension:modelName];
    guid = [guid stringByAppendingPathExtension:storeExtension];
    
    NSString *appSupportPath = [storePath stringByDeletingLastPathComponent];
    NSString *backupPath = [appSupportPath stringByAppendingPathComponent:guid];
    
    if( [[NSFileManager defaultManager] moveItemAtPath:[sourceStoreURL path] toPath:backupPath error:error] == NO ) {
        // Failed to copy the file
        return NO;
    }
    
    // Move the destination to the source path
    if( [[NSFileManager defaultManager] moveItemAtPath:storePath toPath:[sourceStoreURL path] error:error] == NO ) {
        // Try to back out the source move first, no point in checking it for errors
        [[NSFileManager defaultManager] moveItemAtPath:backupPath toPath:[sourceStoreURL path] error:nil];
        return NO;
    }
    
    // We may not be at the "current" model yet, so recurse
    return [self progressivelyMigrateURL:sourceStoreURL ofType:type toModel:finalModel error:error];
}
#pragma mark -

- (BOOL)isRunningInOCUnit
{
    // Info.plist must exist in a bundle: which will either be the app bundle for regular application launches, or
    // OCUnit generated bundle for testing with SenTestKit/OCUnit.
    //
    // If we don't find an Info.plist in the main bundle, we know we're being run in OCUnit.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    return path == nil;
}
@end
