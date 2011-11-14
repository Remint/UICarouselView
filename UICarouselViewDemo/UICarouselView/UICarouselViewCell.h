//
//  UICarouselViewCell.h
//  UICarouselViewDemo
//
//  Created by Igor Starzhinskiy on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICarouselViewCell : UIView {
    
    UIView *selectedBackgroundView;  
    
    BOOL selected;
}

@property (nonatomic, retain) UIView *selectedBackgroundView;
@property (nonatomic, getter=isSelected) BOOL selected;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

- (void)prepareForReuse;

@end
