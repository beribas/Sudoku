//
//  RandomNumberPicker.h
//  Sudoku
//
//  Created by Oleg Langer on 20.01.14.
//  Copyright (c) 2014 Oleg Langer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomNumberPicker : NSObject

+ (id) pickerWithMaxNumber: (NSUInteger) maxNumber;

- (NSNumber *) pickNumberDistinct: (BOOL) distinct;

@end
