//
//  SudokuTests.m
//  SudokuTests
//
//  Created by Oleg Langer on 13.01.14.
//  Copyright (c) 2014 Oleg Langer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SudokuBoard.h"
#import "RandomNumberPicker.h"

static const NSUInteger testSquareSize = 5;

struct field {
    int row;
    int col;
};


@interface SudokuTests : XCTestCase
@property (strong, nonatomic) SudokuBoard *board;
@property (strong, nonatomic) RandomNumberPicker *fieldIndexPicker;
@property (strong, nonatomic) RandomNumberPicker *numberPicker;
@end

@implementation SudokuTests

- (void)setUp
{
    [super setUp];
    self.board = [[SudokuBoard alloc] initWithSquareSize:testSquareSize];
    self.numberPicker = [RandomNumberPicker pickerWithMaxNumber:testSquareSize];
    self.fieldIndexPicker = [RandomNumberPicker pickerWithMaxNumber:testSquareSize * testSquareSize];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testcreateBoard
{
    XCTAssertNotNil(self.board, @"board should not be nil");
}

- (void) testBoardRangeViolation {
    XCTAssertFalse([self.board addNumber:@4 toRow:testSquareSize column:0], @"the max row number is squareSize-1");
    XCTAssertFalse([self.board addNumber:@4 toRow:0 column:testSquareSize], @"the max column number is squareSize-1");
    XCTAssertTrue([self.board addNumber:@(testSquareSize) toRow:0 column:0]);
    XCTAssertFalse([self.board addNumber:@(testSquareSize+1) toRow:0 column:0]);
}

- (void) testAddNumberToField {
    NSNumber *nr = @3;
    [self.board addNumber:nr toRow:0 column:0];
    XCTAssertEqualObjects(nr, [self.board numberInRow:0 column:0]);
    XCTAssertEqualObjects(nr, [self.board numberInField:0]);
}

- (void) testAddNumberToField2 {
    NSNumber *nr = @2;
    XCTAssertTrue([self.board addNumber:nr toField:20]);
    XCTAssertEqualObjects(nr, [self.board numberInField:20]);
}


- (void) testCanNotAddTheSameNumberToTheSameFieldTwice {
    [self.board addNumber:@3 toRow:2 column:2];
    XCTAssertFalse([self.board addNumber:@3 toRow:2 column:2]);
}

- (void) testCanChangeNumberInField {
    [self.board addNumber:@3 toRow:2 column:2];
    XCTAssertTrue([self.board addNumber:@2 toRow:2 column:2]);
}

- (void) testRemoveNumberInFieldByAddingZero {
    [self.board addNumber:@3 toRow:0 column:0];
    [self.board addNumber:@4 toRow:0 column:3];
    [self.board addNumber:@2 toRow:1 column:3];
    XCTAssertTrue([[self.board numberInRow:0 column:0] isEqualToNumber:@3]);
    XCTAssertTrue([self.board addNumber:@0 toRow:0 column:0]);
    XCTAssertTrue([[self.board numberInRow:0 column:0] isEqualToNumber:@0]);
    XCTAssertTrue([self.board addNumber:@0 toRow:0 column:3]);
    XCTAssertTrue([[self.board numberInRow:0 column:3] isEqualToNumber:@0]);
    XCTAssertTrue([self.board addNumber:@0 toRow:1 column:3]);
    XCTAssertTrue([[self.board numberInRow:1 column:3] isEqualToNumber:@0]);
}

- (void) testCanFindTheRightNumberInOneMissingFieldInRow {
    self.board = [[SudokuBoard alloc] initWithSquareSize:9];
    for (int i = 0; i < 8; i ++) {
        XCTAssertTrue([self.board addNumber:@(i+1) toRow:0 column:i]);
    }
    for (int i = 1; i <=9; i ++) {
        if (i != 9) {
            XCTAssertFalse([self.board addNumber:@(i) toRow:1 column:9]);
        }
        else {
            XCTAssertTrue([self.board addNumber:@(i) toRow:0 column:8]);
        }
    }
}


- (void) testValidateSudokuExample {
// this example is taken from http://www.mathematische-basteleien.de/sudoku.htm
    
    int fields[5][5] = {    { 1, 2, 3, 4, 5 },
                            { 5, 1, 2, 3, 4 },
                            { 4, 5, 1, 2, 3 },
                            { 3, 4, 5, 1, 2 },
                            { 2, 3, 4, 5, 1 }};
    
    for (int row = 0; row < 5; row ++) {
        for (int col = 0; col < 5; col ++) {
            NSNumber *numberToAdd = @(fields[row][col]);
            XCTAssertTrue([self.board addNumber:numberToAdd toRow:row column:col]);
        }
    }
}

- (void) testFindOneMissingNumber {
    // zeroes are used for missed numbers
    int fields[5][5] = {    { 1, 0, 3, 4, 5 },
                            { 5, 1, 2, 3, 4 },
                            { 4, 5, 1, 2, 3 },
                            { 3, 4, 5, 1, 2 },
                            { 2, 3, 4, 5, 1 }};
    
    struct field missingField;
    
    for (int row = 0; row < 5; row ++) {
        for (int col = 0; col < 5; col ++) {
            NSNumber *numberToAdd = @(fields[row][col]);
            if ([numberToAdd isEqualToNumber:@0]) {
                missingField.row = row;
                missingField.col = col;
                continue;
            }
            XCTAssertTrue([self.board addNumber:numberToAdd toRow:row column:col]);
        }
    }
    NSNumber *randomNr = [self.numberPicker pickNumberDistinct:YES];
    while (![self.board addNumber:randomNr toRow:missingField.row column:missingField.col]) {
        randomNr = [self.numberPicker pickNumberDistinct:YES];
    }
    XCTAssertTrue([randomNr isEqualToNumber:@2]);
}

- (void) testFindMissingNumbers {
    // zeroes are used for missed numbers
    int fields[5][5] = {    { 1, 0, 3, 4, 5 },
                            { 5, 1, 2, 3, 4 },
                            { 4, 5, 1, 2, 3 },
                            { 3, 4, 0, 1, 2 },
                            { 2, 3, 4, 5, 1 }};
    
    struct field missingFields[2];
    int structStepper = 0;
    
    for (int row = 0; row < 5; row ++) {
        for (int col = 0; col < 5; col ++) {
            NSNumber *numberToAdd = @(fields[row][col]);
            if ([numberToAdd isEqualToNumber:@0]) {
                missingFields[structStepper].row = row;
                missingFields[structStepper].col = col;
                structStepper ++;
                continue;
            }
            XCTAssertTrue([self.board addNumber:numberToAdd toRow:row column:col]);
        }
    }
    
    NSNumber *randomNr = [self.numberPicker pickNumberDistinct:YES];
    while (![self.board addNumber:randomNr toRow:missingFields[0].row column:missingFields[0].col]) {
        randomNr = [self.numberPicker pickNumberDistinct:YES];
    }
    XCTAssertTrue([randomNr isEqualToNumber:@2]);
    self.numberPicker = [RandomNumberPicker pickerWithMaxNumber:5];
    
    while (![self.board addNumber:randomNr toRow:missingFields[1].row column:missingFields[1].col]) {
        randomNr = [self.numberPicker pickNumberDistinct:YES];
    }
    XCTAssertTrue([randomNr isEqualToNumber:@5]);
}

@end
