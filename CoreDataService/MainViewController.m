//
//  ViewController.m
//  CoreDataService
//
//  Created by Ben Ford on 7/30/13.
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

#import "MainViewController.h"
#import "CoreDataService.h"
#import "AllManagedObjects.h"
#import "GCDUtilities.h"
#import "GlobalPersistantStoreCoordinator.h"
#import "GlobalManagedObjectContext.h"

typedef enum {
    DatastoreLocationActive = 0,
    DatastoreLocationSync,
    DatastoreLocationWorker,
} DatastoreLocation;

@interface MainViewController()
@end

@implementation MainViewController
{
    NSOperationQueue *queue;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;


    [self repeatedlyCheckForRecord];




}

- (void)createRecordIfNeeded
{
    Person *person = [Person fetchEntityByAttribute:@"name" value:@"Bob" context:nil];

    if (person == nil) {
        NSLog(@"Creating bob");
        person = [Person makeEntityWithContext:nil];
        person.name = @"Bob";
        [CoreDataService save];
    }
}

- (void)repeatedlyCheckForRecord
{
    [self createRecordIfNeeded];
    [self checkForRecord];

    [queue addOperationWithBlock:^{
        [self copyCurrentDatastoreFileToActive];
        [self reinitializeDatastore];
    }];

    dispatch_after_delay_ext(3.0f, dispatch_get_main_queue(), ^{
        [self repeatedlyCheckForRecord];
    });
}

- (void)checkForRecord
{
    NSArray *people = [Person fetchAllEntitiesWithContext:nil];
    for (Person *person in people) {
        NSLog(@"person: %@", person.name);
    }
}

- (void)reinitializeDatastore
{
    // this is required for new datastore file to be read from disk
    dispatch_async(dispatch_get_main_queue(), ^{
        [[GlobalPersistantStoreCoordinator singleton] reinitializeSingleton];
        [[GlobalManagedObjectContext sharedService] reinitializeGlobalContext];
    });

}

- (void)copyCurrentDatastoreFileToActive
{

    // create second persistant store to simulate the sync database
    // we're not actually syncing anything in the simple app
    NSString *path = [self pathForDatabaseAtLocation:DatastoreLocationSync];
    GlobalPersistantStoreCoordinator *syncStoreCoordinator = [[GlobalPersistantStoreCoordinator alloc]
                                                              initWithStorePath:path];

    [self fillDatastoreWithSomeDataUsingCoordinator:syncStoreCoordinator];

    NSString *activeDatabasePath = [GlobalPersistantStoreCoordinator globalDatastoreFilePath];
    NSString *syncDatastorePath = syncStoreCoordinator.datastorePath;

    // remove active database file entirely
    NSError *deleteFileError = nil;
    [[NSFileManager defaultManager] removeItemAtPath:activeDatabasePath error:&deleteFileError];
    if( deleteFileError != nil ) {
        NSLog(@"FATAL ERROR SYNCING: %@", [deleteFileError localizedDescription]);
        abort();
    }

    // copy sync database into to active database path
    NSError *copyFileError = nil;
    [[NSFileManager defaultManager] copyItemAtPath:syncDatastorePath toPath:activeDatabasePath error:&copyFileError];
    if( copyFileError != nil ) {
        NSLog(@"FATAL ERROR: copying current path to active path. Details: '%@'", [copyFileError localizedDescription]);
        abort();
    }

    // if we're syncing, copy this datastore to worker path.
    if ([syncDatastorePath isEqualToString:[self pathForDatabaseAtLocation:DatastoreLocationSync]]) {
        NSString *workerPath = [self pathForDatabaseAtLocation:DatastoreLocationWorker];

        // remove worker database file entirely
        NSError *deleteFileError = nil;
        [[NSFileManager defaultManager] removeItemAtPath:workerPath error:&deleteFileError];
        if( deleteFileError != nil ) {
            NSLog(@"WARNING: could not delete worker path. Details: %@", [deleteFileError localizedDescription]);
        }


        NSError *copyFileError = nil;
        [[NSFileManager defaultManager] copyItemAtPath:syncDatastorePath toPath:workerPath error:&copyFileError];
        if( copyFileError != nil ) {
            NSLog(@"FATAL ERROR: copying current path to worker path. Details: '%@'", [copyFileError localizedDescription]);
            abort();
        }
    }
}

- (NSString *)pathForDatabaseAtLocation:(DatastoreLocation)datastoreLocation {
    NSString *activeDatabasePath = [GlobalPersistantStoreCoordinator globalDatastoreFilePath];

    NSString *locationPrefix;

    switch (datastoreLocation) {
        case DatastoreLocationActive:
            locationPrefix = @"";
            break;
        case DatastoreLocationSync:
            locationPrefix = @"_sync";
            break;
        case DatastoreLocationWorker:
            locationPrefix = @"_worker";
            break;
    }

    NSString *extensionWithDot = [NSString stringWithFormat:@".%@",[activeDatabasePath pathExtension]];
    NSString *replaceWith = [NSString stringWithFormat:@"%@.%@", locationPrefix, [activeDatabasePath pathExtension]];
    NSString *finalDatastorePath = [activeDatabasePath stringByReplacingOccurrencesOfString:extensionWithDot withString:replaceWith];

    return finalDatastorePath;
}

- (void)fillDatastoreWithSomeDataUsingCoordinator:(GlobalPersistantStoreCoordinator *)syncStoreCoordinator
{
    NSManagedObjectContext *context = [syncStoreCoordinator allocManagedObjectContext];

    Person *person = [CoreDataService context:context makeObjectWithEntityName:NSStringFromClass([Person class])];
    person.name = @"Ben";
    [CoreDataService contextSave:context requireMainThread:NO];
}
@end
