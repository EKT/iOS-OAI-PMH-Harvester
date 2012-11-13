//
//  ItemListCustomTableViewCell.h
//  enamber
//
//  Created by Konstantinos Stamatis on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IdentifyCell : UITableViewCell {

	IBOutlet UILabel *label;
	IBOutlet UILabel *value;
	
	IBOutlet UIImageView *imageView;
	IBOutlet UIButton *button;
	
}

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UILabel *value;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIButton *button;

-(IBAction)buttonPressed:(id)sender;
@end
