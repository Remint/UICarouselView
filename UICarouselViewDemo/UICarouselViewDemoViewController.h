//
//  UICarouselViewDemoViewController.h
//  UICarouselViewDemo
//
//  Created by Igor Starzhinskiy on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICarouselView.h"

@interface UICarouselViewDemoViewController : UIViewController <UICarouselViewDataSource, UICarouselViewDelegate> {

    IBOutlet UICarouselView *carouselView;
    
    IBOutlet UIButton *btnDeleteSelected;
    IBOutlet UIButton *btnDeleteMultiple;
    IBOutlet UIButton *btnClearAll;
    
    IBOutlet UILabel *lblNumberOfColumns;
    IBOutlet UILabel *lblNumberByDataSource;
    IBOutlet UILabel *lblAllocatedCells;
    IBOutlet UILabel *lblReusablePool;
    IBOutlet UILabel *lblSelectedCell;
    
    NSMutableArray *dataSourceArray;
    NSTimer *timer;
}

- (IBAction)addColumn:(id)sender;
- (IBAction)addMultipleColumns:(id)sender;
- (IBAction)removeSelectedColumn:(id)sender;
- (IBAction)removeMultipleColumns:(id)sender;
- (IBAction)clearAll:(id)sender;
- (IBAction)reloadData:(id)sender;

@end
