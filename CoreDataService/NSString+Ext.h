//
//  NSString+Ext.h
//
//  Created by Ben Ford on 10/27/11.
//  Copyright (c) 2011 Ben Ford All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NSStringExtElipseTypeNone = 0,
    NSStringExtElipseTypeEnd,
    NSStringExtElipseTypeMiddle,
    NSStringExtElipseTypeFront,
} NSStringExtElipseType;

@interface NSString(Ext)

+ (NSString *)extEmptyStringIfNilOrBlank:(NSString *)inputString;

+ (BOOL)extContainsText:(NSString *)inputString;

- (CGRect)extToCGRect;

- (BOOL)extBeginsWithString:(NSString *)beginsWith;
- (BOOL)extContainsString:(NSString *)containsString;

- (NSString *)extTrimmedText;
- (NSString *)extLastCharactersOfString:(NSUInteger)count;

- (NSString *)extExtensionWithDot;
- (NSString *)extLastPathComponentWithoutExtension;
- (NSString *)extPathWithoutExtension;

- (NSString *)extStringWithMaxLength:(NSUInteger)maxLength withElipses:(NSStringExtElipseType)elipseType;

+ (NSString *)extStringByConcatenatingArray:(NSArray *)arrayOfObjects;
+ (NSString *)extStringByConcatenatingArray:(NSArray *)arrayOfObjects withSeperator:(NSString *)separator;
+ (NSString *)extStringByConcatenatingArray:(NSArray *)arrayOfObjects withSeperator:(NSString *)separator prefixString:(NSString *)prefix postFixString:(NSString *)postFix;
@end
