//
//  UICarouselViewDemoViewController.m
//  UICarouselViewDemo
//
//  Created by Igor Starzhinskiy on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UICarouselViewDemoViewController.h"
#import "CustomCarouselViewCell.h"


@interface UICarouselViewDemoViewController ()

@property (nonatomic, retain) NSMutableArray *dataSourceArray;
@property (nonatomic, retain) NSTimer *timer;

@end



@implementation UICarouselViewDemoViewController

@synthesize dataSourceArray;
@synthesize timer;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)updateLabels {
    lblNumberOfColumns.text = [[NSNumber numberWithInt:carouselView.numberOfColumns] description];
    lblNumberByDataSource.text = [[NSNumber numberWithInt:dataSourceArray.count] description];
    lblAllocatedCells.text = [[NSNumber numberWithInt:carouselView.allocatedCells.count] description];
    lblReusablePool.text = [[NSNumber numberWithInt:carouselView.reusablePool.count] description];
    lblSelectedCell.text = [[NSNumber numberWithInt:carouselView.indexOfSelectedCell] description];
}

#pragma mark - View lifecycle

- (void)dealloc
{
    [timer invalidate];
    [timer release];
    [dataSourceArray release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.dataSourceArray = [NSMutableArray arrayWithCapacity:32];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) carouselView.columnWidth = 107.0f;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [timer invalidate];
    self.timer = nil;
    self.dataSourceArray = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

static const NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

- (NSString *)randomString {	
	NSMutableString *randomString = [NSMutableString stringWithCapacity:10];
    
	for (int i=0; i<10; i++) {
		[randomString appendFormat: @"%c", [letters characterAtIndex: rand()%[letters length]]];
	}
	
	return randomString;
}

#pragma mark - actions

- (IBAction)addColumn:(id)sender {
    
    [dataSourceArray addObject:[self randomString]];
    [carouselView reloadData];
    
}

- (IBAction)addMultipleColumns:(id)sender {
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:5];
    for (NSUInteger i = 0; i < 2; i++) {
        [indexes addObject:[NSNumber numberWithInt:i]];
        [dataSourceArray insertObject:[self randomString] atIndex:i];
    }
    [carouselView insertColumnsAtIndexes:indexes withColumnAnimation:UICarouselViewColumnAnimationFade];
}

- (IBAction)removeSelectedColumn:(id)sender {
    if (carouselView.indexOfSelectedCell != -1) {
        [dataSourceArray removeObjectAtIndex:carouselView.indexOfSelectedCell];
        [carouselView deleteColumnsAtIndexes:[NSArray arrayWithObject:[NSNumber numberWithInt:carouselView.indexOfSelectedCell]] 
                                                  withColumnAnimation:UICarouselViewColumnAnimationFade];
    }
}

- (IBAction)removeMultipleColumns:(id)sender {
    
    if (dataSourceArray.count == 0) return;
    NSUInteger count = dataSourceArray.count;
    if (count > 3) count = 3;
    
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:count];
	
	for (int i = 0; i < count; i++) {
		[dataSourceArray removeObjectAtIndex:0];
		[indexes addObject:[NSNumber numberWithInt:i]];
	}
	
	[carouselView deleteColumnsAtIndexes:indexes withColumnAnimation:UICarouselViewColumnAnimationFade];
}

- (IBAction)clearAll:(id)sender {
    [dataSourceArray removeAllObjects];
    [carouselView reloadData];
}

- (IBAction)reloadData:(id)sender {
    [carouselView reloadData];
}

#pragma mark - UICarouselViewDataSource

- (NSUInteger)numberOfColumnsForCarouselView:(UICarouselView *)aCarouselView
{
    if (dataSourceArray.count == 0) {
        btnDeleteSelected.enabled = NO;
        btnDeleteMultiple.enabled = NO;
        btnClearAll.enabled = NO;
    }else {
        btnDeleteMultiple.enabled = YES;
        btnClearAll.enabled = YES;
    }
    
    return dataSourceArray.count;
}

- (UICarouselViewCell *)carouselView:(UICarouselView *)aCarouselView cellForColumnAtIndex:(NSInteger)index
{
    static NSString *CellIdentifier = @"CustomCarouselViewCell";
    
    CustomCarouselViewCell *cell = (CustomCarouselViewCell *)[aCarouselView dequeueReusableCell];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
		
		for (id currentObject in topLevelObjects){
			if ([currentObject isKindOfClass:[CustomCarouselViewCell class]]){
				cell =  (CustomCarouselViewCell *) currentObject;
				break;
			}
		}
    }
    
    cell.label.text = [dataSourceArray objectAtIndex:index];
    
    return cell;
}

#pragma mark - UICarouselViewDelegate

- (void)carouselView:(UICarouselView *)carouselView didSelectCellAtIndex:(NSInteger)index
{
    btnDeleteSelected.enabled = YES;
}

- (void)carouselView:(UICarouselView *)carouselView didDeselectCellAtIndex:(NSInteger)index
{
    btnDeleteSelected.enabled = NO;
}

@end
