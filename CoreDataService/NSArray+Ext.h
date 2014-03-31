//
//  NSArray+Ext.h
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


#import <Foundation/Foundation.h>

@interface NSArray(Ext)
- (id)extObjectAtIndexOrNil:(NSUInteger)theIndex;
- (id)extFirstObject;

- (NSUInteger)extLastIndex;

- (NSNumber *)extNumberAtIndexOrZero:(NSUInteger)theIndex;

- (id)extObjectPrecedingObject:(id)object;

- (NSArray *)extMapObjectsUsingBlock:(id (^)(id object))block;
- (NSArray *)extMapObjectsUsingSelector:(SEL)selector;
- (NSArray *)extMapObjectsUsingKeyPath:(NSString *)keyPath;

- (NSArray *)extFilteredArrayUsingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;

- (NSRange)extRangeOfObjectsWithKeyPath:(NSString *)keyPath matchingTwoValues:(NSArray *)values;

- (NSSet *)extSet;
- (NSMutableSet *)extMutableSet;


- (NSArray *)extSortArrayByKey:(NSString *)key ascending:(BOOL)ascending;
- (NSArray *)extSortArrayByKeys:(NSArray *)keys ascending:(BOOL)ascending;
@end
