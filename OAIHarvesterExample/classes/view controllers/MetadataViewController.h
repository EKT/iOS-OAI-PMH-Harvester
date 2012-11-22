//
//  MetadataViewController.h
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/22/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAIRecordHelper.h"
#import "MetadataCell.h"
#import "FastImageView.h"
#import "ReaderViewController.h"

@interface MetadataViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

    OAIRecordHelper *recordHelper;
    NSArray *metadataDictionary;
    
    IBOutlet UIImageView *thumbImageView;
}

@property (nonatomic, retain) NSArray *metadataDictionary;
@property (nonatomic, retain) UIImageView *thumbImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil oaiRecordHelper:(OAIRecordHelper *)oaiRecordHelper;

@end
