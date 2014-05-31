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
    MRCOperatorDivision,
    MRCOperatorOpenParan = 100,
    MRCOperatorCloseParen
};

@interface MRCPolishNode : NSObject
@property (nonatomic, strong) MRCPolishNode *rightNode;
@property (nonatomic, strong) MRCPolishNode *leftNode;
@property (nonatomic, strong) NSString *value;
@end

@interface MRCPolishCalculator ()
@property (nonatomic, strong) NSMutableArray *numberResultsStack;
@end

@implementation MRCPolishNode
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
    if (!string || [string length] > 1) {
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
        case '(':
            return MRCOperatorOpenParan;
            break;
        case ')':
            return MRCOperatorCloseParen;
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

+ (NSNumber *)calculateInfix:(NSString *)string {
    MRCPolishCalculator *calculator = [MRCPolishCalculator new];
    NSArray *stackify = [[calculator convertInfixToRPN:string] componentsSeparatedByString:@" "];
    return [calculator calculate:stackify error:nil];
}

- (NSString *)convertInfixToRPN:(NSString *)string {
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray *operatorStack = [NSMutableArray new];
    NSMutableString *numberString = [NSMutableString string];
    BOOL __block lastWasOperator = NO;
    //    @"50*(10-(5+6)) + (60*(10-2))"
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        
        MRCOperator operator = [self operatorFromString:substring];
        if (operator == MRCOperatorNotOperator) {
            //operand, write to string
            if (lastWasOperator == YES) {
                [numberString appendString:@" "];
            }
            [numberString appendString:substring];
            lastWasOperator = NO;
        }
        else
        {
            
            //check precedence. if higher, put on stack else write top stack value to string
            MRCOperator topStackOperator = [self operatorFromString:[operatorStack lastObject]];
            
            //operator is lower than current stack start popping
            while ((operator == MRCOperatorCloseParen && topStackOperator != MRCOperatorOpenParan) || (topStackOperator != MRCOperatorNotOperator && (operator == MRCOperatorAddition || operator == MRCOperatorSubtraction) && (topStackOperator == MRCOperatorMultiplication || topStackOperator == MRCOperatorDivision))) {
                
                [numberString appendString:@" "];
                [numberString appendString:[operatorStack lastObject]];
                [operatorStack removeLastObject];
                topStackOperator = [self operatorFromString:[operatorStack lastObject]];
                if (topStackOperator == MRCOperatorOpenParan && operator == MRCOperatorCloseParen) {
                    [operatorStack removeLastObject];
                }
            }
            //Put operator on stack
            if (operator != MRCOperatorCloseParen) {
                [operatorStack addObject:substring];
            }
            lastWasOperator = YES;
        }
    }];
    
    while ([operatorStack count] != 0) {
        [numberString appendString:@" "];
        [numberString appendString:[operatorStack lastObject]];
        [operatorStack removeLastObject];
    }
    return numberString;
}

@end
