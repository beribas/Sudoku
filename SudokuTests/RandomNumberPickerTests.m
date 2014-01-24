//
//  RandomNumberPickerTests.m
//  Sudoku
//
//  Created by Oleg Langer on 20.01.14.
//  Copyright (c) 2014 Oleg Langer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RandomNumberPicker.h"

@interface RandomNumberPickerTests : XCTestCase

@end

@implementation RandomNumberPickerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void) testCanPickNumbers {
    RandomNumberPicker *rnp = [RandomNumberPicker pickerWithMaxNumber:9];
    int counter = 256;
    NSMutableArray *numbers = [NSMutableArray new];
    while (counter --) {
        NSNumber *randomNumber = [rnp pickNumberDistinct:NO];
        XCTAssertTrue(randomNumber.integerValue <= 256, @"");
        [numbers addObject:randomNumber];
    }
    // number should appear more then once because distinct is NO
    __block NSNumber *nr = [numbers firstObject];
    NSInteger occurrencesOfSameNumber = [[numbers indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        return [nr isEqualToNumber:obj];
    }] count];
    XCTAssertTrue(occurrencesOfSameNumber > 1,);
}

- (void)testCanPickUniqueNumbers
{
    RandomNumberPicker *rnp = [RandomNumberPicker pickerWithMaxNumber:9];
    int counter = 9;
    NSMutableArray *numbers = [NSMutableArray new];
    while (counter --) {
        NSNumber *randomNumber = [rnp pickNumberDistinct:YES];
        XCTAssertTrue(randomNumber.integerValue <= 9, @"");
        XCTAssertFalse([numbers containsObject:randomNumber], @"");
        [numbers addObject:randomNumber];

        XCTAssertTrue([numbers containsObject:randomNumber], @"");
    }
    NSLog(@"random numbers given from picker:\n%@", numbers);
}


@end
