//
//  ErrorUtil.m
//
//  Created by Ben Ford on 8/30/10.
//

#import "ErrorUtil.h"
#import <CoreData/CoreData.h>

@implementation ErrorUtil

+ (NSString *)stringFromMultipleErrors:(NSError *)error {
    NSArray *detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    
    unsigned numErrors = [detailedErrors count];
    NSMutableString *errorString = [NSMutableString stringWithFormat:@"%u validation errors have occurred", numErrors];
    
    if (numErrors > 3) {
        numErrors = 3;
        [errorString appendFormat:@".\nThe first 3 are:\n"];
    } else {
        [errorString appendFormat:@":\n"];
    }
    
    for (NSUInteger i = 0; i < numErrors; i++) {
        [errorString appendFormat:@"%@\n",
        [[detailedErrors objectAtIndex:i] localizedDescription]];
    }
    return errorString;
}
@end
