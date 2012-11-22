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
    
    //metadata
    NSString *identifier;
    NSString *digitalIdentifier;
}

@property (nonatomic, retain) OAIRecord *oaiRecord;
@property (nonatomic, retain) NSData *thumbnailData;
@property (nonatomic, retain) NSMutableArray *pages;

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *digitalIdentifier;

- (id)initWithOAIRecord:(OAIRecord *)oaiRecord;
- (void) initialize;
- (NSArray *) getMetadataDictionary;

- (NSString *) getTitle;
- (NSString *) getDigitalIdentifier;
- (NSString *) getCreator;
- (NSString *) getDate;
- (NSString *) getIdentifier;
- (NSString *)getPage:(int)page;
- (int) getPagesCount;

@end
