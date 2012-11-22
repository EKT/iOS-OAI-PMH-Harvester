//
//  PageViewController.h
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/13/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastImageView.h"
#import "OAIRecordHelper.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "ThumbnailView.h"

@class ReaderViewController;

@interface PageViewController : UIViewController <UIScrollViewDelegate, FastImageViewDelegate> {
    
    int page;
 
    OAIRecordHelper *oaiRecordHelper;
    
    UIImage *image;
    FastImageView *imageView;
    UIScrollView *scrollView;
    
    UINavigationController *fatherController;
    ReaderViewController *readerViewController;
    
    BOOL shouldUpdate;
}

@property (nonatomic, assign) BOOL shouldUpdate;

@property (nonatomic, retain) UINavigationController *fatherController;
@property (nonatomic, retain) ReaderViewController *readerViewController;

@property (nonatomic, retain) UIImage *image;

@property (nonatomic, assign) int page;
@property (nonatomic, retain) OAIRecordHelper *oaiRecordHelper;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil oaiRecordHelper:(OAIRecordHelper *)oaiRecordHelper andPage:(int)thePage;

@end
