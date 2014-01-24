//
//  ViewController.h
//  Sudoku
//
//  Created by Oleg Langer on 21.01.14.
//  Copyright (c) 2014 Oleg Langer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIButton *eraseButton;
@end
