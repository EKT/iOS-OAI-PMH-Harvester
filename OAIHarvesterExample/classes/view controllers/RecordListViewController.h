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

@interface RecordListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    NSArray *allRecords;
    
    UITableView *recordTable;
    
}

@property (nonatomic, retain) IBOutlet UITableView *recordTable;

@property (nonatomic, retain) NSArray *allRecords;

@end
