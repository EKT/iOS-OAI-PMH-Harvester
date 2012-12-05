//
//  RecordGridViewController.h
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 12/2/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "OAIRecordHelper.h"
#import "RecordGridCell.h"
#import "FastImageView.h"
#import "MetadataViewController.h"
#import "GMGridView.h"
#import "BrowseTypeViewController.h"

@interface RecordGridViewController : UIViewController <GMGridViewActionDelegate, GMGridViewDataSource> {
    
    NSArray *allRecords;
    
    NSString *browseType;
    NSString *browseValue;
    
    UIBarButtonItem *browseBarItem;
    
    UIPopoverController *browsePopOverController;
    
    IBOutlet GMGridView *gridView;
}

@property (nonatomic, retain) NSString *browseType;
@property (nonatomic, retain) NSString *browseValue;

@property (nonatomic, retain) NSArray *allRecords;

@end
