//
//  CoreDataService.h
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
// 
// Provides easy way to use in background thread
//
// This abstracts the most common CoreData operations into easy to use methods
// It will logs errors on the console

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kShouldAbortOnCoreDataThreadError YES

@interface CoreDataService : NSObject

+ (NSArray *)context:(NSManagedObjectContext *)context executeFetchRequest:(NSFetchRequest *)request;

+ (void)context:(NSManagedObjectContext *)context deleteObject:(id)object;
+ (void)context:(NSManagedObjectContext *)context deleteObjects:(NSSet *)objects;
+ (void)context:(NSManagedObjectContext *)context deleteEntitiesForClass:(Class)classToDelete;
+ (void)context:(NSManagedObjectContext *)context deleteEntities:(NSString *)entityName withPredicate:(NSPredicate *)predicate;

+ (BOOL)save;
+ (BOOL)contextSave:(NSManagedObjectContext *)context requireMainThread:(BOOL)shouldRequireMainThread;

+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntities:(NSString *)entityName;
+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntities:(NSString *)entityName fetchPropertyValues:(BOOL)fetchPropertyValues;
+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntities:(NSString *)entityName withPredicate:(NSPredicate *)thePredicate;
+ (id)context:(NSManagedObjectContext *)context makeObjectWithEntityName:(NSString *)name;

+ (id)context:(NSManagedObjectContext *)context fetchEntity:(NSString *)entityName byAttribute:(NSString *)attribute withValue:(id)value;
+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntities:(NSString *)entityName byAttribute:(NSString *)attribute withValues:(NSArray *)values;

+ (id)context:(NSManagedObjectContext *)context fetchEntity:(NSString *)entityName withPredicate:(NSPredicate *)thePredicate;
+ (id)context:(NSManagedObjectContext *)context fetchEntityByObjectID:(NSManagedObjectID *)objectID;
+ (NSSet *)context:(NSManagedObjectContext *)context fetchEntitiesByObjectIdSet:(NSSet *)objectIdSet;
+ (NSArray *)context:(NSManagedObjectContext *)context fetchEntitiesByObjectIdArray:(NSArray *)objectIdArray;
+ (void)context:(NSManagedObjectContext *)context refreshObject:(NSManagedObject *)objectToRefresh mergeChanges:(BOOL)mergeChanges;

#pragma mark Utilities
+ (NSArray *)arrayOfObjectIDsFromObjects:(NSArray *)managedObjectArray;
+ (NSArray *)arrayOfPropertiesWithName:(NSString *)propertyName fromObjects:(NSArray *)managedObjects skipNulls:(BOOL)skipNulls;
#pragma mark -

#pragma mark Counting
+ (NSUInteger)context:(NSManagedObjectContext *)context countEntities:(NSString *)entityName;
+ (NSUInteger)context:(NSManagedObjectContext *)context countEntities:(NSString *)entityName
       withPredicate:(NSPredicate *)thePredicate;
#pragma mark -
@end

@interface NSManagedObject(CoreDataService)
+ (id)makeEntityWithContext:(NSManagedObjectContext *)context;

+ (NSArray *)fetchAllEntitiesWithContext:(NSManagedObjectContext *)context;
+ (id)fetchEntityByAttribute:(NSString *)attribute value:(id)value context:(NSManagedObjectContext *)context;
+ (NSArray *)fetchEntitiesWithPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)context;
+ (id)fetchEntityByObjectID:(NSManagedObjectID *)objectID context:(NSManagedObjectContext *)context;
+ (NSSet *)fetchEntitiesByObjectIdSet:(NSSet *)objectIdSet context:(NSManagedObjectContext *)context;
+ (NSArray *)fetchEntitiesByObjectIdArray:(NSArray *)objectIdArray context:(NSManagedObjectContext *)context;


+ (void)deleteEntitiesWithPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)context;
- (void)deleteEntity;

- (void)refreshEntityAndMergeChanges:(BOOL)mergeChanges;

#pragma mark - Counting
+ (NSUInteger)countAllEntities:(NSManagedObjectContext *)context;
+ (NSUInteger)countEntitiesWithPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)context;
#pragma mark -
@end