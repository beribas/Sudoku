//
//  ViewController.m
//  Sudoku
//
//  Created by Oleg Langer on 21.01.14.
//  Copyright (c) 2014 Oleg Langer. All rights reserved.
//

#import "ViewController.h"
#import "FieldCell.h"
#import "SudokuBoard.h"

static CGFloat spacing = 2.0f;

@interface ViewController ()

@property (nonatomic) CGPoint initalCenterOfCurrentlyDraggedButton;
@property (nonatomic) NSUInteger squareSize;
@property (strong, nonatomic) SudokuBoard *board;
@property (nonatomic) NSIndexPath *indexPathForLastCellMarkedEditing;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSArray *fieldsArray = @[ @[@1, @2, @3, @4, @5],
//                              @[@0, @1, @0, @3, @4],
//                              @[@4, @5, @1, @2, @3],
//                              @[@3, @4, @5, @1, @2],
//                              @[@2, @3, @4, @5, @0]];
//    
//    self.board = [[SudokuBoard alloc] initWith2DArray:fieldsArray];
    
    NSArray *fieldsArray =  @[ @[@0, @0, @0, @2, @6, @0, @7, @0, @1],
                               @[@6, @8, @0, @0, @7, @0, @0, @9, @0],
                               @[@1, @9, @0, @0, @0, @4, @5, @0, @0],
                               @[@8, @2, @0, @1, @0, @0, @0, @4, @0],
                               @[@0, @0, @4, @6, @0, @2, @9, @0, @0],
                               @[@0, @5, @0, @0, @0, @3, @0, @2, @8],
                               @[@0, @0, @9, @3, @0, @0, @0, @7, @4],
                               @[@0, @4, @0, @0, @5, @0, @0, @3, @6],
                               @[@7, @0, @3, @0, @1, @8, @0, @0, @0]];
    
    if (!(self.board = [[SudokuBoard alloc] initWith2DArray:fieldsArray])) {
        [NSException raise:@"Could not initialize the board" format:@"the fieldsArray could be corrupt: \n%@", fieldsArray];
    }
    self.squareSize = fieldsArray.count;
    CGFloat buttonHeight = 30;    
    CGFloat y = CGRectGetMaxY(self.view.frame) - 150;
    CGFloat x = 0;
    for (int i = 1; i <= self.squareSize; i ++) {
        CGRect frame = CGRectMake(x, y, buttonHeight, buttonHeight);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        button.tag = i;
        [button addTarget:self action:@selector(buttonTouchBegan:withEvent:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(buttonDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [button addTarget:self action:@selector(buttonTouchEnded:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(buttonTouchEnded:withEvent:) forControlEvents:UIControlEventTouchCancel];
        
        [self.view addSubview:button];
        CGFloat innerSpace = CGRectGetWidth(self.view.frame) / self.squareSize;
        x += innerSpace;
    }
    
    [self.eraseButton addTarget:self action:@selector(buttonTouchBegan:withEvent:) forControlEvents:UIControlEventTouchDown];
    [self.eraseButton addTarget:self action:@selector(buttonDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self.eraseButton addTarget:self action:@selector(buttonTouchEnded:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.eraseButton addTarget:self action:@selector(buttonTouchEnded:withEvent:) forControlEvents:UIControlEventTouchCancel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
        return self.squareSize * self.squareSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"FieldCellID";
    FieldCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    NSUInteger row = (NSUInteger) (indexPath.row / self.squareSize);
    NSUInteger col = (NSUInteger) (indexPath.row % self.squareSize);
    NSNumber *nrInRow = [self.board numberInRow:row column:col];
    if (nrInRow && nrInRow.integerValue != 0)
        cell.label.text = nrInRow.stringValue;
    else
        cell.label.text = @"";
    if ([indexPath isEqual:self.indexPathForLastCellMarkedEditing]) {
        cell.backgroundColor = [UIColor yellowColor];
    }
    else {
        cell.backgroundColor = [UIColor orangeColor];
    }
    return cell;
}

- (IBAction) buttonTouchBegan:(id)sender withEvent:(UIEvent *)event {
    UIButton *button = sender;
    self.initalCenterOfCurrentlyDraggedButton = button.center;
    [button.superview bringSubviewToFront:button];
}

- (IBAction) buttonDragged:(id) sender withEvent:(UIEvent *) event
{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    UIControl *control = sender;
    control.center = point;
    
    CGPoint pointInCollectionView = [[[event allTouches] anyObject] locationInView:self.collectionView];
    NSIndexPath *ip = [self.collectionView indexPathForItemAtPoint:pointInCollectionView];
    if (ip && [self.board isEditableFieldAtIndex:ip.row]) {
        // a workaround for unmark cells if dragging too fast
        NSMutableArray *indexPathsToReload = [@[ip] mutableCopy];
        if (self.indexPathForLastCellMarkedEditing && ![self.indexPathForLastCellMarkedEditing isEqual:ip]) {
            // if one cell was already marked, we have to unmark it
            [indexPathsToReload addObject:self.indexPathForLastCellMarkedEditing];
        }
        self.indexPathForLastCellMarkedEditing = ip;
        [self.collectionView reloadItemsAtIndexPaths:indexPathsToReload];
    }
    else {
        [self unmarkCellsIfNecessary];
    }
}

- (IBAction) buttonTouchEnded:(id) sender withEvent:(UIEvent *) event
{
    UIButton *but = sender;
    NSNumber *numberToAdd = @(but.tag);
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.collectionView];
    NSIndexPath *ip = [self.collectionView indexPathForItemAtPoint:point];
    if (ip && [self.board addNumber:numberToAdd toField:ip.row]) {
        [self.collectionView reloadItemsAtIndexPaths:@[ip]];
        but.center = self.initalCenterOfCurrentlyDraggedButton;
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            but.center = self.initalCenterOfCurrentlyDraggedButton;
        }];
    }
    [self unmarkCellsIfNecessary];
}


#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(self.view.frame) - (self.squareSize+1) * spacing;
    CGFloat cellWidth = width / self.squareSize;
    return CGSizeMake(cellWidth, cellWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return spacing;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return spacing;
}

#pragma mark - Private

- (void) unmarkCellsIfNecessary {
    if (self.indexPathForLastCellMarkedEditing) {
        NSArray *cellsToReload = @[self.indexPathForLastCellMarkedEditing];
        self.indexPathForLastCellMarkedEditing = nil;
        [self.collectionView reloadItemsAtIndexPaths:cellsToReload];
    }
}


@end
