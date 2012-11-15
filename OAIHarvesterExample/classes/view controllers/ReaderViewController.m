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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSDictionary *options =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                forKey: UIPageViewControllerOptionSpineLocationKey];
    
    pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    pageViewController.dataSource = self;
    pageViewController.delegate = self;
    
    PageViewController *notesPageController = [[PageViewController alloc]
                                               initWithNibName:@"PageView" bundle:nil oaiRecordHelper:oaiRecordHelper andPage:0];
    notesPageController.fatherController = self.navigationController;
    NSArray *pageViewControllers = [NSArray arrayWithObjects:notesPageController, nil];
    [pageViewController setViewControllers:pageViewControllers
                                 direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    [self.view addSubview:pageViewController.view];
    if (IS_IPHONE){
        CGRect frame = pageViewController.view.frame;
        frame.origin.y -= 20;
    //frame.size.height +=40;
        pageViewController.view.frame = frame;
    }
    
    //Add the thumbnails view
    UIViewController *thumbController = [[UIViewController alloc] initWithNibName:@"ThumbnailView" bundle:[NSBundle mainBundle]];
    self.thumbView = (ThumbnailView *)thumbController.view;
    thumbView.frame = CGRectMake(0, 300, 516, 159);
    //[self.view addSubview:thumbView];
    [thumbController release];
    
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
        [viewcontroller didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

#pragma mark - UIPageViewController datasource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    PageViewController *controller = (PageViewController *)viewController;
    
    int oldPage = controller.page;
    //if (oldPage==0)
    //    return nil;
    
    PageViewController *notesPageController = [[PageViewController alloc]
                                               initWithNibName:@"PageView" bundle:nil oaiRecordHelper:controller.oaiRecordHelper andPage:(oldPage+1)];
    notesPageController.fatherController = self.navigationController;
    
    return [notesPageController autorelease];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    PageViewController *controller = (PageViewController *)viewController;
    
    int oldPage = controller.page;
    if (oldPage==0)
        return nil;
    
    PageViewController *notesPageController = [[PageViewController alloc]
                                               initWithNibName:@"PageView" bundle:nil oaiRecordHelper:controller.oaiRecordHelper andPage:(oldPage-1)];
    notesPageController.fatherController = self.navigationController;
    
    return [notesPageController autorelease];
}

- (void)pageViewController:(UIPageViewController *)apageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    for (PageViewController *viewcontroller in apageViewController.viewControllers){
        [viewcontroller didRotateFromInterfaceOrientation:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)? UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeLeft];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{
    for (PageViewController *viewcontroller in pendingViewControllers){
        [viewcontroller didRotateFromInterfaceOrientation:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)? UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeLeft];
    }
}


@end
