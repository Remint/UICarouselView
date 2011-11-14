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


@protocol UICarouselViewDelegate <NSObject, UIScrollViewDelegate>
@optional
- (void)carouselView:(UICarouselView *)carouselView didSelectCellAtIndex:(NSInteger)index;
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

- (UICarouselViewCell *)dequeueReusableCell;

- (void)insertColumnsAtIndexes:(NSArray *)indexes withColumnAnimation:(UICarouselViewColumnAnimation)animation;
- (void)deleteColumnsAtIndexes:(NSArray *)indexes withColumnAnimation:(UICarouselViewColumnAnimation)animation;

- (NSArray *)visibleCells;
- (UICarouselViewCell *)visibleCellForIndex:(NSInteger)index; //return nil if cell is not visible
- (NSUInteger)indexForCell:(UICarouselViewCell *)cell;



- (void)reloadData;

@end