//
//  NSRangeExt.h
//  MakeItReal
//
//  Created by Ben Ford on 10/3/12.
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
// This abstracts the most common CoreData operations into easy to use methods
// It will logs errors on the console

#import <Foundation/Foundation.h>

NSRange Ext_NSRangeFromArrayIndexes(NSUInteger startIndex, NSUInteger endIndex);

NSUInteger Ext_NSRangeGetArrayIndex(NSRange range);

NSRange Ext_NSRangeUnion(NSRange firstRange, NSRange secondRange);

BOOL Ext_NSRangeValidForArray(NSRange range, NSArray *array);

BOOL EXT_NSRangeIsZero(NSRange range);

NSRange Ext_NSRangeIntersectionFromArrays(NSArray *firstArray, NSArray *secondArray);

NSArray *Ext_NSArrayBeforeRange(NSArray *array, NSRange range);
NSArray *Ext_NSArrayAfterRange(NSArray *array, NSRange range);