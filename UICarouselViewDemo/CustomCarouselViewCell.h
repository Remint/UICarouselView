//
//  CustomCarouselViewCell.h
//  UICarouselViewDemo
//
//  Created by Igor Starzhinskiy on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UICarouselViewCell.h"

@interface CustomCarouselViewCell : UICarouselViewCell {
    
    UILabel *label;
    
}

@property (nonatomic, retain) IBOutlet UILabel *label;

@end
