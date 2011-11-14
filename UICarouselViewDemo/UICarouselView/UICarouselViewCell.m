//
//  UICarouselViewCell.m
//  UICarouselViewDemo
//
//  Created by Igor Starzhinskiy on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UICarouselViewCell.h"
#import "UICarouselView.h"

@interface UICarouselView ()

- (void)cellTouchUpInside:(UICarouselViewCell *)cell;
- (void)cellTouchDown:(UICarouselViewCell *)cell;

@end


@implementation UICarouselViewCell

@synthesize selectedBackgroundView;
@synthesize selected;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        selectedBackgroundView = [[UIView alloc] initWithFrame:frame];
        selectedBackgroundView.hidden = YES;
        selectedBackgroundView.backgroundColor = [UIColor blackColor];
        selectedBackgroundView.alpha = 0.15f;
        selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:selectedBackgroundView]; 
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        selectedBackgroundView.backgroundColor = [UIColor blackColor];
        selectedBackgroundView.hidden = YES;
        selectedBackgroundView.alpha = 0.15f;
        selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:selectedBackgroundView]; 
    }
    return self;
}

- (id)init 
{
    return [self initWithFrame:CGRectZero];
}

- (void)dealloc 
{
    [selectedBackgroundView release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ([self.superview respondsToSelector:@selector(cellTouchDown:)]) [(UICarouselView*)self.superview cellTouchDown:self];
    
    [self bringSubviewToFront:selectedBackgroundView];
    if (selected == NO && selectedBackgroundView != nil) [self setHighlighted:YES animated:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (selected == NO && selectedBackgroundView != nil) selectedBackgroundView.hidden = YES;
    
    if ([self.superview respondsToSelector:@selector(cellTouchUpInside:)]) [(UICarouselView*)self.superview cellTouchUpInside:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (selectedBackgroundView != nil) selectedBackgroundView.hidden = YES;
}

- (void)setSelectedBackgroundView:(UIView *)newSelectedBackgroundView
{
    [selectedBackgroundView autorelease];
    [selectedBackgroundView removeFromSuperview];
    selectedBackgroundView = newSelectedBackgroundView;
    selectedBackgroundView.frame = self.frame;
    [self addSubview:selectedBackgroundView];
    
}



- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (selectedBackgroundView == nil || selected == YES) return;
    selectedBackgroundView.alpha = (highlighted == YES) ? 0.0f : 0.15f;
    selectedBackgroundView.hidden = NO;
    if (animated == YES) [UIView animateWithDuration:0.3f animations:^(void) {selectedBackgroundView.alpha = (highlighted == YES) ? 0.15f : 0.0f;}];
}

- (void)setSelected:(BOOL)_selected {
    
    if (selectedBackgroundView != nil) {
        selectedBackgroundView.hidden = !_selected; 
        selectedBackgroundView.alpha = 0.15f;
    }
    selected = _selected;
}

- (void)setSelected:(BOOL)_selected animated:(BOOL)animated {
    
    if (animated == YES && _selected != selected) {
        [UIView animateWithDuration:0.3f 
                         animations:^(void) {selectedBackgroundView.alpha = (_selected == YES) ? 0.15f : 0.0f;} 
                         completion:^(BOOL finished) {
                             selected = _selected;
                         }];
    }
    else {
        [self setSelected:_selected];
    }
}

- (void)prepareForReuse {
    [self setSelected:NO];
}

@end
