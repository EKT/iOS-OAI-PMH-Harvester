//
//  FastImageView.h
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/12/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAIRecordHelper.h"

@class FastImageView;

@protocol FastImageViewDelegate <NSObject>

- (void)fastImageView:(FastImageView *)fastImageView didLoadImage:(UIImage *)image;

@end

@interface FastImageView : UIImageView{
    OAIRecordHelper *oaiRecordHelper;
    int page;
    int level;
    
    id<FastImageViewDelegate> delegate;
}

@property (nonatomic, retain) id<FastImageViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame forOAIRecord:(OAIRecordHelper *)oaiRecordHelper forPage:(int)page forLevel:(int)level;

@end
