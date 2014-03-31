//
//  NSRangeExt.m
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


#import "NSRangeExt.h"

NSRange Ext_NSRangeFromArrayIndexes(NSUInteger startIndex, NSUInteger endIndex) {
    return NSMakeRange(startIndex, endIndex-startIndex+1);
}

NSUInteger Ext_NSRangeGetArrayIndex(NSRange range) {
    return range.location+range.length-1;
}

NSRange Ext_NSRangeUnion(NSRange firstRange, NSRange secondRange) {
    
    NSUInteger fromIndex = MIN(firstRange.location, secondRange.location);
    NSUInteger toIndex = MAX(Ext_NSRangeGetArrayIndex(firstRange),Ext_NSRangeGetArrayIndex(secondRange));

    return Ext_NSRangeFromArrayIndexes(fromIndex, toIndex);
}

BOOL Ext_NSRangeValidForArray(NSRange range, NSArray *array) {
    NSUInteger endIndex = Ext_NSRangeGetArrayIndex(range);
    return endIndex <= [array count]-1;
}

BOOL EXT_NSRangeIsZero(NSRange range) {
    return range.location == 0 && range.length == 0;
        
}

NSRange Ext_NSRangeIntersectionFromArrays(NSArray *firstArray, NSArray *secondArray) {
    // handle empty arrays
    if( [firstArray count] == 0 || [secondArray count] == 0 )
        return NSMakeRange(0, 0);
    
    // force smallest array to be first
    NSArray *temp;
    if( [firstArray count] > [secondArray count] ) {
        temp = secondArray;
        secondArray = firstArray;
        firstArray = temp;
    }
    
    id firstObject = [firstArray objectAtIndex:0];
    id lastObject = [firstArray lastObject];
    
    NSUInteger indexOfFirstObject = [secondArray indexOfObject:firstObject];
    NSUInteger indexOfLastObject = [secondArray indexOfObject:lastObject];
    
    return Ext_NSRangeFromArrayIndexes(indexOfFirstObject, indexOfLastObject);
}

NSArray *Ext_NSArrayBeforeRange(NSArray *array, NSRange range) {
    NSRange beforeRange = Ext_NSRangeFromArrayIndexes(0, range.location);
    return [array subarrayWithRange:beforeRange];
}

NSArray *Ext_NSArrayAfterRange(NSArray *array, NSRange range) {
    NSUInteger startIndex = Ext_NSRangeGetArrayIndex(range);
    NSUInteger endIndex = [array count]-1;
    NSRange afterRange = Ext_NSRangeFromArrayIndexes(startIndex, endIndex);
    return [array subarrayWithRange:afterRange];
}


