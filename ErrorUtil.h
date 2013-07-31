//
//  ErrorUtil.h
//
//  Created by Ben Ford on 8/30/10.
//

#import <Foundation/Foundation.h>


@interface ErrorUtil : NSObject {

}
+ (NSString *)stringFromMultipleErrors:(NSError *)error;
@end
