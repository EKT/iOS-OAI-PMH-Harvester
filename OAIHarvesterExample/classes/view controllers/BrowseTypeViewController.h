//
//  BrowseTypeViewController.h
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/24/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "OAIMetadataValue.h"
#import "BrowseValueViewController.h"

@class RecordListViewController;

@interface BrowseTypeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    NSMutableArray *allTypes;
    
    UITableView *tableView;
    
    RecordListViewController *mainController;
}

@property (nonatomic, retain) RecordListViewController *mainController;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
