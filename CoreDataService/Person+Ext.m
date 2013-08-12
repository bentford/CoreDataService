//
//  Person+Ext.m
//  CoreDataService
//
//  Created by Ben Ford on 8/8/13.
//  Copyright (c) 2013 Ben Ford. All rights reserved.
//

#import "Person+Ext.h"

@implementation Person(Ext)
- (NSString *)description
{
    return [NSString stringWithFormat:@"Person: %@", self.name];
}
@end
