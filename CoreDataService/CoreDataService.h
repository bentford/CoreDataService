//
//  GenericDataService.h
//
//  Created by Ben Ford on 6/3/10.
//
// This abstracts the most common CoreData operations into easy to use methods
// It will logs errors on the console
// 
// Provides easy way to use in background thread

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
@end

@interface NSManagedObject(CoreDataService)
+ (id)makeEntityWithContext:(NSManagedObjectContext *)context;

+ (NSArray *)fetchAllEntitiesWithContext:(NSManagedObjectContext *)context;
+ (id)fetchEntityByAttribute:(NSString *)attribute value:(NSString *)value context:(NSManagedObjectContext *)context;
+ (NSArray *)fetchEntitiesWithPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)context;
+ (id)fetchEntityByObjectID:(NSManagedObjectID *)objectID context:(NSManagedObjectContext *)context;
+ (NSSet *)fetchEntitiesByObjectIdSet:(NSSet *)objectIdSet context:(NSManagedObjectContext *)context;
+ (NSArray *)fetchEntitiesByObjectIdArray:(NSArray *)objectIdArray context:(NSManagedObjectContext *)context;


+ (void)deleteEntitiesWithPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)context;
- (void)deleteEntity;

- (void)refreshEntityAndMergeChanges:(BOOL)mergeChanges;
@end