//
//  CoreDataService.m
//
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


#import "CoreDataService.h"
#import "ErrorUtil.h"
#import "GlobalManagedObjectContext.h"

#define kDebugEmptyResults NO
#define kDebugEmptyContextSaves NO

@implementation CoreDataService

+ (NSArray *)context:(NSManagedObjectContext *)context executeFetchRequest:(NSFetchRequest *)request
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
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

+ (id)context:(NSManagedObjectContext *)context fetchEntity:(NSString *)entityName withPredicate:(NSPredicate *)thePredicate
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
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

+ (id)context:(NSManagedObjectContext *)context fetchEntity:(NSString *)entityName byAttribute:(NSString *)attribute withValue:(id)value
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
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
    context = [CoreDataService useGlobalContextIfNeeded:context];
    if ([values count] == 0)
        return [NSArray array];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN %@", attribute, values];
    
    return [CoreDataService context:context fetchEntities:entityName withPredicate:predicate];
}

+ (id)context:(NSManagedObjectContext *)context makeObjectWithEntityName:(NSString *)name
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
    [CoreDataService verifyThreadSafetyForContext:context];
    
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];   
}

+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntities:(NSString *)entityName
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
    return [CoreDataService context:context fetchEntities:entityName fetchPropertyValues:YES];
}

+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntities:(NSString *)entityName fetchPropertyValues:(BOOL)fetchPropertyValues
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
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

+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntities:(NSString *)entityName withPredicate:(NSPredicate *)thePredicate
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
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

+ (id)context:(NSManagedObjectContext *)context fetchEntityByObjectID:(NSManagedObjectID *)objectID
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
    [CoreDataService verifyThreadSafetyForContext:context];
    
    return [context objectWithID:objectID];
}

+ (NSSet *)context:(NSManagedObjectContext *)context fetchEntitiesByObjectIdSet:(NSSet *)objectIdSet
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
    NSMutableSet *entities = [NSMutableSet setWithCapacity:[objectIdSet count]];
    for( NSManagedObjectID *objectId in [objectIdSet allObjects]) {
        id object = [CoreDataService context:context fetchEntityByObjectID:objectId];
        [entities addObject:object];
    }
    return entities;
}

+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntitiesByObjectIdArray:(NSArray *)objectIdArray
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
    NSMutableArray *entities = [NSMutableArray arrayWithCapacity:[objectIdArray count]];
    for( NSManagedObjectID *objectId in objectIdArray) {
        id object = [CoreDataService context:context fetchEntityByObjectID:objectId];
        [entities addObject:object];
    }
    return entities;
}

+ (void)context:(NSManagedObjectContext *)context refreshObject:(NSManagedObject *)objectToRefresh mergeChanges:(BOOL)mergeChanges
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
    [CoreDataService verifyThreadSafetyForContext:context];
    
    [context refreshObject:objectToRefresh mergeChanges:mergeChanges];
}

+ (BOOL)save
{
    NSManagedObjectContext *context = [GlobalManagedObjectContext sharedService].globalContext;
    return [self contextSave:context requireMainThread:YES];
}

+ (BOOL)contextSave:(NSManagedObjectContext *)context requireMainThread:(BOOL)shouldRequireMainThread
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
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

+ (void)context:(NSManagedObjectContext *)context deleteEntitiesForClass:(Class)classToDelete
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
    [CoreDataService verifyThreadSafetyForContext:context];
    
    NSArray *objectsToDelete = [CoreDataService context:context fetchEntities:NSStringFromClass(classToDelete) fetchPropertyValues:NO];
    [CoreDataService context:context deleteObjects:[NSSet setWithArray:objectsToDelete]];
}

+ (void)context:(NSManagedObjectContext *)context deleteObjects:(NSSet *)objects
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
    [CoreDataService verifyThreadSafetyForContext:context];
    
    for (NSManagedObject *object in objects) {
        [CoreDataService context:context deleteObject:object];
    }
}

+ (void)context:(NSManagedObjectContext *)context deleteObject:(id)object
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
    [CoreDataService verifyThreadSafetyForContext:context];
    
    [context deleteObject:object];
}

+ (void)context:(NSManagedObjectContext *)context deleteEntities:(NSString *)entityName withPredicate:(NSPredicate *)predicate
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
    NSArray *entitiesToDelete = [CoreDataService context:context fetchEntities:entityName withPredicate:predicate];
    [CoreDataService context:context deleteObjects:[NSSet setWithArray:entitiesToDelete]];
}

+ (NSArray *)arrayOfObjectIDsFromObjects:(NSArray *)managedObjectArray
{
    NSMutableArray *objectIDs = [NSMutableArray arrayWithCapacity:[managedObjectArray count]];
    for( NSManagedObject *object in managedObjectArray )
        [objectIDs addObject:object.objectID];
    
    return objectIDs;
}

+ (NSArray *)arrayOfPropertiesWithName:(NSString *)propertyName fromObjects:(NSArray *)managedObjects skipNulls:(BOOL)skipNulls
{
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

#pragma mark - Counting

+ (NSUInteger)context:(NSManagedObjectContext *)context countEntities:(NSString *)entityName
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
    [CoreDataService verifyThreadSafetyForContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
    
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    if( error )
        NSLog(@"CoreData Error (in countEntities:) ++ %@",[error localizedDescription]);
    
    return count;
}

+ (NSUInteger)context:(NSManagedObjectContext *)context countEntities:(NSString *)entityName
        withPredicate:(NSPredicate *)thePredicate
{
    context = [CoreDataService useGlobalContextIfNeeded:context];
    [CoreDataService verifyThreadSafetyForContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
    
    [request setPredicate:thePredicate];
    
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    if( error )
        NSLog(@"CoreData Error (in countEntities:) ++ %@",[error localizedDescription]);
    
    return count;
}

#pragma mark -

+ (void)verifyThreadSafetyForContext:(NSManagedObjectContext *)context
{
    if( [NSThread isMainThread] == NO && context == [GlobalManagedObjectContext sharedService].globalContext ) {
        NSLog(@"ERROR: you are accessing the global context from a background thread!!!!!!!!!!!!!!!");
        abort();
    }
}

+ (NSManagedObjectContext *)useGlobalContextIfNeeded:(NSManagedObjectContext *)context
{
    if (context == nil)
        return [GlobalManagedObjectContext sharedService].globalContext;

    return context;
}

+ (NSString *)classNameFromObject:(id)object
{
    NSString *className = NSStringFromClass([object class]);
    if ([className containsString:@"."]) {
        NSArray *parts = [className componentsSeparatedByString:@"."];
        if (parts.count > 1) {
            className = parts[1];
        }
    }
    return className;
}
@end

@implementation NSManagedObject(CoreDataService)
+ (id)makeEntityWithContext:(NSManagedObjectContext *)context
{
    return [CoreDataService context:context makeObjectWithEntityName:[CoreDataService classNameFromObject:self]];
}

+ (id)fetchEntityByAttribute:(NSString *)attribute value:(id)value context:(NSManagedObjectContext *)context
{
    return [CoreDataService context:context fetchEntity:[CoreDataService classNameFromObject:self]
                        byAttribute:attribute withValue:value];
}

+ (NSArray *)fetchEntitiesWithPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)context
{
    return [CoreDataService context:context fetchEntities:[CoreDataService classNameFromObject:self]
                      withPredicate:predicate];
}

+ (id)fetchEntityByObjectID:(NSManagedObjectID *)objectID context:(NSManagedObjectContext *)context
{
    id object = [CoreDataService context:context fetchEntityByObjectID:objectID];
    if ([object isKindOfClass:[self class]] == NO) {
        NSLog(@"ERROR: incorrect type fetched: %@ for %@", NSStringFromClass([object class]), [CoreDataService classNameFromObject:self]);
        abort();
    }
    return object;
}

+ (NSSet *)fetchEntitiesByObjectIdSet:(NSSet *)objectIdSet context:(NSManagedObjectContext *)context
{
    return [CoreDataService context:context fetchEntitiesByObjectIdSet:objectIdSet];
}

+ (NSArray *)fetchEntitiesByObjectIdArray:(NSArray *)objectIdArray context:(NSManagedObjectContext *)context
{
    return [CoreDataService context:context fetchEntitiesByObjectIdArray:objectIdArray];
}

+ (NSArray *)fetchAllEntitiesWithContext:(NSManagedObjectContext *)context
{
    return [CoreDataService context:context fetchEntities:[CoreDataService classNameFromObject:self]];
}

- (void)deleteEntity
{
    [CoreDataService context:self.managedObjectContext deleteObject:self];
}

+ (void)deleteEntitiesWithPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)context
{
    [CoreDataService context:context deleteEntities:[CoreDataService classNameFromObject:self] withPredicate:predicate];
}


- (void)refreshEntityAndMergeChanges:(BOOL)mergeChanges
{
    [CoreDataService context:self.managedObjectContext refreshObject:self mergeChanges:mergeChanges];
}

#pragma mark - Counting
+ (NSUInteger)countAllEntities:(NSManagedObjectContext *)context
{
    return [CoreDataService context:context countEntities:[CoreDataService classNameFromObject:self]];
}

+ (NSUInteger)countEntitiesWithPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)context
{
    return [CoreDataService context:context countEntities:[CoreDataService classNameFromObject:self] withPredicate:predicate];
}
#pragma mark -

@end