//
//  ViewController.h
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/1/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IdentifyCell.h"
#import "IdentifyButtonCell.h"
#import "RecordListViewController.h"

@interface IdentifyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
 
    OAIHarvester *harvester;
    UITableView *listTableView;
    
}

@property (nonatomic, retain) IBOutlet UITableView *listTableView;

@property (nonatomic, retain) OAIHarvester *harvester;

@end
