//
//  SudokuBoard.m
//  Sudoku
//
//  Created by Oleg Langer on 20.01.14.
//  Copyright (c) 2014 Oleg Langer. All rights reserved.
//

#import "SudokuBoard.h"
#import "Field.h"

#define SudokuErrorDomain @"com.oleglanger.sudoku"

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

- (id)initWith2DArray:(NSArray *)fieldsArray error:(NSError **)error {
    if (![self validate2DArray:fieldsArray error:error]) {
        return nil;
    }
    if (self = [self initWithSquareSize:fieldsArray.count]) {
        if (![self fillFieldsWith2DArray:fieldsArray error:error]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)validate2DArray:(NSArray *)fieldsArray error:(NSError **)error {
    NSUInteger count = fieldsArray.count;
    for (id obj in fieldsArray) {
        if (![obj isKindOfClass:[NSArray class]] || ![obj count] == count) {
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"The fields array is not a 2-dimensional square array"};
            *error = [NSError errorWithDomain:SudokuErrorDomain code:2 userInfo:errorDict];
            return NO;
        }
    }
    return YES;
}

- (BOOL)addNumber:(NSNumber *)number toField:(NSUInteger)fIndex {
    if ([self fieldIndexOutsideBounds:fIndex]
            ||![self isEditableFieldAtIndex:fIndex]
            || [self numberOutsideBoardBounds:number]) {
        return NO;
    }
    else if (number.integerValue == 0) {
        return [self deleteNumberInField:fIndex];
    }
    if (![self numberExists:number inField:fIndex]) {
        [self writeNumber:number toField:fIndex];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)addNumber:(NSNumber *)number toRow:(NSUInteger)row column:(NSUInteger)col {
    if ([self rowOrColumnOutsideBoardBounds:row col:col]
            || [self numberOutsideBoardBounds:number]
            || ![self isEditableFieldInRow:row col:col])
        return NO;
    else if (number.integerValue == 0) {
        return [self deleteNumberInRow:row column:col];
    }
    else if (![self numberExists:number inRow:row column:col]) {
        [self writeNumber:number toRow:row column:col];
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

- (BOOL)isEditableFieldInRow:(NSUInteger)row col:(NSUInteger)col {
    NSUInteger index = row* self.squareSize +col;
    return [self isEditableFieldAtIndex:index];
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

- (BOOL) numberExists: (NSNumber *)number inField: (NSUInteger) fIndex {
    NSUInteger row = fIndex / self.squareSize;
    NSUInteger column = fIndex % self.squareSize;
    return [self numberExists:number inRow:row column:column];
}

- (BOOL) numberExists: (NSNumber*)number inRow: (NSUInteger) row column: (NSUInteger)col {
    // indices of fields in this row
    NSIndexSet *fieldsIndexesInRow = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(row*self.squareSize, self.squareSize)];
    // indices of fields in this column
    NSMutableIndexSet *fieldsIndexesInCol = [NSMutableIndexSet new];
    for (int colIndex = col; colIndex < self.squareSize*self.squareSize; colIndex += self.squareSize) {
        [fieldsIndexesInCol addIndex:colIndex];
    }
    NSMutableIndexSet *fieldsIndexesToCheck = fieldsIndexesInCol;
    [fieldsIndexesToCheck addIndexes:fieldsIndexesInRow];
    
    NSArray *fieldsToCheck = [self.fields objectsAtIndexes:fieldsIndexesToCheck];
    NSArray *fieldsNumbers = [fieldsToCheck valueForKeyPath:@"number"];
    return [fieldsNumbers containsObject:number];
}

- (BOOL) deleteNumberInRow: (NSUInteger) row column: (NSUInteger)col {
    return [self deleteNumberInField:row*self.squareSize+col];
}

- (BOOL) deleteNumberInField: (NSUInteger) fIndex {
    Field *f = self.fields[fIndex];
    f.number = @0;
    return  YES;
}

- (BOOL)fillFieldsWith2DArray:(NSArray *)fieldsArray error:(NSError **)error {
    for (int row = 0; row < self.squareSize; row ++) {
        for (int col = 0; col < self.squareSize; col ++) {
            NSNumber *nr = fieldsArray[row][col];
            if (nr.integerValue != 0 && [self numberExists:nr inRow:row column:col]) {
                NSDictionary *errorDetail = @{NSLocalizedDescriptionKey : @"the field matrix is corrupt"};
                *error = [NSError errorWithDomain:SudokuErrorDomain code:1 userInfo:errorDetail];
                return NO;
            }
            else {
                Field *f = self.fields[row* self.squareSize +col];
                f.number = nr;
                f.editable = (nr.integerValue == 0);
            }
        }
    }
    return YES;
}

#pragma mark - Bounds Validation

- (BOOL)numberOutsideBoardBounds:(NSNumber *)number {
    return number.integerValue > self.squareSize || number.integerValue < 0;
}

- (BOOL)rowOrColumnOutsideBoardBounds:(NSUInteger)row col:(NSUInteger)col {
    return row >= self.squareSize || col >= self.squareSize
            || row < 0 || col < 0;
}

- (BOOL)fieldIndexOutsideBounds:(NSUInteger)fIndex {
    return fIndex >= self.squareSize * self.squareSize || fIndex < 0;
}

@end
