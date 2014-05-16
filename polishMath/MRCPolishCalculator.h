//
//  MRCPolishCalculator.h
//  polishMath
//
//  Created by mathew cruz on 5/15/14.
//  Copyright (c) 2014 mathew cruz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRCPolishCalculator : NSObject
+ (NSNumber *)calculateFromString:(NSString *)stringForCalculation error:(NSError * __autoreleasing *)error;
@end
