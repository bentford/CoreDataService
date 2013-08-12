//
//  Person.h
//  CoreDataService
//
//  Created by Ben Ford on 8/8/13.
//  Copyright (c) 2013 Ben Ford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * age;

@end
