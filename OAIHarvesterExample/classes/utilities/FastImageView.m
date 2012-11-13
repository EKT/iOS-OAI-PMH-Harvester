//
//  FastImageView.m
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/12/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import "FastImageView.h"

@implementation FastImageView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame forOAIRecord:(OAIRecordHelper *)theOAIRecordHelper forPage:(int)thePage forLevel:(int)theLevel
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        oaiRecordHelper = [theOAIRecordHelper retain];
        page = thePage;
        level = theLevel;
        //[self loadImage];
        [NSThread detachNewThreadSelector:@selector(loadImage) toTarget:self withObject:nil];
    }
    return self;
}

- (void) dealloc{
    
    [oaiRecordHelper release];
    [delegate release];
    
    [super dealloc];
}

- (void) loadImage{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *basePath = [NSString stringWithFormat:@"%@/%@/imagecache", APP_CACHE_FOLDER, [oaiRecordHelper getIdentifier]];
    if (![fileManager fileExistsAtPath:basePath]){
        NSError *error = nil;
        //Create base path
        [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@/imagecache/p%i_l%i.jpg", APP_CACHE_FOLDER, [oaiRecordHelper getIdentifier], page, level];
    if ([fileManager fileExistsAtPath:imagePath]){
        self.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
    }
    else {
        NSString *urlString = [NSString stringWithFormat:URL_PAGE, [oaiRecordHelper getDigitalIdentifier], [oaiRecordHelper getPage:page], level];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        // [self performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithData:data] waitUntilDone:YES];
        self.image = [UIImage imageWithData:data];
        [data writeToFile:imagePath atomically:YES];
    }
    
    if (delegate && [delegate respondsToSelector:@selector(fastImageView:didLoadImage:)]){
        [delegate fastImageView:self didLoadImage:self.image];
    }
    
    [pool release];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
