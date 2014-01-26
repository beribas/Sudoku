//
//  SudokuBoard.h
//  Sudoku
//
//  Created by Oleg Langer on 20.01.14.
//  Copyright (c) 2014 Oleg Langer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SudokuBoard : NSObject

- (id) initWithSquareSize: (NSUInteger) squareSize;

- (id)initWith2DArray:(NSArray *)fieldsArray error:(NSError **)error;

- (BOOL) addNumber:(NSNumber *)number toRow:(NSUInteger)row column: (NSUInteger) col;
- (BOOL) addNumber:(NSNumber *)number toField:(NSUInteger) fIndex;

- (NSNumber *) numberInRow:(NSUInteger) row column: (NSUInteger) col;

- (NSNumber *)numberInField:(NSUInteger)fIndex;

- (BOOL) isEditableFieldAtIndex: (NSUInteger) fIndex;
@end
