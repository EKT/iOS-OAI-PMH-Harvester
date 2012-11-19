//
//  ThumbnailView.m
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/15/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import "ThumbnailView.h"

@implementation ThumbnailView

@synthesize recordHelper, delegate, button;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) dealloc {
    
    [recordHelper release];
    [delegate release];
    [button release];
    
    [super dealloc];
}

- (void)initialize{
    CGRect frame;
    int height = IS_IPAD?200:150;
    int offset = IS_IPAD?50:30;
    
    frame = CGRectMake(0, offset, 768, height);
    
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    
    
    int totalPages = [recordHelper getPagesCount];
    
    int tileWidth=IS_IPAD?120:80;
    
    for (int i=0; i<totalPages; i++){
        UIView *thumbView = [[UIView alloc] initWithFrame:CGRectMake(i*tileWidth, 0, tileWidth, height-offset)];
        thumbView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [scrollView addSubview:thumbView];
        [thumbView release];
        
        FastImageView *imageview = [[FastImageView alloc] initWithFrame:CGRectMake(10, 10, tileWidth-20, height-offset-10-30) forOAIRecord:recordHelper forPage:i forLevel:0];
        [thumbView addSubview:imageview];
        [imageview release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, height-offset-30, tileWidth, 30)];
        label.text = [NSString stringWithFormat:@"σελ. %i", (i+1)];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [thumbView addSubview:label];
        [label release];
        
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        button2.frame = CGRectMake(0, 0, tileWidth, height-offset);
        button2.tag = i;
        [button2 addTarget:self action:@selector(pagePressed:) forControlEvents:UIControlEventTouchUpInside];
        [thumbView addSubview:button2];
    }
    
    scrollView.contentSize = CGSizeMake(tileWidth*totalPages, height-offset);
    [self addSubview:scrollView];
    [scrollView release];
}

- (void)setFrame:(CGRect)theframe{
    [super setFrame:theframe];
    
    CGRect scrollFrame = scrollView.frame;
    scrollFrame.size.width = theframe.size.width;
    scrollView.frame = scrollFrame;
    
    button.frame = CGRectMake(self.frame.size.width-90, 0, 90, IS_IPAD?50:30);
}

- (IBAction)showHidePressed:(UIButton *)sender{
    sender.selected = !sender.selected;
    
    if (delegate && [delegate respondsToSelector:@selector(thumbnailView:shouldShow:)]){
        [delegate thumbnailView:self shouldShow:sender.selected];
    }
}

- (void) pagePressed:(UIButton *)sender{
    int page = sender.tag;
    
    if (delegate && [delegate respondsToSelector:@selector(thumbnailView:didSelectPage:)]){
        [delegate thumbnailView:self didSelectPage:page];
    }
    
    [self setCurrentPage:page];
}

- (void)setCurrentPage:(int)page{
    int tileWidth=IS_IPAD?120:80;
    int width = self.frame.size.width;
    
    int totalPages = [recordHelper getPagesCount];
    
    int x = tileWidth*page - width/2 + tileWidth/2;
    if (x<0)
        x=0;
    else if (totalPages*tileWidth - x < width)
        x = totalPages*tileWidth-width;
    
    [scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

@end
