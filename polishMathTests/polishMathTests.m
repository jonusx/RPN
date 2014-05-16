//
//  polishMathTests.m
//  polishMathTests
//
//  Created by mathew cruz on 5/15/14.
//  Copyright (c) 2014 mathew cruz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MRCPolishCalculator.h"

@interface polishMathTests : XCTestCase

@end

@implementation polishMathTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddition
{
    NSError *error;
    NSString *testString = @"1 2 +";
    NSNumber *result = [MRCPolishCalculator calculateFromString:testString error:&error];
    XCTAssertEqual([result integerValue], 3, @"%@ should be 3, is %@", testString, result);
    XCTAssertNil(error, @"Error should be nil, is %@", error);
}

- (void)testDivision
{
    NSError *error;
    NSString *testString = @"4 2 /";
    NSNumber *result = [MRCPolishCalculator calculateFromString:testString error:&error];
    XCTAssertEqual([result integerValue], 2, @"%@ should be 2, is %@", testString, result);
    XCTAssertNil(error, @"Error should be nil, is %@", error);
}

- (void)testMultiplication
{
    NSError *error;
    NSString *testString = @"25 10 *";
    NSNumber *result = [MRCPolishCalculator calculateFromString:testString error:&error];
    XCTAssertEqual([result integerValue], 250, @"%@ should be 250, is %@", testString, result);
    XCTAssertNil(error, @"Error should be nil, is %@", error);
}

- (void)testSubtraction
{
    NSError *error;
    NSString *testString = @"13 4 -";
    NSNumber *result = [MRCPolishCalculator calculateFromString:testString error:&error];
    XCTAssertEqual([result integerValue], 9, @"%@ should be 9, is %@", testString, result);
    XCTAssertNil(error, @"Error should be nil, is %@", error);
}

- (void)testMixed
{
    NSError *error;
    NSString *testString = @"3 4 + 5 6 + *";
    NSNumber *result = [MRCPolishCalculator calculateFromString:testString error:&error];
    XCTAssertEqual([result integerValue], 77, @"%@ should be 77, is %@", testString, result);
    XCTAssertNil(error, @"Error should be nil, is %@", error);
}

- (void)testMixedPost
{
    NSError *error;
    NSString *testString = @"2 3 4 + *";
    NSNumber *result = [MRCPolishCalculator calculateFromString:testString error:&error];
    XCTAssertEqual([result integerValue], 14, @"%@ should be 14, is %@", testString, result);
    XCTAssertNil(error, @"Error should be nil, is %@", error);
}

- (void)testNotEnoughArgs
{
    NSError *error;
    NSString *testString = @"1 +";
    NSNumber *result = [MRCPolishCalculator calculateFromString:testString error:&error];
    XCTAssertNil(result, @"result should be nil, is %@", result);
    XCTAssertNotNil(error, @"Error should not be nil, is %@", error);
    XCTAssertEqual(error.code, 1001, @"Improper error code");
}

- (void)testTooManyArgs
{
    NSError *error;
    NSString *testString = @"1 6 8 +";
    NSNumber *result = [MRCPolishCalculator calculateFromString:testString error:&error];
    XCTAssertNil(result, @"result should be nil, is %@", result);
    XCTAssertNotNil(error, @"Error should not be nil, is %@", error);
    XCTAssertEqual(error.code, 1002, @"Improper error code");
}

- (void)testImproperArgs
{
    NSError *error;
    NSString *testString = @"a b +";
    NSNumber *result = [MRCPolishCalculator calculateFromString:testString error:&error];
    XCTAssertNil(result, @"result should be nil, is %@", result);
    XCTAssertNotNil(error, @"Error should not be nil, is %@", error);
    XCTAssertEqual(error.code, 1000, @"Improper error code");
}

@end
