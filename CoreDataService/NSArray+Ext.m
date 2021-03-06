//
//  NSArray+Ext.m
//
//  Created by Ben Ford on 10/27/11.
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


#import "NSArray+Ext.h"
#import "NSRangeExt.h"

@implementation NSArray(Ext)
- (id)extObjectAtIndexOrNil:(NSUInteger)theIndex {
    // NSUInteger rolls around to zero when at NSUIntegerMax
    // and it's impossible to have a NSUIntegerMax index because the count would be higher than NSUIntegerMax
    if( theIndex != NSUIntegerMax && theIndex + 1 <= [self count])
        return [self objectAtIndex:theIndex];
    else
        return nil;
}

- (id)extFirstObject {
    return [self extObjectAtIndexOrNil:0];
}

- (NSNumber *)extNumberAtIndexOrZero:(NSUInteger)theIndex
{
	id number = [self extObjectAtIndexOrNil:theIndex];
    
	if ( [number isKindOfClass:[NSNumber class]] )
		return number;
	
	if ( [number isKindOfClass:[NSString class]] ) 
		return [NSNumber numberWithFloat:[number floatValue]];
	
	return [NSNumber numberWithInt:0];
}

- (NSUInteger)extLastIndex
{
    if ([self count] == 0)
        return 0;
    else
        return [self count] - 1;
}

- (id)extObjectPrecedingObject:(id)object
{
    NSUInteger index = [self indexOfObject:object];
    if (index == NSNotFound || index == 0)
        return nil;
    
    return [self objectAtIndex:index-1];
}

- (NSArray *)extMapObjectsUsingBlock:(id (^)(id object))block
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:self.count];
    for (id object in self) {
        id fetchedObject = block(object);
        if (fetchedObject != nil)
            [results addObject:fetchedObject];
    }
    
    return [NSArray arrayWithArray:results];
}

- (NSArray *)extMapObjectsUsingSelector:(SEL)selector
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:self.count];
    for (id object in self) {
        // used to suppress use of performSelector:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id fetchedObject = [object performSelector:selector];
#pragma clang diagnostic pop
        
        if (fetchedObject != nil)
            [results addObject:fetchedObject];
    }
    return [NSArray arrayWithArray:results];
}

- (NSArray *)extMapObjectsUsingKeyPath:(NSString *)keyPath
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:self.count];
    for (id object in self) {
        id fetchedObject = [object valueForKeyPath:keyPath];
        if (fetchedObject != nil)
            [results addObject:fetchedObject];
    }
    return [NSArray arrayWithArray:results];
}

- (NSArray *)extFilteredArrayUsingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    NSIndexSet *filteredIndexes = [self indexesOfObjectsPassingTest:predicate];
    return [self objectsAtIndexes:filteredIndexes];
}

- (NSRange)extRangeOfObjectsWithKeyPath:(NSString *)keyPath matchingTwoValues:(NSArray *)values
{
    NSAssert([values count] == 2, @"values array must have only two elements");
    id firstValue = values[0];
    id secondValue = values[1];
    
    NSUInteger startIndex = 0;
    NSUInteger endIndex = 0;
    NSUInteger index = 0;
    for (id object in self) {
        id thisValue = [object valueForKeyPath:keyPath];
        BOOL isString = [thisValue isKindOfClass:[NSString class]];
        
        // check for string equality
        if (isString && [firstValue isEqualToString:thisValue])
            startIndex = index;
        if (isString && [secondValue isEqualToString:thisValue])
            endIndex = index;
        
        // check for object equality
        if (!isString && [firstValue isEqual:thisValue])
            startIndex = index;
        if (!isString && [secondValue isEqual:thisValue])
            endIndex = index;
        
        index++;
    }
    
    return Ext_NSRangeFromArrayIndexes(startIndex, endIndex);
}

- (NSSet *)extSet
{
    return [NSSet setWithArray:self];
}

- (NSMutableSet *)extMutableSet
{
    return [NSMutableSet setWithArray:self];
}

- (NSArray *)extSortArrayByKey:(NSString *)key ascending:(BOOL)ascending
{
    return [self sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:key ascending:ascending]]];
}

- (NSArray *)extSortArrayByKeys:(NSArray *)keys ascending:(BOOL)ascending
{
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
    for (NSString *key in keys)
        [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:ascending]];
    
    return [self sortedArrayUsingDescriptors:sortDescriptors];
}
@end
