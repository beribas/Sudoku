//
//  SudokuBoard.m
//  Sudoku
//
//  Created by Oleg Langer on 20.01.14.
//  Copyright (c) 2014 Oleg Langer. All rights reserved.
//

#import "SudokuBoard.h"
#import "Field.h"

@interface SudokuBoard ()

@property (strong, nonatomic) NSArray *fields;
@property NSUInteger squareSize;

@end

@implementation SudokuBoard

- (id) initWithSquareSize: (NSUInteger) squareSize {
    if (self = [super init]) {
        self.squareSize = squareSize;

        NSMutableArray *fieldsMutable = [NSMutableArray arrayWithCapacity:self.squareSize * self.squareSize];
        for (int i = 0; i < self.squareSize * self.squareSize; i ++) {
            [fieldsMutable addObject:[[Field alloc] init]];
        }
        self.fields = fieldsMutable;
    }
    return self;
}

- (instancetype)initWith2DArray:(NSArray *)fieldsArray {
    NSUInteger count = fieldsArray.count;
    for (id obj in fieldsArray) {
        NSCParameterAssert([obj isKindOfClass:[NSArray class]]);
        NSCParameterAssert([obj count] == count);
    }
    if (self = [self initWithSquareSize:count]) {
        for (int row = 0; row < self.squareSize; row ++) {
            for (int col = 0; col < self.squareSize; col ++) {
                NSNumber *nr = fieldsArray[row][col];
                if (nr.integerValue != 0 && [self numberExists:nr inRow:row column:col]) {
                    return nil;
                }
                else {
                    Field *f = self.fields[row*self.squareSize +col];
                    f.number = nr;
                    f.editable = (nr.integerValue == 0);
                }
            }
        }
    }
    return self;
}

- (BOOL)addNumber:(NSNumber *)number toRow:(NSUInteger)row column:(NSUInteger)col {
    if (row >= self.squareSize || col >= self.squareSize) {
        return NO;
    }
    else if (number.integerValue > self.squareSize) {
        return NO;
    }
    else if (![self.fields[row*self.squareSize+col] isEditable]) {
        return NO;
    }
    if (number.integerValue == 0) {
        NSUInteger fieldIndex = row*self.squareSize+col;
        return [self deleteNumberInField:fieldIndex];
    }
    
    if (![self numberExists:number inRow:row column:col]) {
        [self writeNumber:number toRow:row column:col];
        return YES;
    }
    else {
        return NO;
    }

}

- (BOOL)addNumber:(NSNumber *)number toField:(NSUInteger)fIndex {
    if (fIndex >= self.squareSize*self.squareSize) {
        return NO;
    }
    if (![self.fields[fIndex] isEditable]) {
        return NO;
    }
    if (number.integerValue == 0) {
        return [self deleteNumberInField:fIndex];
    }
    NSUInteger row = fIndex / self.squareSize;
    NSUInteger column = fIndex % self.squareSize;
    if (![self numberExists:number inRow:row column:column]) {
        [self writeNumber:number toField:fIndex];
        return YES;
    }
    else {
        return NO;
    }
}

- (NSNumber *)numberInRow:(NSUInteger)row column:(NSUInteger)col {
    NSUInteger fieldIndex = row * self.squareSize + col;
    return [self numberInField:fieldIndex];
}

- (NSNumber *)numberInField:(NSUInteger) fieldKey {
    return [self.fields[fieldKey] number];
}

- (BOOL)isEditableFieldAtIndex:(NSUInteger)fIndex {
    return [self.fields[fIndex] isEditable];
}

#pragma mark - Private

- (void) writeNumber: (NSNumber*)nr toRow: (NSUInteger)row column: (NSUInteger)col {
    NSUInteger fieldIndex = row*self.squareSize+col;
    [self writeNumber:nr toField:fieldIndex];
}

- (void) writeNumber: (NSNumber*)nr toField: (NSUInteger) fIndex {
    Field *f = self.fields[fIndex];
    f.number = nr;
}

- (BOOL) numberExists: (NSNumber*)number inRow: (NSUInteger) row column: (NSUInteger)col {
    // indices of fields in this row
    NSIndexSet *fieldsIndexesInRow = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(row*self.squareSize, self.squareSize)];
    // indices of fields in this column
    NSMutableIndexSet *fieldsIndexesInCol = [NSMutableIndexSet new];
    for (int ci = col; ci < self.squareSize*self.squareSize; ci += self.squareSize) {
        [fieldsIndexesInCol addIndex:ci];
    }
    
    NSMutableIndexSet *fieldsIndexesToCheck = fieldsIndexesInCol;
    [fieldsIndexesToCheck addIndexes:fieldsIndexesInRow];
    
    NSArray *fieldsToCheck = [self.fields objectsAtIndexes:fieldsIndexesToCheck];
    NSArray *fieldsNumbers = [fieldsToCheck valueForKeyPath:@"number"];
    return [fieldsNumbers containsObject:number];
}

- (BOOL) deleteNumberInField: (NSUInteger) fIndex {
    Field *f = self.fields[fIndex];
    f.number = @0;
    return  YES;
}

@end
