//
//  NSString+Ext.m
//
//  Created by Ben Ford on 10/27/11.
//  Copyright (c) 2011 Ben Ford All rights reserved.
//

#import "NSString+Ext.h"
#import "NSArray+Ext.h"
#import <QuartzCore/QuartzCore.h>

@implementation NSString(Ext)

+ (NSString *)extEmptyStringIfNilOrBlank:(NSString *)inputString {
    BOOL isBlank = [[inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0;
    if( inputString == nil || isBlank == YES )
        return @"";
    else
        return inputString;
}

+ (BOOL)extContainsText:(NSString *)inputString {
    return inputString != nil && [[inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0;
}

- (CGRect)extToCGRect {
	NSArray * arr = [self componentsSeparatedByString:@","];
	
	return CGRectMake([[arr extNumberAtIndexOrZero:0] floatValue], [[arr extNumberAtIndexOrZero:1] floatValue], [[arr extNumberAtIndexOrZero:2] floatValue],[[arr extNumberAtIndexOrZero:3] floatValue]);
}

- (BOOL)extBeginsWithString:(NSString *)beginsWith {
    return [self rangeOfString:beginsWith].location == 0;
}

- (BOOL)extContainsString:(NSString *)containsString
{
    return [self rangeOfString:containsString].location != NSNotFound;
}

- (NSString *)extExtensionWithDot {
    return [NSString stringWithFormat:@".%@",[self pathExtension]];    
}

- (NSString *)extLastPathComponentWithoutExtension {    
    return [[self lastPathComponent] stringByReplacingOccurrencesOfString:[self extExtensionWithDot] withString:@""];
}

- (NSString *)extPathWithoutExtension {
    return [self stringByReplacingOccurrencesOfString:[self extExtensionWithDot] withString:@""];
}

- (NSString *)extStringWithMaxLength:(NSUInteger)maxLength withElipses:(NSStringExtElipseType)elipseType {
    if( [self length] <= maxLength )
        return self;
    
    
    if( elipseType == NSStringExtElipseTypeNone )
        return [self substringToIndex:maxLength];

    if( elipseType == NSStringExtElipseTypeFront ) {
        NSUInteger lastHalf = [self length]-maxLength;
        return [NSString stringWithFormat:@"%@%@", @"...", [self substringFromIndex:lastHalf]];
    }
    
    if( elipseType == NSStringExtElipseTypeMiddle ) {
        NSUInteger firstHalf = maxLength / 2;
        NSUInteger lastHalf = [self length]-firstHalf;
        return [NSString stringWithFormat:@"%@%@%@", [self substringToIndex:firstHalf], @"...", [self substringFromIndex:lastHalf]];
    }
    
    if( elipseType == NSStringExtElipseTypeEnd )
        return [NSString stringWithFormat:@"%@%@", [self substringToIndex:maxLength], @"..."];

    return [self substringToIndex:maxLength];
}

+ (NSString *)extStringByConcatenatingArray:(NSArray *)arrayOfObjects
{
    return [NSString extStringByConcatenatingArray:arrayOfObjects withSeperator:@","];
}

+ (NSString *)extStringByConcatenatingArray:(NSArray *)arrayOfObjects withSeperator:(NSString *)separator
{
    return [NSString extStringByConcatenatingArray:arrayOfObjects withSeperator:separator prefixString:@"[" postFixString:@"]"];
}

+ (NSString *)extStringByConcatenatingArray:(NSArray *)arrayOfObjects withSeperator:(NSString *)separator prefixString:(NSString *)prefix postFixString:(NSString *)postFix
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendString:prefix];
    
    for (id part in arrayOfObjects)
        [result appendFormat:@"%@%@", part, separator];
    
    // delete trailing seperator if needed
    if ([arrayOfObjects count] > 0) {
        NSRange range = NSMakeRange(result.length-separator.length, separator.length);
        [result deleteCharactersInRange:range];
    }
    
    [result appendString:postFix];
    
    return result;
}

- (NSString *)extLastCharactersOfString:(NSUInteger)count
{
    if ([self length] >= count)
        return [self substringFromIndex:[self length]-count];
    else
        return self;
}

- (NSString *)extTrimmedText
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end
