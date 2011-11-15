//
//  UICarouselView.m
//  UICarouselViewDemo
//
//  Created by Igor Starzhinskiy on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UICarouselView.h"

@interface UICarouselView ()

//@property (nonatomic, retain) NSMutableArray *allocatedCells;
//@property (nonatomic, retain) NSMutableSet *reusablePool;

- (BOOL)isColumnVisibleForIndex:(NSInteger)index;

@end



@implementation UICarouselView

@synthesize allocatedCells;
@synthesize reusablePool;

@synthesize dataSource; 
@synthesize delegate;
@synthesize columnWidth;
@synthesize indexOfSelectedCell;

@synthesize numberOfColumns;


static float ANIMATION_SPEED = 0.3f;


#pragma mark - Init

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        
        self.allocatedCells = [NSMutableArray arrayWithCapacity:16];
        self.reusablePool = [NSMutableSet setWithCapacity:16];
        
        
        self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        self.contentSize = self.bounds.size;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = NO;
        self.scrollEnabled = YES;
        self.bounces = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        // defaults values
        allocatedCellsRange.location = 0;
        allocatedCellsRange.length = 0;
        columnWidth = 192;
        indexOfSelectedCell = -1;
        numberOfColumns = NSUIntegerMax;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.allocatedCells = [NSMutableArray arrayWithCapacity:16];
        self.reusablePool = [NSMutableSet setWithCapacity:16];

        
        self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        self.contentSize = self.bounds.size;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = NO;
        self.scrollEnabled = YES;
        self.bounces = YES;
        self.showsHorizontalScrollIndicator = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        
        // defaults values
        allocatedCellsRange.location = 0;
        allocatedCellsRange.length = 0;
        columnWidth = 192;
        indexOfSelectedCell = -1;
        numberOfColumns = NSUIntegerMax;
    }
    return self;
}

- (void)dealloc 
{
    [allocatedCells release];
    [reusablePool release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (numberOfColumns == NSUIntegerMax) [self reloadData];
}


- (NSRange)getVisibleRange {
    NSInteger offset = self.contentOffset.x;
    if (offset < 0) offset = 0;
    NSRange range = NSMakeRange(offset / columnWidth, (self.bounds.size.width / columnWidth + 2));
    if ((range.length + range.location) > numberOfColumns) range.length = numberOfColumns - range.location;
    return range;
}

- (NSUInteger)getLastVisibleCellIndex {
    NSRange visibleRange = [self getVisibleRange];
    return visibleRange.location + visibleRange.length - 1;
}

- (UICarouselViewCell *)dequeueReusableCell
{
    UICarouselViewCell *cell = nil;
    NSRange visibleRange = [self getVisibleRange];
    
    if (reusablePool.count > 0) {
        cell = [reusablePool anyObject];
    }else {
        if (visibleRange.location > (allocatedCellsRange.location + 2)) {
            cell = [allocatedCells objectAtIndex:0];
            [reusablePool addObject:cell];
            [allocatedCells removeObjectAtIndex:0];
            allocatedCellsRange.location++;
            allocatedCellsRange.length = allocatedCells.count;
        }else if ((visibleRange.length + 1) < allocatedCellsRange.length) {
            cell = [allocatedCells lastObject];
            [reusablePool addObject:cell];
            [allocatedCells removeLastObject];
            allocatedCellsRange.length = allocatedCells.count;
        }
    }
    
    if (cell != nil) {
        [cell prepareForReuse];
        [cell removeFromSuperview];
        return cell;
    }
    
    return nil;
}

- (UICarouselViewCell *)setupCellAtIndex:(NSUInteger)index
{
    UICarouselViewCell *cell = [dataSource carouselView:self cellForColumnAtIndex:index];
    if (cell == nil) return nil;

    cell.frame = CGRectMake(index * columnWidth, 0, columnWidth, self.bounds.size.height);
    if (index == indexOfSelectedCell) [cell setSelected:YES animated:NO]; 
    
    if ([allocatedCells indexOfObject:cell] == NSNotFound) {
        
        NSUInteger indexInArray = index - allocatedCellsRange.location;
        if (index < allocatedCellsRange.location) indexInArray = 0;
        
        if (indexInArray >= allocatedCells.count) [allocatedCells addObject:cell];
        else [allocatedCells insertObject:cell atIndex:indexInArray];
    }
    allocatedCellsRange.length = allocatedCells.count;
    [self addSubview:cell];
    [reusablePool removeObject:cell];
    
    return cell;
}

- (void)reloadData
{
    indexOfSelectedCell = -1;
    if (dataSource == nil) return;
    if ([dataSource respondsToSelector:@selector(numberOfColumnsForCarouselView:)] == NO 
        || [dataSource respondsToSelector:@selector(carouselView:cellForColumnAtIndex:)] == NO) 
        return;
    
    numberOfColumns = 0;
    numberOfColumns = [dataSource numberOfColumnsForCarouselView:self];
    
    if (allocatedCells.count > 0) {
        for (UICarouselViewCell *cell in allocatedCells)[cell removeFromSuperview];
        [reusablePool addObjectsFromArray:allocatedCells];
        [allocatedCells removeAllObjects];
        allocatedCellsRange = NSMakeRange(0, 0);
    }
    
    NSRange visibleRange = [self getVisibleRange];
    NSUInteger cellIndex = visibleRange.location;
    
    for (NSUInteger i = 0; i < visibleRange.length; i++) {
        
        [self setupCellAtIndex:cellIndex];
        //allocatedCellsRange.length++;
        cellIndex++;
    }
    self.contentSize = CGSizeMake(numberOfColumns * columnWidth, self.bounds.size.height);
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    if (contentOffset.x == self.contentOffset.x) return; //prevention of unnecessary work by setContentSize calls
    [super setContentOffset:contentOffset];
    
    if (numberOfColumns == 0 || numberOfColumns == NSUIntegerMax) return;
    
    NSRange visibleRange = [self getVisibleRange];
    
    if (visibleRange.location < allocatedCellsRange.location) {
        
        NSInteger start = visibleRange.location;
        for (NSInteger cellIndex = allocatedCellsRange.location - 1; cellIndex >= start; cellIndex--) {
            
            [self setupCellAtIndex:cellIndex];
            allocatedCellsRange.location = cellIndex;
        }
    }
    
    NSUInteger allocEnd = allocatedCellsRange.location + allocatedCellsRange.length;
    NSUInteger visibleEnd = visibleRange.location + visibleRange.length;
    
    if (visibleEnd > allocEnd) {
        
        for (NSUInteger cellIndex = allocEnd; cellIndex < visibleEnd; cellIndex++) [self setupCellAtIndex:cellIndex];
    }

}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setContentOffset:self.contentOffset];
}


#pragma mark - Private

- (BOOL)isColumnVisibleForIndex:(NSInteger)index {
    NSRange visibleRange = [self getVisibleRange];
	return (index >= visibleRange.location && index <= (visibleRange.location + visibleRange.length));
}

- (NSArray *)visibleCells
{
    return [NSArray arrayWithArray:allocatedCells];
}

- (UICarouselViewCell *)visibleCellForIndex:(NSInteger)index {
    
    if ([self isColumnVisibleForIndex:index] == NO) return nil;
    
    return [allocatedCells objectAtIndex:index - allocatedCellsRange.location];
}


- (NSMutableArray *)getSortedNumbers:(NSArray *)_numbers ascending:(BOOL)ascending
{
    NSMutableArray *numbers = [NSMutableArray arrayWithArray:_numbers];
    [numbers sortUsingDescriptors:
     [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"intValue" ascending:ascending]autorelease]]];
    return numbers;
}


- (void)insertColumnAtIndex:(NSUInteger)index withColumnAnimation:(UICarouselViewColumnAnimation)animation
{
    numberOfColumns++;
    NSUInteger endLocation = allocatedCellsRange.location + allocatedCellsRange.length;
    if (index < allocatedCellsRange.location || index > endLocation) return;
    
    NSArray *cellsToMove = [allocatedCells subarrayWithRange:NSMakeRange(index, endLocation - index)];
    
    [UIView animateWithDuration: cellsToMove.count ? ANIMATION_SPEED : 0.0f
					 animations:^{
						 for (UICarouselViewCell *cell in cellsToMove) {
                             CGRect frame = cell.frame;
                             frame.origin.x += columnWidth;
                             cell.frame = frame;
                         }
                     }
                    completion:^(BOOL finished) {
                        UICarouselViewCell *cell = [self setupCellAtIndex:index];
                        cell.alpha = 0.0;
                        //numberOfColumns++;
                        self.contentSize = CGSizeMake(numberOfColumns * columnWidth, self.bounds.size.height);
                        
                        [UIView animateWithDuration:ANIMATION_SPEED 
                                         animations:^{ 
                                             cell.alpha = 1.0; 
                                         }];
					 }];
    
}


- (void)insertColumnsAtIndexes:(NSArray *)_indexes withColumnAnimation:(UICarouselViewColumnAnimation)animation
{
	
    NSMutableArray *indexes = [self getSortedNumbers:_indexes ascending:YES];
    /*
    for (NSNumber *index in indexes) {
		[self insertColumnAtIndex:[index intValue] withColumnAnimation:animation];
	}
     */
    
    CGFloat animationSpeed = 0.0f;
    
    NSUInteger cellIndex = allocatedCellsRange.location;
    NSMutableArray *cellShifts = [NSMutableArray arrayWithCapacity:allocatedCells.count];
    for (UICarouselViewCell *cell in allocatedCells) {
        
        CGFloat cellShift = 0;
        NSUInteger indexShift = 0;
        
        for (NSNumber *indexNum in indexes) {
            
            NSUInteger index = [indexNum intValue];
            if (cellIndex + indexShift >= index) {
                animationSpeed = ANIMATION_SPEED;
                cellShift += columnWidth;
                indexShift++;
            }
        }
        [cellShifts addObject:[NSNumber numberWithFloat:cellShift]];
        cellIndex++;
    }
    
    [UIView animateWithDuration: animationSpeed
					 animations:^{
                         
                         NSUInteger i = 0;
                         for (UICarouselViewCell *cell in allocatedCells) {
                             CGRect frame = cell.frame;
                             frame.origin.x += [[cellShifts objectAtIndex:i] floatValue];
                             cell.frame = frame;
                         }


                     }
                     completion:^(BOOL finished) {
                         
                         if (finished) {
                             
                             [self reloadData];
                             if (animation == UICarouselViewColumnAnimationNone) return;
                             
                             NSMutableArray *animatedCells = [NSMutableArray arrayWithCapacity:allocatedCells.count];
                             
                             for (NSNumber *indexNum in indexes) {
                                 UICarouselViewCell *cell = [self visibleCellForIndex:[indexNum intValue]];
                                 if (cell != nil) {
                                     cell.alpha = 0.0f;
                                     [animatedCells addObject:cell];  
                                 }
                             }
                             
                             [UIView animateWithDuration:ANIMATION_SPEED 
                                              animations:^{ 
                                                  for (UICarouselViewCell *cell in animatedCells) {
                                                      cell.alpha = 1.0f;
                                                  }
                                              }];
                         }
					 }];
}


- (void)deleteColumnAtIndex:(NSUInteger)index withColumnAnimation:(UICarouselViewColumnAnimation)animation
{
    if (index >= numberOfColumns) return;
    
    numberOfColumns--;
    NSUInteger endLocation = allocatedCellsRange.location + allocatedCellsRange.length;
    if (index > endLocation) {
        
        self.contentSize = CGSizeMake(numberOfColumns * columnWidth, self.bounds.size.height);
        return;
    }
    if (index < allocatedCellsRange.location) index = allocatedCellsRange.location; //??? need check this moment
    
    
    
    NSUInteger indexInArray = index - allocatedCellsRange.location;
    UICarouselViewCell *cell = [allocatedCells objectAtIndex:indexInArray];
    
    
    [UIView animateWithDuration:ANIMATION_SPEED 
                     animations:^{ 
                         cell.alpha = 0.0f; 
                     } 
                     completion:^(BOOL finished) {
                         
                         [cell removeFromSuperview];
                         cell.alpha = 1.0f;
                         [reusablePool addObject:cell];
                         [allocatedCells removeObjectAtIndex:indexInArray];
                         allocatedCellsRange.length = allocatedCells.count;

                         if (endLocation < numberOfColumns) {
                             //prepare cell at end of visible location
                             [allocatedCells addObject:cell];
                             [self setupCellAtIndex:endLocation];
                         }

                         
                         NSArray *cellsToMove = [allocatedCells subarrayWithRange:NSMakeRange(indexInArray, allocatedCells.count - indexInArray)];
                         [UIView animateWithDuration:ANIMATION_SPEED
                                          animations:^{
                                              for (UICarouselViewCell *cell in cellsToMove) {
                                                  CGRect frame = cell.frame;
                                                  frame.origin.x -= columnWidth;
                                                  cell.frame = frame;
                                              }
                                          }
                                          completion:^(BOOL finished) {
                                              self.contentSize = CGSizeMake(numberOfColumns * columnWidth, self.bounds.size.height);
                                          }];
                     }];
    
}


- (void)deleteColumnsAtIndexes:(NSArray *)_indexes withColumnAnimation:(UICarouselViewColumnAnimation)animation
{
	
    NSMutableArray *indexes = [self getSortedNumbers:_indexes ascending:YES];
    CGFloat animationSpeed = (animation == UICarouselViewColumnAnimationNone) ? 0.0f : ANIMATION_SPEED;
    
    NSMutableArray *animatedCells = [NSMutableArray arrayWithCapacity:allocatedCells.count];
    for (NSNumber *indexNum in indexes) {
        NSUInteger index = [indexNum intValue];
        if (indexOfSelectedCell == index) indexOfSelectedCell = -1;
        UICarouselViewCell *cell = [self visibleCellForIndex:index];
        if (cell != nil) [animatedCells addObject:cell];
    }
    
    numberOfColumns -= indexes.count;
    
    [UIView animateWithDuration: animationSpeed 
                     animations:^{ 
                         for (UICarouselViewCell *cell in animatedCells) {
                             cell.alpha = 0.0f;
                         }
                          
                     } 
                     completion:^(BOOL finished) {
                         
                         NSUInteger fix = allocatedCellsRange.location + allocatedCellsRange.length;
                         for (UICarouselViewCell *cell in animatedCells) {
                             
                             [cell removeFromSuperview];
                             cell.alpha = 1.0f;
                             [reusablePool addObject:cell];
                             NSUInteger indexInArray = [allocatedCells indexOfObject:cell];
                             [allocatedCells removeObjectAtIndex:indexInArray];
                             if (indexInArray == 0 && allocatedCellsRange.location > 0) allocatedCellsRange.location--;
                             
                             allocatedCellsRange.length = allocatedCells.count;
                         }
                         NSUInteger lastVisibleCellIndex = [self getLastVisibleCellIndex];
                         while (allocatedCellsRange.location + allocatedCellsRange.length <= lastVisibleCellIndex) {
                             UICarouselViewCell *cell = [self setupCellAtIndex:allocatedCellsRange.location + allocatedCellsRange.length];
                             CGRect frame = cell.frame;
                             frame.origin.x = columnWidth * fix;
                             cell.frame = frame;
                             fix++;
                         }
                         [UIView animateWithDuration:ANIMATION_SPEED
                                          animations:^{
                                              NSUInteger cellIndex = allocatedCellsRange.location;
                                              for (UICarouselViewCell *cell in allocatedCells) {
                                                  cell.frame = CGRectMake(cellIndex * columnWidth, 0, columnWidth, self.bounds.size.height);
                                                  cellIndex++;
                                              }
                                          }];
                     }];
}


- (NSUInteger)indexForCell:(UICarouselViewCell *)cell
{
    NSUInteger indexInArray = [allocatedCells indexOfObject:cell];
    return allocatedCellsRange.location + indexInArray;
}


#pragma mark - UICarouselViewCell actions

- (void)cellTouchDown:(UICarouselViewCell *)cell {
    
    NSUInteger index = [self indexForCell:cell];
    if (index == indexOfSelectedCell) return;
    
    // deselect previous selected cell 
    if (indexOfSelectedCell != -1) {
        
        UICarouselViewCell *previousSelectedCell = [self visibleCellForIndex:indexOfSelectedCell];
        if ([delegate respondsToSelector:@selector(carouselView:didDeselectCellAtIndex:)])
            [delegate carouselView:self didDeselectCellAtIndex:indexOfSelectedCell];
        if (previousSelectedCell != nil) [previousSelectedCell setSelected:NO animated:NO];
        indexOfSelectedCell = -1;
    }
}


- (void)cellTouchUpInside:(UICarouselViewCell *)cell {
    
    NSUInteger index = [self indexForCell:cell];
    if (index == indexOfSelectedCell) return;
    
    // select tapped cell 
    UICarouselViewCell *newSelectedCell = [self visibleCellForIndex:index];
    [newSelectedCell setSelected:YES animated:NO];
    
    indexOfSelectedCell = index; 
    
    if ([delegate respondsToSelector:@selector(carouselView:didSelectCellAtIndex:)]) [delegate carouselView:self didSelectCellAtIndex:index];
}


- (void)scrollToCellAtIndex:(NSUInteger)index atScrollPosition:(UICarouselViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    CGPoint pos = CGPointMake(columnWidth * index, 0);
    switch (scrollPosition) {
        case UITableViewScrollPositionNone: [self scrollRectToVisible:CGRectMake(pos.x, pos.y, columnWidth, self.bounds.size.height) animated:animated];
            return;
        case UITableViewScrollPositionMiddle: pos.x += self.bounds.size.width / 2.0f - columnWidth / 2.0f;
            break;
        case UITableViewScrollPositionRight: pos.x += self.bounds.size.width - columnWidth;
            break;
    }
    [self setContentOffset:pos animated:animated];
}

- (void)selectCellAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index == indexOfSelectedCell) return;
    
    if (indexOfSelectedCell != -1) {
        UICarouselViewCell *previousSelectedCell = [self visibleCellForIndex:indexOfSelectedCell];
        //if ([delegate respondsToSelector:@selector(carouselView:didDeselectCellAtIndex:)]) [delegate carouselView:self didDeselectCellAtIndex:indexOfSelectedCell];
        if (previousSelectedCell != nil) [previousSelectedCell setSelected:NO animated:NO];
    }
    
    UICarouselViewCell *cell = [self visibleCellForIndex:index];
    if (cell != nil) {
        UICarouselViewCell *newSelectedCell = [self visibleCellForIndex:index];
        [newSelectedCell setSelected:YES animated:NO];
        indexOfSelectedCell = index; 
        
        //if ([delegate respondsToSelector:@selector(carouselView:didSelectCellAtIndex:)]) [delegate carouselView:self didSelectCellAtIndex:index];
    }
    indexOfSelectedCell = index;
}

- (void)deselectCellAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index != indexOfSelectedCell) return;
    UICarouselViewCell *cell = [self visibleCellForIndex:index];
    if (cell != nil) [cell setSelected:NO animated:animated];
    indexOfSelectedCell = -1;
}


@end
