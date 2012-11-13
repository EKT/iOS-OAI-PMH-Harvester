//
//  ItemListCustomTableViewCell.m
//  enamber
//
//  Created by Konstantinos Stamatis on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "IdentifyCell.h"


@implementation IdentifyCell

@synthesize label, value, imageView, button;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[label release];
	[value release];
	[imageView release];
	[button release];
	
    [super dealloc];
}

-(IBAction)buttonPressed:(id)sender{
	//NSLog(@"Button PRESSED!!!!");
}

@end
