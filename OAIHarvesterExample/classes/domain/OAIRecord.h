//
//  OAIRecord.h
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/11/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OAIMetadataValue;

@interface OAIRecord : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * datestamp;
@property (nonatomic, retain) NSSet *metadata;
@end

@interface OAIRecord (CoreDataGeneratedAccessors)

- (void)addMetadataObject:(OAIMetadataValue *)value;
- (void)removeMetadataObject:(OAIMetadataValue *)value;
- (void)addMetadata:(NSSet *)values;
- (void)removeMetadata:(NSSet *)values;

@end
