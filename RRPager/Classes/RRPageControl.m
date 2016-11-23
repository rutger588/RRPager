//
//  RRPageControl.m
//  Pods
//
//  Created by Rutger Nijhuis on 21/11/2016.
//
//

#import "RRPageControl.h"

@interface RRPageControl () <UIScrollViewDelegate>

@property (nonatomic, retain) UIScrollView *scrollView;

/**
 Contains the tab views
 */
@property (nonatomic, retain) NSMutableArray <UIView *> *tabViews;

@end

@implementation RRPageControl{
    
    CGFloat scrollProgress;
    
    BOOL listenToScrollProgress;
}

@synthesize tabWidth = _tabWidth;

#pragma mark - Initializers

- (instancetype)init{
    self = [super init];
    
    [self defaultSetup];
    
    return self;
}

- (void)defaultSetup{
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.frame = self.bounds;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:self.scrollView];
    
    listenToScrollProgress = YES;
    
    // ScrollView Constraints
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    
    
    // Indicator
    _indicator = [UIView new];
    self.indicator.backgroundColor = [UIColor greenColor];
    [self.scrollView addSubview:self.indicator];
}


#pragma mark - Layout

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    BOOL animate = self.indicator.frame.size.width > 0;
    
    [self drawPagerInRect:rect animated:animate];

}

- (void)drawPagerInRect:(CGRect)rect animated:(BOOL)animated{
    CGFloat height = 2;
    
    CGFloat x = self.selectedIndex * self.tabWidth +  ((animated ? 0 : scrollProgress) * self.tabWidth);
    
    CGRect indicatorRect = CGRectMake(x, rect.size.height-height, self.tabWidth, height);
    
    // Get the x of the selected index
    CGFloat margin = (rect.size.width - self.tabWidth) / 2;
    CGRect centerRect = CGRectMake(x-margin, 0, self.tabWidth+margin+margin, height);
    
    
    if (animated){
        [UIView animateWithDuration:.3 animations:^{
            self.indicator.frame = indicatorRect;
        } completion:^(BOOL finished) {
            listenToScrollProgress = YES;
        }];
    }
    else{
        self.indicator.frame = indicatorRect;
        listenToScrollProgress = YES;
    }
    
    [self.scrollView scrollRectToVisible:centerRect animated:animated];
}


#pragma mark - Public 

- (void)reloadData{
    // Rebuild scrollview
    
    for (UIView *subView in self.tabViews) {
        [subView removeFromSuperview];
    }
    
    NSUInteger numberTabs = [self.dataSource pageControlNumberOfTabs:self];
    self.tabViews = [NSMutableArray new];
    
    CGFloat x = 0;
    CGFloat height = self.bounds.size.height;
    
    
    self.scrollView.contentSize = CGSizeMake(numberTabs * self.tabWidth, height);
    
    for (int index = 0; index < numberTabs; index++) {
        UIView *tabView = [self.dataSource pageControl:self viewForTabAtIndex:index];
        tabView.frame = CGRectMake(x, 0, self.tabWidth, height);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tabTabbed:)];
        [tabView addGestureRecognizer:tap];
        
        [self.scrollView addSubview:tabView];
        [self.tabViews addObject:tabView];
        x+= self.tabWidth;
    }
    // Bring the indicator to the front
    [self.scrollView bringSubviewToFront:self.indicator];
    
    //[self setNeedsDisplay];
}

- (void)selectTabAtIndex:(NSUInteger)index{
    [self selectTabAtIndex:index animated:YES];
}

- (void)selectTabAtIndex:(NSUInteger)index animated:(BOOL)animated{
    _selectedIndex = index;
    scrollProgress = 0; //reset scroll progress
    
    // Disable scrollProgress listening while scrolling to the new index
    
    // Animate to the new index
    [self drawPagerInRect:self.bounds animated:animated];
}

- (void)scrollProgress:(CGFloat)progress{
    scrollProgress = progress;
    
    if (progress != 0 && listenToScrollProgress){
        [self drawPagerInRect:self.bounds animated:NO];
    }
}


#pragma mark - Properties

- (void)setTabWidth:(NSUInteger)tabWidth{
    _tabWidth = tabWidth;
}

- (NSUInteger)tabWidth{
    if (!_tabWidth){
        _tabWidth = 50;
    }
    return _tabWidth;
}


#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}


#pragma mark - UITapGestureRecognizer

- (void)tabTabbed:(UITapGestureRecognizer *)recognizer{
    NSUInteger index =  [self.tabViews indexOfObject:recognizer.view];
    listenToScrollProgress = NO;
    [self selectTabAtIndex:index animated:YES];
    
    [self.delegate pageControl:self didSelectTabAtIndex:index];
}

@end
