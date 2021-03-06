//
//  RRPageViewController.m
//  Pods
//
//  Created by Rutger Nijhuis on 21/11/2016.
//
//

#import "RRPageViewController.h"

@interface RRPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

/**
 The PageController that contains the content controllers
 */
@property (nonatomic, retain) UIPageViewController *pageController;


/**
 View that contains the RRPageControl if not created manually
 */
@property (nonatomic, retain) UIView *pageControlWrapper;

@end

@implementation RRPageViewController{
    CGFloat internalPageControlHeight;
    
    // Constraints
    NSLayoutConstraint *constraintPageControlHeight;
}

@synthesize pageControlHeight = _pageControlHeight;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the datasource and delegate to self, catch this in your subclass
    self.dataSource = self;
    self.delegate = self;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    [self setupPageController];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.pageControl reloadData];
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
//    [self.pageControl reloadData];
}


#pragma mark - PageViewController

- (void)setupPageController{
    
    // Page controller
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    
    
    for (UIView *view in self.pageController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]){
            ((UIScrollView *)view).delegate = self;
        }
        
    }
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    
    [self.view addSubview:self.pageController.view];
    
    // Page control wrapper
    self.pageControlWrapper = [UIView new];
    [self.view addSubview:self.pageControlWrapper];
    
    self.pageControlWrapper.translatesAutoresizingMaskIntoConstraints = NO;
    self.pageController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Page control constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControlWrapper attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControlWrapper attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControlWrapper attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControlWrapper attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.pageController.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    // Height
    constraintPageControlHeight = [NSLayoutConstraint constraintWithItem:self.pageControlWrapper attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:self.pageControlHeight];
    [self.pageControlWrapper addConstraint:constraintPageControlHeight];
    
    // Page controller constraints
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pageController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pageController.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pageController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    // Setup default pageControl if none is specified through Interface Builder
    if (!self.pageControl){
        self.pageControl = [RRPageControl new];
        self.pageControl.dataSource = self;
        self.pageControl.delegate = self;
        self.pageControl.backgroundColor = [UIColor whiteColor];
        [self.pageControlWrapper addSubview:self.pageControl];
        
        // Page control constraints
        self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self.pageControlWrapper addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.pageControlWrapper attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        [self.pageControlWrapper addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.pageControlWrapper attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [self.pageControlWrapper addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.pageControlWrapper attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.pageControlWrapper addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.pageControlWrapper attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
}

- (void)setPageControllers:(NSArray<UIViewController *> *)controllers{
    _pages = controllers;
    [self reloadData];
}

- (void)reloadData{
    NSArray *pages = self.pages;
    if (!self.pages || self.pages.count == 0){
        pages = @[[UIViewController new]];
    }
        
        
    [self.pageController setViewControllers:@[pages.firstObject]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:^(BOOL finished) {
                                     
                                 }];
    
    [self.pageControl reloadData];
}

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated{
    if (index >= self.pages.count || (NSInteger)index < 0){
        NSLog(@"ERROR: scrollToIndex:animated: index:(%lu) is out of bounds:(%lu)", (long unsigned)index, (long unsigned)self.pages.count-1);
        return;
    }
    else if (self.isScrolling){
        NSLog(@"WARN: scrollToIndex:animated: We're already scrolling, terminating request..");
//        return;
    }
    
    // Lock other scroll events
    _isScrolling = YES;
    
    UIViewController *controller = self.pages[index];
    
    
    UIPageViewControllerNavigationDirection direction = self.currentIndex > index ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;
    
    __weak RRPageViewController *weakSelf = self;
    
    [self.pageController setViewControllers:@[controller]
                                  direction:direction
                                   animated:animated
                                 completion:^(BOOL finished) {
                                     // TODO: Make callback
                                     NSLog(@"scrollToIndex: completed");
                                     
                                     [weakSelf setCurrentIndex:index];
                                     _isScrolling = NO;
                                     
                                 }];
}


#pragma mark - Properties

- (void)setCurrentIndex:(NSUInteger)newIndex{
    NSLog(@"Index changed %lu => %lu", (long unsigned)self.currentIndex, (long unsigned)newIndex);
    _currentIndex = newIndex;
    
    [self.pageControl selectTabAtIndex:newIndex animated:NO];
}

- (void)setPageControlHeight:(CGFloat)pageControlHeight{
    _pageControlHeight = pageControlHeight;
    
    // Update contstraints
    constraintPageControlHeight.constant = pageControlHeight;
    
}

- (CGFloat)pageControlHeight{
    if (!_pageControlHeight){
        _pageControlHeight = 60;
    }
    return _pageControlHeight;
}


#pragma mark - UIPageViewController DataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = [self.pages indexOfObject:viewController];
    if (index == 0){
        // This is already the first object
        return nil;
    }
    else{
        return self.pages[index-1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger index = [self.pages indexOfObject:viewController];
    if (index+1 == self.pages.count){
        // This is already the last object
        return nil;
    }
    else{
        return self.pages[index+1];
    }
}


#pragma mark - UIPageViewController Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
    NSUInteger index = [self.pages indexOfObject:pendingViewControllers.firstObject];
    
//    [self.pageControl peekTabAtIndex:index];
    
    NSLog(@"willTransition: %lu",(long unsigned)index);
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    
    NSUInteger newIndex = [self.pages indexOfObject: pageViewController.viewControllers.firstObject];
    
    NSLog(@"didFinishAnimating: current: %lu", (long unsigned)newIndex);
    
    [self setCurrentIndex:newIndex];
}


#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
//    if (scrollView.panGestureRecognizer.state != UIGestureRecognizerStatePossible){
        CGFloat origin = self.view.bounds.size.width;
        
//        NSLog(@"didScrol.. %.0f / %.3f%%",scrollView.contentOffset.x, (scrollView.contentOffset.x/origin)-1);
        
        [self.pageControl scrollProgress:(scrollView.contentOffset.x/origin)-1];
//    }
}


#pragma mark - RRPageControl DataSource

- (NSUInteger)pageControlNumberOfTabs:(RRPageControl *)control{
    return self.pages.count;
}

- (UIView *)pageControl:(RRPageControl *)control viewForTabAtIndex:(NSUInteger)index bounds:(CGRect)bounds{
    UIView *view = [UIView new];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:bounds];
    lbl.text = @(index).stringValue;
    lbl.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lbl];
    
    return view;
}

- (CGFloat)pageControl:(RRPageControl *)control widthForTabAtIndex:(NSUInteger)index{
    return 50;
//    return arc4random() % 100 + 50;
}


#pragma mark - RRPageControl Delegate

- (void)pageControl:(RRPageControl *)control didSelectTabAtIndex:(NSUInteger)index{
    [self scrollToIndex:index animated:YES];
}

@end
