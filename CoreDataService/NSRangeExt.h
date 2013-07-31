//
//  NSRangeExt.h
//  MakeItReal
//
//  Created by Ben Ford on 10/3/12.
//  Copyright (c) 2012 Ben Fprd. All rights reserved.
//

#import <Foundation/Foundation.h>

NSRange Ext_NSRangeFromArrayIndexes(NSUInteger startIndex, NSUInteger endIndex);

NSUInteger Ext_NSRangeGetArrayIndex(NSRange range);

NSRange Ext_NSRangeUnion(NSRange firstRange, NSRange secondRange);

BOOL Ext_NSRangeValidForArray(NSRange range, NSArray *array);

BOOL EXT_NSRangeIsZero(NSRange range);

NSRange Ext_NSRangeIntersectionFromArrays(NSArray *firstArray, NSArray *secondArray);

NSArray *Ext_NSArrayBeforeRange(NSArray *array, NSRange range);
NSArray *Ext_NSArrayAfterRange(NSArray *array, NSRange range);