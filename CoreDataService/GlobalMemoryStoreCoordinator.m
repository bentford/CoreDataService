//
//  GlobalMemoryStoreCoordinator.m
//  CoreDataService
//
//  Created by Ben Ford on 11/25/15.
//  Copyright © 2015 Ben Ford. All rights reserved.
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

#import "GlobalMemoryStoreCoordinator.h"
#import "GCDSingleton.h"


#define kDebugCoordinator NO
#define kEnableAutomaticMigration YES

@interface GlobalMemoryStoreCoordinator()
@end

static NSString *globalDatastoreFilename;

@implementation GlobalMemoryStoreCoordinator
{
    NSManagedObjectModel *model;
    NSString *datastorePath;
}

+ (void)setGlobalDatastoreName:(NSString *)fileName
{
    globalDatastoreFilename = fileName;
}

+ (NSString *)globalDatastoreName
{
    return globalDatastoreFilename;
}

- (id)init
{
    if( self = [super init] ) {
        [self initializeCoordinator];
        
    }
    return self;
}

#pragma mark Singleton
+ (GlobalMemoryStoreCoordinator *)singleton {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}
#pragma mark -

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

- (NSManagedObjectContext *)allocManagedObjectContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:self.coordinator];
    
    return context;
}

#pragma mark PrivateMethods

- (void)initializeCoordinator
{
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
    
    if( kDebugCoordinator )
        NSLog(@"using datafile: %@", globalDatastoreFilename);
    
    if( [_coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:options error:&error] == nil ) {
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
