//
//  ItemListCustomTableViewCell.h
//  enamber
//
//  Created by Konstantinos Stamatis on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RecordCell : UITableViewCell {

	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *creatorLabel;
	
	IBOutlet UIImageView *imageView;
	IBOutlet UILabel *dateLabel;
	
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *creatorLabel;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *dateLabel;

-(IBAction)buttonPressed:(id)sender;
@end
