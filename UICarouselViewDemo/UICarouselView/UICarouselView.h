//
//  UICarouselView.h
//  UICarouselViewDemo
//
//  Created by Igor Starzhinskiy on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICarouselViewCell.h"

@class UICarouselView;

typedef enum {
	UICarouselViewColumnAnimationNone,
	UICarouselViewColumnAnimationFade//,
	//UICarouselViewColumnAnimationTop,
	//UICarouselViewColumnAnimationBottom
} UICarouselViewColumnAnimation;

typedef enum {
    UICarouselViewScrollPositionNone,
    UICarouselViewScrollPositionLeft,
    UICarouselViewScrollPositionMiddle,
    UICarouselViewScrollPositionRight
} UICarouselViewScrollPosition;


@protocol UICarouselViewDelegate <NSObject, UIScrollViewDelegate>
@optional

- (NSUInteger)carouselView:(UICarouselView *)carouselView willSelectCellAtIndex:(NSUInteger)index; //should retung NSNotFound if selection don't wanted, otherwise return index of cell that should be selected
- (void)carouselView:(UICarouselView *)carouselView didSelectCellAtIndex:(NSInteger)index;

- (NSUInteger)carouselView:(UICarouselView *)carouselView willDeselectCellAtIndex:(NSUInteger)index; //should retung NSNotFound if deselection don't wanted, otherwise return index of cell that should be deselected
- (void)carouselView:(UICarouselView *)carouselView didDeselectCellAtIndex:(NSInteger)index;

@end

@protocol UICarouselViewDataSource <NSObject>

- (NSUInteger)numberOfColumnsForCarouselView:(UICarouselView *)carouselView;
- (UICarouselViewCell *)carouselView:(UICarouselView *)carouselView cellForColumnAtIndex:(NSInteger)index;

@end



@interface UICarouselView : UIScrollView {
    
    NSUInteger numberOfColumns;
    
    NSRange allocatedCellsRange;    
    NSMutableArray *allocatedCells;
    
    NSMutableSet *reusablePool;
    
}

@property (nonatomic, assign) IBOutlet id<UICarouselViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id<UICarouselViewDelegate> delegate;
@property (nonatomic) CGFloat columnWidth;
@property (nonatomic, readonly) NSInteger indexOfSelectedCell;

//temp public accessors for test
@property (nonatomic, retain) NSMutableArray *allocatedCells;
@property (nonatomic, retain) NSMutableSet *reusablePool;
@property (nonatomic, readonly) NSUInteger numberOfColumns;

- (void)releaseCells; //release cells from reusablePool & allocatedCells

- (UICarouselViewCell *)dequeueReusableCell;

- (void)insertColumnsAtIndexes:(NSArray *)indexes withColumnAnimation:(UICarouselViewColumnAnimation)animation;
- (void)deleteColumnsAtIndexes:(NSArray *)indexes withColumnAnimation:(UICarouselViewColumnAnimation)animation;

- (NSArray *)visibleCells;
- (UICarouselViewCell *)visibleCellForIndex:(NSInteger)index; //return nil if cell is not visible
- (NSUInteger)indexForCell:(UICarouselViewCell *)cell;


- (void)scrollToCellAtIndex:(NSUInteger)index atScrollPosition:(UICarouselViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (void)selectCellAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)deselectCellAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)selectCellAtIndex:(NSUInteger)index animated:(BOOL)animated scrollPosition:(UICarouselViewScrollPosition)scrollPosition;


- (void)reloadData;


@end
