//
//  Field.h
//  Sudoku
//
//  Created by Oleg Langer on 23.01.14.
//  Copyright (c) 2014 Oleg Langer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Field : NSObject

@property (strong, nonatomic) NSNumber *number;
@property (nonatomic, getter = isEditable) BOOL editable;

@end
