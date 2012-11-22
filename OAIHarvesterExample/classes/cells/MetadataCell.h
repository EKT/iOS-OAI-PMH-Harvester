//
//  ItemListCustomTableViewCell.h
//  enamber
//
//  Created by Konstantinos Stamatis on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MetadataCell : UITableViewCell {

	IBOutlet UILabel *value;
	
	IBOutlet UIImageView *imageView;	
}

@property (nonatomic, retain) UILabel *value;
@property (nonatomic, retain) UIImageView *imageView;

-(IBAction)buttonPressed:(id)sender;
@end
