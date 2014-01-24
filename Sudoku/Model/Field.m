//
//  Field.m
//  Sudoku
//
//  Created by Oleg Langer on 23.01.14.
//  Copyright (c) 2014 Oleg Langer. All rights reserved.
//

#import "Field.h"

@implementation Field

- (id) init {
    if (self = [super init]) {
        self.editable = YES;
    }
    return self;
}

@end
