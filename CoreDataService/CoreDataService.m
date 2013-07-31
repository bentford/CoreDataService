    //
//  GenericDataService.m
//
//  Created by Ben Ford on 6/3/10.
//

#import "CoreDataService.h"
#import "ErrorUtil.h"
#import "GlobalManagedObjectContext.h"
#import "NSString+Ext.h"

#define kDebugEmptyResults NO
#define kDebugEmptyContextSaves NO

@interface CoreDataService(PrivateMethods)
+ (void)verifyThreadSafetyForContext:(NSManagedObjectContext *)context;
@end

@implementation CoreDataService

#pragma mark Helper methods that use global CoreData Context (only valid to use on Main thread)
+ (NSArray *)executeFetchRequest:(NSFetchRequest *)request {
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    return [CoreDataService context:context executeFetchRequest:request];
}

+ (id)fetchEntity:(NSString *)entityName withPredicate:(NSPredicate *)thePredicate {
    
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    return [CoreDataService context:context fetchEntity:entityName withPredicate:thePredicate];     
}

+ (id)fetchEntity:(NSString *)entityName byAttribute:(NSString *)attribute withValue:(id)value {
    
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    return [CoreDataService context:context fetchEntity:entityName byAttribute:attribute withValue:value];
}

+ (NSArray *)fetchEntities:(NSString *)entityName byAttribute:(NSString *)attribute withValues:(NSArray *)values {
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    return [CoreDataService context:context fetchEntities:entityName byAttribute:attribute withValues:values];
}

+ (id)makeObjectWithEntityName:(NSString *)name {
    
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    return [CoreDataService context:context makeObjectWithEntityName:name];
}

+ (NSArray *)fetchEntities:(NSString *)entityName {
    
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    return [CoreDataService context:context fetchEntities:entityName];
}

+ (NSArray *)fetchEntities:(NSString *)entityName withPredicate:(NSPredicate *)thePredicate {

    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    return [CoreDataService context:context fetchEntities:entityName withPredicate:thePredicate];
}

+ (id)fetchEntityByObjectID:(NSManagedObjectID *)objectID {
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    return [context objectWithID:objectID];
}

+ (NSSet *)fetchEntitiesByObjectIdSet:(NSSet *)objectIdSet {
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    return [CoreDataService context:context fetchEntitiesByObjectIdSet:objectIdSet];
}

+ (NSArray *)fetchEntitiesByObjectIdArray:(NSArray *)objectIdArray {
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    return [CoreDataService context:context fetchEntitiesByObjectIdArray:objectIdArray];
}

+ (void)refreshObject:(NSManagedObject *)objectToRefresh mergeChanges:(BOOL)mergeChanges {
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    [CoreDataService context:context refreshObject:objectToRefresh mergeChanges:mergeChanges];
}

+ (BOOL)save {
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    return [CoreDataService contextSave:context requireMainThread:YES];
}

+ (void)deleteObject:(id)object {
    if( object == nil ) {
        NSLog(@"GenericDataService: ignoring attempt to delete nil object");
        return;
    }
    
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    [CoreDataService context:context deleteObject:object];
}

+ (void)deleteObjects:(NSSet *)objects {
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    [CoreDataService context:context deleteObjects:objects];
}

+ (void)deleteEntitiesForClass:(Class)classToDelete {
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    [CoreDataService context:context deleteEntitiesForClass:classToDelete];
}

+ (void)deleteEntities:(NSString *)entityName withPredicate:(NSPredicate *)predicate {
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    [CoreDataService context:context deleteEntities:entityName withPredicate:predicate];
}
#pragma mark -



+ (NSArray *)context:(NSManagedObjectContext *)context executeFetchRequest:(NSFetchRequest *)request {
    [CoreDataService verifyThreadSafetyForContext:context];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if( error )
        NSLog(@"CoreData Error (in executeFetchRequest) ++ %@", [error localizedDescription]);
    
    if( [results count] < 1 ) {
        if( kDebugEmptyResults )
            NSLog(@"CoreData Warning: nothing matched fetch request: %@",[request description]); 
        return [NSArray array];
    } else
        return results;
}

+ (id)context:(NSManagedObjectContext *)context fetchEntity:(NSString *)entityName withPredicate:(NSPredicate *)thePredicate {
    [CoreDataService verifyThreadSafetyForContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
    
    [request setPredicate:thePredicate];
    [request setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if( error )
        NSLog(@"CoreData Error (in fetchEntity:withPredicate) ++ %@", [error localizedDescription]);
    
    if( [results count] < 1 ) {
        if( kDebugEmptyResults )
            NSLog(@"CoreData Warning: for entity: %@, nothing matched predicate: %@",entityName,[thePredicate description]); 
        return nil;
    } else
        return [results objectAtIndex:0];
}

+ (id)context:(NSManagedObjectContext *)context fetchEntity:(NSString *)entityName byAttribute:(NSString *)attribute withValue:(id)value {
    [CoreDataService verifyThreadSafetyForContext:context];
    
    if (value == nil) {
        return nil;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
    
    if( [value isKindOfClass:[NSString class]] )
        [request setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",attribute, value]];
    else if( [value isKindOfClass:[NSNumber class]] ) 
        [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %d",attribute, [value intValue]]];
    
    [request setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if( error )
        NSLog(@"CoreData Error (in fetchEntity:byAttribute:withValue:) ++  %@", [error localizedDescription]);
    
    if( [results count] < 1 ) {
        if( kDebugEmptyResults )
            NSLog(@"CoreData Warning: for entity: %@, nothing matched %@ == %@",entityName,attribute,value); 
        return nil;
    } else
        return [results objectAtIndex:0];
}

+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntities:(NSString *)entityName byAttribute:(NSString *)attribute withValues:(NSArray *)values
{
    if ([values count] == 0)
        return [NSArray array];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN %@", attribute, values];
    
    return [CoreDataService context:context fetchEntities:entityName withPredicate:predicate];
}

+ (id)context:(NSManagedObjectContext *)context makeObjectWithEntityName:(NSString *)name {
    [CoreDataService verifyThreadSafetyForContext:context];
    
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];   
}

+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntities:(NSString *)entityName
{
    return [CoreDataService context:context fetchEntities:entityName fetchPropertyValues:YES];
}

+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntities:(NSString *)entityName fetchPropertyValues:(BOOL)fetchPropertyValues
{
    [CoreDataService verifyThreadSafetyForContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
    [request setIncludesPropertyValues:fetchPropertyValues];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if( error )
        NSLog(@"CoreData Error (in fetchEntities:) ++ %@",[error localizedDescription]);
    
    return results;
}

+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntities:(NSString *)entityName withPredicate:(NSPredicate *)thePredicate {
    [CoreDataService verifyThreadSafetyForContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
    
    [request setPredicate:thePredicate];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if( error )
        NSLog(@"CoreData Error (in fetchEntity:withPredicate) ++ %@", [error localizedDescription]);
    
    if( kDebugEmptyResults && [results count] < 1 ) 
        NSLog(@"CoreData Warning: for entity: %@, nothing matched predicate: %@",entityName,[thePredicate description]); 
    
    return results;
}

+ (id)context:(NSManagedObjectContext *)context fetchEntityByObjectID:(NSManagedObjectID *)objectID {
    [CoreDataService verifyThreadSafetyForContext:context];
    
    return [context objectWithID:objectID];
}

+ (NSSet *)context:(NSManagedObjectContext *)context fetchEntitiesByObjectIdSet:(NSSet *)objectIdSet {
    NSMutableSet *entities = [NSMutableSet setWithCapacity:[objectIdSet count]];
    for( NSManagedObjectID *objectId in [objectIdSet allObjects]) {
        id object = [CoreDataService context:context fetchEntityByObjectID:objectId];
        [entities addObject:object];
    }
    return entities;
}

+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntitiesByObjectIdArray:(NSArray *)objectIdArray {
    NSMutableArray *entities = [NSMutableArray arrayWithCapacity:[objectIdArray count]];
    for( NSManagedObjectID *objectId in objectIdArray) {
        id object = [CoreDataService context:context fetchEntityByObjectID:objectId];
        [entities addObject:object];
    }
    return entities;
}

+ (void)context:(NSManagedObjectContext *)context refreshObject:(NSManagedObject *)objectToRefresh mergeChanges:(BOOL)mergeChanges {
    [CoreDataService verifyThreadSafetyForContext:context];
    
    [context refreshObject:objectToRefresh mergeChanges:mergeChanges];
}

+ (BOOL)contextSave:(NSManagedObjectContext *)context requireMainThread:(BOOL)shouldRequireMainThread {
    [CoreDataService verifyThreadSafetyForContext:context];
    
    if( shouldRequireMainThread == NO && [NSThread isMainThread] == YES ) {
        NSLog(@"+++ERROR: you are saving on main thread, but not requiring the main thread.  Are you expecting a background thread?");
        if( kShouldAbortOnCoreDataThreadError ) {
            abort();
            return NO;
        }
    }

    if( shouldRequireMainThread == YES && [NSThread isMainThread] == NO ) {
        NSLog(@"+++SERIOUS ERROR: call to the global ManagedObjectContext from a background thread is not allowed.  The save request was ignored.");
        if( kShouldAbortOnCoreDataThreadError )
            abort();
        return NO;
    }
    
    if( [context hasChanges] == NO ) {
        if( kDebugEmptyContextSaves )
            NSLog(@"GenericDataService: context had no changes to save.");
        
        return YES;
    }
    
    NSError *error = nil;
    BOOL wasSuccessful = [context save:&error];
    
    if( wasSuccessful == NO ) {
        NSLog(@"CoreData Error (in save) ++ %@", [error localizedDescription]);
        switch ([error code]) {
            case NSPersistentStoreSaveError:
                NSLog(@"PersistentStoreSaveError: unclassified save error - something we depend on returned an error.");
                break;
            case NSValidationMultipleErrorsError:
                NSLog(@"NSValidationMultipleErrorsError: Error code to denote an error containing multiple validation errors.");
                NSLog(@"%@", [ErrorUtil stringFromMultipleErrors:error]);
                break;
            case NSManagedObjectValidationError:
                NSLog(@"NSManagedObjectValidationError: denotes a generic validation error.");
                break;
            case 133020:
                NSLog(@"Merge conflict error");
                NSLog(@"conflict list: %@", [error.userInfo objectForKey:@"conflictList"]);
                break;
            default:
                NSLog(@"Unknown error: %@", [error userInfo]);
                break;
        }
    }
    
    return wasSuccessful;
}

+ (void)context:(NSManagedObjectContext *)context deleteEntitiesForClass:(Class)classToDelete {
    [CoreDataService verifyThreadSafetyForContext:context];
    
    NSArray *objectsToDelete = [CoreDataService context:context fetchEntities:NSStringFromClass(classToDelete) fetchPropertyValues:NO];
    [CoreDataService context:context deleteObjects:[NSSet setWithArray:objectsToDelete]];
}

+ (void)context:(NSManagedObjectContext *)context deleteObjects:(NSSet *)objects {
    [CoreDataService verifyThreadSafetyForContext:context];
    
    for (NSManagedObject *object in objects) {
        [CoreDataService context:context deleteObject:object];
    }
}

+ (void)context:(NSManagedObjectContext *)context deleteObject:(id)object {
    [CoreDataService verifyThreadSafetyForContext:context];
    
    [context deleteObject:object];
}

+ (void)context:(NSManagedObjectContext *)context deleteEntities:(NSString *)entityName withPredicate:(NSPredicate *)predicate {
    NSArray *entitiesToDelete = [CoreDataService context:context fetchEntities:entityName withPredicate:predicate];
    [CoreDataService context:context deleteObjects:[NSSet setWithArray:entitiesToDelete]];
}

+ (NSArray *)arrayOfObjectIDsFromObjects:(NSArray *)managedObjectArray {
    NSMutableArray *objectIDs = [NSMutableArray arrayWithCapacity:[managedObjectArray count]];
    for( NSManagedObject *object in managedObjectArray )
        [objectIDs addObject:object.objectID];
    
    return objectIDs;
}

+ (NSArray *)arrayOfPropertiesWithName:(NSString *)propertyName fromObjects:(NSArray *)managedObjects skipNulls:(BOOL)skipNulls {
    NSMutableArray *propertyValues = [NSMutableArray arrayWithCapacity:[managedObjects count]];
    for (NSManagedObject *object in managedObjects) {
        id propertyValue = [object valueForKey:propertyName];

        if (propertyValue == nil && skipNulls == NO)
            [propertyValues addObject:[NSNull null]];
        
        if (propertyValue != nil)
            [propertyValues addObject:propertyValue];
    }
    
    return propertyValues;
}
@end

@implementation CoreDataService(PrivateMethods)
+ (void)verifyThreadSafetyForContext:(NSManagedObjectContext *)context {
    
    if( [NSThread isMainThread] == NO && context == [GlobalManagedObjectContext sharedService].globalContext ) {
        NSLog(@"ERROR: you are accessing the global context from a background thread!!!!!!!!!!!!!!!");
        abort();
    }
}
@end