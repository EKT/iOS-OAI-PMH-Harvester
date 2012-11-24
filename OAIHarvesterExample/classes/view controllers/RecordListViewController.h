//
//  RecordListViewController.h
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/11/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAIRecord.h"
#import "OAIMetadataValue.h"
#import "AppDelegate.h"
#import "OAIRecordHelper.h"
#import "RecordCell.h"
#import "FastImageView.h"
#import "PageViewController.h"
#import "ReaderViewController.h"
#import "MetadataViewController.h"
#import "BrowseTypeViewController.h"

@interface RecordListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, BrowseValueDelegate> {
    
    NSArray *allRecords;
    
    UITableView *recordTable;
    UIBarButtonItem *browseBarItem;
    
    UIPopoverController *browsePopOverController;
    
    NSString *browseType;
    NSString *browseValue;
}

@property (nonatomic, retain) NSString *browseType;
@property (nonatomic, retain) NSString *browseValue;

@property (nonatomic, retain) IBOutlet UITableView *recordTable;

@property (nonatomic, retain) NSArray *allRecords;

@end
