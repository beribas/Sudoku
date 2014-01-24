//
//  RandomNumberPicker.m
//  Sudoku
//
//  Created by Oleg Langer on 20.01.14.
//  Copyright (c) 2014 Oleg Langer. All rights reserved.
//

#import "RandomNumberPicker.h"

@interface RandomNumberPicker ()
@property NSUInteger maxNumber;
@property (strong, nonatomic) NSMutableArray *pickedNumbers;

@end

@implementation RandomNumberPicker

+ (id)pickerWithMaxNumber:(NSUInteger)maxNumber {
    RandomNumberPicker *picker = [RandomNumberPicker new];
    if (picker) {
        picker.maxNumber = maxNumber;
        picker.pickedNumbers = [NSMutableArray arrayWithCapacity:maxNumber];
    }
    return picker;
}

- (NSNumber *) pickNumberDistinct:(BOOL)distinct {
    int randomNumber = arc4random() % self.maxNumber + 1;
    if (distinct) {
        while ([self.pickedNumbers containsObject:@(randomNumber)]) {
            randomNumber = arc4random() % self.maxNumber + 1;
        }
        [self.pickedNumbers addObject:@(randomNumber)];
    }
    return @(randomNumber);
}

@end
