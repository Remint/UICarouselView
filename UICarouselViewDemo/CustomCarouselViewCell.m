//
//  CustomCarouselViewCell.m
//  UICarouselViewDemo
//
//  Created by Igor Starzhinskiy on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomCarouselViewCell.h"

@implementation CustomCarouselViewCell

@synthesize label;

- (void)prepareForReuse {
    [super prepareForReuse];
    self.label.text = @"";
}

- (void)dealloc {
    [label release];
    [super dealloc];
}

@end
