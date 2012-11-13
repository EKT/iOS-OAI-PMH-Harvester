//
//  OAIRecordHelper.h
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/12/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAIRecord.h"
#import "OAIMetadataValue.h"

@interface OAIRecordHelper : NSObject {
    
    OAIRecord *oaiRecord;
    
    NSData *thumbnailData;
    int numberOfPages;
    NSMutableArray *pages;
}

@property (nonatomic, retain) OAIRecord *oaiRecord;
@property (nonatomic, retain) NSData *thumbnailData;
@property (nonatomic, retain) NSMutableArray *pages;

- (id)initWithOAIRecord:(OAIRecord *)oaiRecord;

- (NSString *) getTitle;
- (NSString *) getDigitalIdentifier;
- (NSString *) getCreator;
- (NSString *) getDate;
- (NSString *) getIdentifier;
- (NSString *)getPage:(int)page;

@end
