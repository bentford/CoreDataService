//
//  Persistance.m
//
//  Created by Ben Ford on 6/3/10.
//  Copyright 2010 Ben Ford.  All rights reserved
//

#import "GlobalManagedObjectContext.h"
#import "GlobalPersistantStoreCoordinator.h"
#import "GCDSingleton.h"

@implementation GlobalManagedObjectContext
@synthesize globalContext;

- (id)init {
    if( self = [super init] ) {
        globalContext = [[GlobalPersistantStoreCoordinator singleton] allocContextUsingGlobalPersistentStore];
        
        // Used to merge changes into global context when background contexts are working
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

- (void)reinitializeGlobalContext {
    globalContext = [[GlobalPersistantStoreCoordinator singleton] allocContextUsingGlobalPersistentStore];
}

#pragma mark Singleton
+ (GlobalManagedObjectContext *)sharedService {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}
#pragma mark -

#pragma mark PrivateMethods

- (void)otherContextDidSave:(NSNotification *)didSaveNotification {
    NSManagedObjectContext *context = (NSManagedObjectContext *)didSaveNotification.object;
    
    if( context.persistentStoreCoordinator == globalContext.persistentStoreCoordinator ) 
        [globalContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:didSaveNotification waitUntilDone:NO];
}

#pragma mark -
@end