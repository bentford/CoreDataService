//
//  Persistance.h
//
//  Created by Ben Ford on 6/3/10.
//  Copyright 2010 Ben Ford.  All rights reserved
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface GlobalManagedObjectContext : NSObject {
    NSManagedObjectContext *globalContext;
}
+ (GlobalManagedObjectContext*)sharedService;

@property (nonatomic, readonly) NSManagedObjectContext *globalContext;

- (void)reinitializeGlobalContext;
@end
