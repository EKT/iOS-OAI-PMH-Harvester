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

@interface PageViewController : UIViewController {
    
    int page;
 
    OAIRecordHelper *oaiRecordHelper;
}

@property (nonatomic, assign) int page;
@property (nonatomic, retain) OAIRecordHelper *oaiRecordHelper;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil oaiRecordHelper:(OAIRecordHelper *)oaiRecordHelper andPage:(int)thePage;

@end
