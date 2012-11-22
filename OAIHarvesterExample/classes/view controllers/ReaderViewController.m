//
//  MyPageViewController.m
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/15/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import "ReaderViewController.h"

@interface ReaderViewController ()

@end

@implementation ReaderViewController

@synthesize thumbView, oaiRecordHelper;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithOAIRecordHelper:(OAIRecordHelper *)theOAIRecordHelper{
    self = [super init];
    if (self) {
        // Custom initialization
        self.oaiRecordHelper = theOAIRecordHelper;
        thumbsShown = NO;
        currentPage = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = [oaiRecordHelper getTitle];
    
    NSDictionary *options =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                forKey: UIPageViewControllerOptionSpineLocationKey];
    
    pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    pageViewController.dataSource = self;
    pageViewController.delegate = self;
    pageViewController.view.autoresizesSubviews = NO;
    pageViewController.view.backgroundColor = [UIColor yellowColor];
    
    PageViewController *notesPageController = [[PageViewController alloc]
                                               initWithNibName:@"PageView" bundle:nil oaiRecordHelper:oaiRecordHelper andPage:0];
    notesPageController.fatherController = self.navigationController;
    notesPageController.readerViewController = self;
    NSArray *pageViewControllers = [NSArray arrayWithObjects:notesPageController, nil];
    [pageViewController setViewControllers:pageViewControllers
                                 direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    [self.view addSubview:pageViewController.view];
        CGRect frame = pageViewController.view.frame;
        frame.origin.y -= 20;
        pageViewController.view.frame = frame;
    
    //Add the thumbnails view
    UIViewController *thumbController = [[UIViewController alloc] initWithNibName:@"ThumbnailView" bundle:[NSBundle mainBundle]];
    self.thumbView = (ThumbnailView *)thumbController.view;
    self.thumbView.recordHelper = oaiRecordHelper;
    [self.thumbView initialize];
    self.thumbView.delegate = self;
    thumbView.frame = CGRectMake(0, 5000, 320, 200);
    [self.view addSubview:thumbView];
    [thumbController release];
    
    self.view.autoresizesSubviews = NO;
    
    [self updateUI];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc{
    
    [thumbView release];
    [oaiRecordHelper release];
    [pageViewController release];
    
    [super dealloc];
}

#pragma mark - Rotation

- (BOOL) shouldAutorotate{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

//iOS5 support
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    for (PageViewController *viewcontroller in pageViewController.viewControllers){
        viewcontroller.shouldUpdate = YES;
        [viewcontroller didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
    
    BOOL hidden = self.navigationController.navigationBarHidden;
    
    CGRect frame;
    if (!hidden){
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
            if (IS_IPAD)
                frame = CGRectMake(0, 0, 768, 1024-20-44);
            else
                frame = CGRectMake(0, 0, 320, 480-20-44);
        }
        else {
            if (IS_IPAD)
                frame = CGRectMake(0, 0, 1024, 768-20-44);
            else
                frame = CGRectMake(0, 0, 480, 320-20-32);
        }
        
    }
    else {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
            if (IS_IPAD)
                frame = CGRectMake(0, 0, 768, 1024-20);
            else
                frame = CGRectMake(0, 0, 320, 480-20);
        }
        else {
            if (IS_IPAD)
                frame = CGRectMake(0, 0, 1024, 768-20);
            else
                frame = CGRectMake(0, 0, 480, 320-20);
        }
    }
    pageViewController.view.frame = frame;
    
    [UIView beginAnimations: @"moveField"context: nil];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDuration: 0.5];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    
    int height = IS_IPAD?200:150;
    int offset = IS_IPAD?50:30;
    
    if (!hidden){
        //if (IS_IPAD){
            if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)){ //new orientation, portrait
                thumbView.frame = CGRectMake(0, (IS_IPAD?1024:480)-20-44-(thumbsShown?height:offset), (IS_IPAD?768:320), height);
            }
            else { //new orientation, landscape
                thumbView.frame = CGRectMake(0, (IS_IPAD?768:320)-20-(IS_IPAD?44:32)-(thumbsShown?height:offset), (IS_IPAD?1024:480), height);
            }
        //}
    }
    else {
        //if (IS_IPAD){
            if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)){ //new orientation, portrait
                thumbView.frame = CGRectMake(0, (IS_IPAD?1024:480)-20-(thumbsShown?height:offset), (IS_IPAD?768:320), height);
            }
            else { //new orientation, landscape
                thumbView.frame = CGRectMake(0, (IS_IPAD?768:320)-20-(thumbsShown?height:offset), (IS_IPAD?1024:480), height);
            }
        //}
    }
    [UIView commitAnimations];
    
    [thumbView setCurrentPage:currentPage];
}

- (void) updateUI {
    [self didRotateFromInterfaceOrientation:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)? UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeLeft];
}

#pragma mark - UIPageViewController datasource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    PageViewController *controller = (PageViewController *)viewController;
    
    [controller didRotateFromInterfaceOrientation:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)? UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeLeft];
    
    int oldPage = controller.page;
    if (oldPage==[oaiRecordHelper getPagesCount]-1)
        return nil;
    
    PageViewController *notesPageController = [[PageViewController alloc]
                                               initWithNibName:@"PageView" bundle:nil oaiRecordHelper:controller.oaiRecordHelper andPage:(oldPage+1)];
    notesPageController.fatherController = self.navigationController;
    notesPageController.readerViewController = self;
    [notesPageController didRotateFromInterfaceOrientation:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)? UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeLeft];
    
    return [notesPageController autorelease];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    PageViewController *controller = (PageViewController *)viewController;
    
    [controller didRotateFromInterfaceOrientation:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)? UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeLeft];
    
    int oldPage = controller.page;
    if (oldPage==0)
        return nil;
    
    PageViewController *notesPageController = [[PageViewController alloc]
                                               initWithNibName:@"PageView" bundle:nil oaiRecordHelper:controller.oaiRecordHelper andPage:(oldPage-1)];
    notesPageController.fatherController = self.navigationController;
    notesPageController.readerViewController = self;
    [notesPageController didRotateFromInterfaceOrientation:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)? UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeLeft];
    
    return [notesPageController autorelease];
}

- (void)pageViewController:(UIPageViewController *)apageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    for (PageViewController *viewcontroller in apageViewController.viewControllers){
        [viewcontroller didRotateFromInterfaceOrientation:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)? UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeLeft];
    }
    
    PageViewController *controller = (PageViewController *)[pageViewController.viewControllers objectAtIndex:0];
    currentPage = controller.page;
    
    [thumbView setCurrentPage:currentPage];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{
    for (PageViewController *viewcontroller in pendingViewControllers){
        [viewcontroller didRotateFromInterfaceOrientation:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)? UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeLeft];
    }
}


#pragma mark - ThumbnailView delegate

- (void)thumbnailView:(ThumbnailView *)thumbnailView didSelectPage:(int)page{
    if (page==currentPage) return;
    
    
    PageViewController *notesPageController = [[PageViewController alloc]
                                               initWithNibName:@"PageView" bundle:nil oaiRecordHelper:oaiRecordHelper andPage:page];
    notesPageController.fatherController = self.navigationController;
    notesPageController.readerViewController = self;
    [notesPageController didRotateFromInterfaceOrientation:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)? UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeLeft];
    
    if (page<currentPage){
        [pageViewController setViewControllers:[NSArray arrayWithObject:[notesPageController autorelease]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
    else {
        [pageViewController setViewControllers:[NSArray arrayWithObject:[notesPageController autorelease]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    currentPage = page;
}

- (void)thumbnailView:(ThumbnailView *)thumbnailView shouldShow:(BOOL)show{

    thumbsShown = show;
    
    [self didRotateFromInterfaceOrientation:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)? UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeLeft];
}

@end
