//
//  MyPageViewController.h
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/15/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbnailView.h"
#import "PageViewController.h"
#import "OAIRecordHelper.h"

@interface ReaderViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, ThumbnailViewDelegate> {
    
    ThumbnailView *thumbView;
    OAIRecordHelper *oaiRecordHelper;
    UIPageViewController *pageViewController;
    
    int currentPage;
    BOOL thumbsShown;
}

@property (nonatomic, retain) OAIRecordHelper *oaiRecordHelper;
@property (nonatomic, retain) ThumbnailView *thumbView;

- (id)initWithOAIRecordHelper:(OAIRecordHelper *)oaiRecordHelper;
- (void) updateUI;

@end
