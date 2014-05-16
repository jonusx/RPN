//
//  MRCPolishCalculator.m
//  polishMath
//
//  Created by mathew cruz on 5/15/14.
//  Copyright (c) 2014 mathew cruz. All rights reserved.
//

#import "MRCPolishCalculator.h"

typedef NS_ENUM(NSInteger, MRCOperator) {
    MRCOperatorNotOperator = -1,
    MRCOperatorAddition = 0,
    MRCOperatorSubtraction,
    MRCOperatorMultiplication,
    MRCOperatorDivision
};

@interface MRCPolishCalculator ()
@property (nonatomic, strong) NSMutableArray *numberResultsStack;
@end


@implementation MRCPolishCalculator

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _numberResultsStack = [NSMutableArray new];
    return self;
}

+ (NSNumber *)calculateFromString:(NSString *)stringForCalculation error:(NSError * __autoreleasing *)error {

    //Check for invalid characters
    if (![self isValidInstruction:stringForCalculation]) {
        *error = [[NSError alloc] initWithDomain:@"com.cruz.math" code:1000 userInfo:@{NSLocalizedDescriptionKey : @"(invalid number)"}];
        return nil;
    }
    //Break apart the string
    NSArray *stackify = [stringForCalculation componentsSeparatedByString:@" "];
    MRCPolishCalculator *calculator = [MRCPolishCalculator new];
    return [calculator calculate:stackify error:error];;
}

+ (BOOL)isValidInstruction:(NSString *)instruction {
    static NSRegularExpression *regex;
    static dispatch_once_t dispatchToken;
    dispatch_once(&dispatchToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z!@#$%^&();|<>\"',?\\\\]" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    return !([regex numberOfMatchesInString:instruction options:0 range:NSMakeRange(0, [instruction length])]);
}

- (NSNumber *)calculate:(NSArray *)numbers error:(NSError * __autoreleasing *)error {
    for (NSString *value in numbers) {
        //Determine if the value is an operator or operand
        MRCOperator operator = [self operatorFromString:value];
        if (operator == MRCOperatorNotOperator) { //operand, push onto stack
            [self pushValue:value];
        }
        else //operator
        {
            //Have to at least have two numbers to work with
            if ([self.numberResultsStack count] < 2) {
                *error = [[NSError alloc] initWithDomain:@"com.cruz.math" code:1001 userInfo:@{NSLocalizedDescriptionKey : @"(not enough arguments)"}];
                return nil;
            }
            [self performOperator:operator];
        }
    }
    
    if ([self.numberResultsStack count] > 1) { // Too many values
        *error = [[NSError alloc] initWithDomain:@"com.cruz.math" code:1002 userInfo:@{NSLocalizedDescriptionKey : @"(too many arguments)"}];
        return nil;
    }
    return @([[self popValue] integerValue]);
}


- (MRCOperator)operatorFromString:(NSString *)string {
    if ([string length] > 1) {
        return MRCOperatorNotOperator;
    }
    const char *stringAsChar = [string cStringUsingEncoding:[NSString defaultCStringEncoding]];
    switch (stringAsChar[0]) {
        case '+':
            return MRCOperatorAddition;
            break;
        case '-':
            return MRCOperatorSubtraction;
            break;
        case '/':
            return MRCOperatorDivision;
            break;
        case '*':
            return MRCOperatorMultiplication;
            break;
        default:
            break;
    }
    return MRCOperatorNotOperator;
}

- (void)performOperator:(MRCOperator)operator {
    NSInteger firstNumber = [[self popValue] integerValue];
    NSInteger previousNumber = [[self popValue] integerValue];
    
    NSInteger result = 0;
    switch (operator) {
        case MRCOperatorAddition:
            result = previousNumber + firstNumber;
            break;
        case MRCOperatorSubtraction:
            result = previousNumber - firstNumber;
            break;
        case MRCOperatorMultiplication:
            result = previousNumber * firstNumber;
            break;
        case MRCOperatorDivision:
            result = previousNumber / firstNumber;
            break;
        default:
            break;
    }
    [self pushValue:[NSString stringWithFormat:@"%ld", (long)result]];
}

- (void)pushValue:(id)value {
    [self.numberResultsStack addObject:value];
}

- (id)popValue {
    id value = [self.numberResultsStack lastObject];
    [self.numberResultsStack removeLastObject];
    return value;
}

@end
