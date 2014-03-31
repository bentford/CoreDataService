//
//  GlobalManagedObjectContext.m
//
//  Created by Ben Ford on 6/3/10.
//  Copyright (c) 2010-2014 Ben Ford
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
// This abstracts the most common CoreData operations into easy to use methods
// It will logs errors on the console

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