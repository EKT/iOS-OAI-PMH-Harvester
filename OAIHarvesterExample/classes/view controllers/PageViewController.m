//
//  PageViewController.m
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/13/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import "PageViewController.h"
#import "ReaderViewController.h"

@interface PageViewController ()

@end

@implementation PageViewController

@synthesize page, oaiRecordHelper, image, fatherController, readerViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil oaiRecordHelper:(OAIRecordHelper *)theOAIRecordHelper andPage:(int)thePage
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        page = thePage;
        self.oaiRecordHelper = theOAIRecordHelper;
    }
    return self;
}

- (void) dealloc {
    
    [oaiRecordHelper release];
    [image release];
    [fatherController release];
    [readerViewController release];
    
    [super dealloc];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self shouldAutorotateToInterfaceOrientation:self.interfaceOrientation];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self shouldAutorotateToInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.autoresizesSubviews = NO;
    
    CGRect frame;
    
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
    
    self.view.frame = frame;
    
    imageView = [[FastImageView alloc] initWithFrame:frame forOAIRecord:oaiRecordHelper forPage:page forLevel:5];
    imageView.delegate = self;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.delegate = self;
    scrollView.minimumZoomScale = scrollView.frame.size.width / imageView.frame.size.width;
    scrollView.maximumZoomScale = 14.0;
    [scrollView setZoomScale:scrollView.minimumZoomScale];
    scrollView.contentSize = imageView.frame.size;
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [UIColor lightGrayColor];
    scrollView.autoresizesSubviews = NO;
    [scrollView release];
    
    [scrollView addSubview:imageView];
    [imageView release];
    
    UITapGestureRecognizer *sTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    sTap.numberOfTapsRequired =1;
    [sTap setDelaysTouchesBegan : YES];
    [scrollView addGestureRecognizer:sTap];
    [sTap release];
    
    UITapGestureRecognizer* dTap = [[UITapGestureRecognizer alloc] initWithTarget : self  action : @selector (doubleTap:)];
    [dTap setDelaysTouchesBegan : YES];
    dTap.numberOfTapsRequired = 2;
    dTap.numberOfTouchesRequired = 1;
    [scrollView addGestureRecognizer : dTap];
    [dTap release];
    
    [sTap requireGestureRecognizerToFail:dTap];
}

#pragma mark - Rotation

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    /*[scrollView setZoomScale:scrollView.minimumZoomScale];
    scrollView.frame = self.view.frame;
    imageView.frame = self.view.frame;
    scrollView.contentSize = imageView.frame.size;*/
    
    /*[UIView beginAnimations: @"moveField"context: nil];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDuration: 0.5];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    */
    
    BOOL hidden = fatherController.navigationBarHidden;
    CGRect frame;
    if (!hidden){
        if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)){
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
        if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)){
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
    [scrollView setZoomScale:scrollView.minimumZoomScale];
    //scrollView.minimumZoomScale = scrollView.frame.size.width / imageView.frame.size.width;
    self.view.frame = frame;
    scrollView.frame = self.view.frame;
    imageView.frame = self.view.frame;
    scrollView.contentSize = imageView.frame.size;
    
    //[UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FastImageView delegate
- (void) fastImageView:(FastImageView *)fastImageView didLoadImage:(UIImage *)image{
    //do nothing
}

#pragma mark - Scroll Delagate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)ascrollView {
    imageView.frame = [self centeredFrameForScrollView:ascrollView andUIView:imageView];;
}

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    return frameToCenter;
}

#pragma mark - UIGestures

- (void) doubleTap : (UIGestureRecognizer*) sender{
    if (scrollView.zoomScale == scrollView.minimumZoomScale) {
        [scrollView setZoomScale:2.0 animated:YES];
    }
    else {
        [scrollView setZoomScale:scrollView.minimumZoomScale animated:YES];
    }
}

- (void) singleTap : (UIGestureRecognizer*) sender{
    [UIView beginAnimations: @"moveField"context: nil];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDuration: 0.5];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    
    BOOL hidden = fatherController.navigationBarHidden;
    CGRect frame;
    if (hidden){
        [fatherController setNavigationBarHidden:NO animated:YES];
        
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
        [fatherController setNavigationBarHidden:YES animated:YES];
        
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
    [scrollView setZoomScale:scrollView.minimumZoomScale];
    //scrollView.minimumZoomScale = scrollView.frame.size.width / imageView.frame.size.width;
    self.view.frame = frame;
    scrollView.frame = self.view.frame;
    imageView.frame = self.view.frame;
    scrollView.contentSize = imageView.frame.size;
    
    [readerViewController updateUI];
    
    [UIView commitAnimations];
}

@end
