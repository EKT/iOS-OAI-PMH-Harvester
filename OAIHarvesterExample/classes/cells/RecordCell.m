//
//  ItemListCustomTableViewCell.m
//  enamber
//
//  Created by Konstantinos Stamatis on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RecordCell.h"


@implementation RecordCell

@synthesize titleLabel, dateLabel, creatorLabel, imageView;

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
	[titleLabel release];
	[dateLabel release];
	[imageView release];
	[creatorLabel release];
	
    [super dealloc];
}

-(IBAction)buttonPressed:(id)sender{
	//NSLog(@"Button PRESSED!!!!");
}

@end
