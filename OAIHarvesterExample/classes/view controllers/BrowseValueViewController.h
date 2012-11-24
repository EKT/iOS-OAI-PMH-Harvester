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

@protocol BrowseValueDelegate <NSObject>

- (void)didSelectToBrowseByType:(NSString *)type andValue:(NSString *)value;

@end

@interface BrowseValueViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    NSString *browseType;
    NSMutableArray *allValues;
    
    UITableView *tableView;
    
    id<BrowseValueDelegate> delegate;
}

@property (nonatomic, retain) id<BrowseValueDelegate> delegate;

@property (nonatomic, retain) NSString *browseType;

@property (nonatomic, retain) IBOutlet UITableView *tableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withBrowseType:(NSString *)type;

@end
