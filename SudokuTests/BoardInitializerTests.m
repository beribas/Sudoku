//
//  BoardInitializerTests.m
//  Sudoku
//
//  Created by Oleg Langer on 23.01.14.
//  Copyright (c) 2014 Oleg Langer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SudokuBoard.h"

@interface BoardInitializerTests : XCTestCase
@property (strong, nonatomic) SudokuBoard *board;

@end

@implementation BoardInitializerTests

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

- (void)testCreateEmptyBoard
{
    XCTAssertNotNil(self.board = [[SudokuBoard alloc] initWithSquareSize:5]);
    for (int fIndex = 0; fIndex < 25; fIndex ++) {
        XCTAssertTrue([self.board isEditableFieldAtIndex:fIndex]);
    }
}

- (void) testCreatePreFilledBoard {
    
    NSArray *fieldsArray = @[ @[@1, @2, @3, @4, @5],
                              @[@5, @1, @2, @3, @4],
                              @[@4, @5, @1, @2, @3],
                              @[@3, @4, @5, @1, @2],
                              @[@2, @3, @4, @5, @1]];
    NSError *error = nil;
    self.board = [[SudokuBoard alloc] initWith2DArray:fieldsArray error:&error ];
    XCTAssertNotNil(self.board);
    XCTAssertTrue([[self.board numberInRow:2 column:3] isEqualToNumber:@2]);
    XCTAssertTrue([[self.board numberInRow:0 column:0] isEqualToNumber:@1]);
    XCTAssertFalse([[self.board numberInRow:4 column:0] isEqualToNumber:@1]);
    for (int fIndex = 0; fIndex < 25; fIndex ++) {
        XCTAssertFalse([self.board isEditableFieldAtIndex:fIndex]);
    }}

- (void) testCreatePreFilledBoardWithCorruptValues {
    NSArray *fieldsArray = @[ @[@1, @3, @2, @4, @5],
                              @[@5, @1, @2, @3, @4],
                              @[@4, @5, @1, @2, @3],
                              @[@3, @4, @5, @1, @2],
                              @[@2, @3, @4, @5, @1]];
    NSError *error = nil;
    self.board = [[SudokuBoard alloc] initWith2DArray:fieldsArray error:&error ];
    XCTAssertNil(self.board);
}

- (void) testCreateBoardWithFieldsLeftOut {
    NSArray *fieldsArray = @[ @[@1, @2, @3, @4, @5],
                              @[@0, @1, @0, @3, @4],
                              @[@4, @5, @1, @2, @3],
                              @[@3, @4, @5, @1, @2],
                              @[@2, @3, @4, @5, @0]];
    NSError *error = nil;
    self.board = [[SudokuBoard alloc] initWith2DArray:fieldsArray error:&error ];
    XCTAssertNotNil(self.board);
    XCTAssertTrue([self.board isEditableFieldAtIndex:24]);
    XCTAssertTrue([self.board isEditableFieldAtIndex:5]);
    XCTAssertTrue([self.board isEditableFieldAtIndex:7]);
    XCTAssertFalse([self.board isEditableFieldAtIndex:1]);
    XCTAssertFalse([self.board isEditableFieldAtIndex:20]);
    XCTAssertFalse([self.board isEditableFieldAtIndex:4]);
    XCTAssertFalse([self.board addNumber:@0 toField:1]);
    XCTAssertTrue([self.board addNumber:@0 toField:5]);
}

- (void) testCreateBoard9x9 {
    NSArray *fieldsArray =  @[ @[@0, @0, @0, @2, @6, @0, @7, @0, @1],
                               @[@6, @8, @0, @0, @7, @0, @0, @9, @0],
                               @[@1, @9, @0, @0, @0, @4, @5, @0, @0],
                               @[@8, @2, @0, @1, @0, @0, @0, @4, @0],
                               @[@0, @0, @4, @6, @0, @2, @9, @0, @0],
                               @[@0, @5, @0, @0, @0, @3, @0, @2, @8],
                               @[@0, @0, @9, @3, @0, @0, @0, @7, @4],
                               @[@0, @4, @0, @0, @5, @0, @0, @3, @6],
                               @[@7, @0, @3, @0, @1, @8, @0, @0, @0]];
    NSError *error = nil;
    self.board = [[SudokuBoard alloc] initWith2DArray:fieldsArray error:&error];
    XCTAssertNotNil(self.board);
}

@end
