//
//  ThumbnailView.h
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/15/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAIRecordHelper.h"
#import "FastImageView.h"

@class ThumbnailView;

@protocol ThumbnailViewDelegate <NSObject>

- (void)thumbnailView:(ThumbnailView *)thumbnailView didSelectPage:(int)page;
- (void)thumbnailView:(ThumbnailView *)thumbnailView shouldShow:(BOOL)show;

@end

@interface ThumbnailView : UIView {
    
    UIScrollView *scrollView;
    UIButton *button;
    
    OAIRecordHelper *recordHelper;
    
    id<ThumbnailViewDelegate> delegate;
}

@property (nonatomic, retain) id<ThumbnailViewDelegate> delegate;
@property (nonatomic, retain) OAIRecordHelper *recordHelper;
@property (nonatomic, retain) IBOutlet UIButton *button;

- (void)initialize;
- (void)setCurrentPage:(int)page;

- (IBAction)showHidePressed:(UIButton *)sender;

@end
