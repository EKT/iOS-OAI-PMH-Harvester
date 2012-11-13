//
//  OAIMetadataValue.h
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/11/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OAIRecord;

@interface OAIMetadataValue : NSManagedObject

@property (nonatomic, retain) NSString * schema;
@property (nonatomic, retain) NSString * element;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) OAIRecord *record;

@end
