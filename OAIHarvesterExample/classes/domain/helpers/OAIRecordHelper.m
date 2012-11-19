//
//  OAIRecordHelper.m
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/12/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import "OAIRecordHelper.h"

@interface OAIRecordHelper()

- (NSString *) getMetadataValueForSchema:(NSString *)schema andElement:(NSString *)element;

@end

@implementation OAIRecordHelper

@synthesize oaiRecord, thumbnailData, pages, identifier, digitalIdentifier;

- (id)initWithOAIRecord:(OAIRecord *)theOAIRecord{
    if (self = [super init]){
        self.oaiRecord = theOAIRecord;
        self.thumbnailData = nil;
        self.pages = nil;
        
        self.identifier = [self getIdentifier];
        self.digitalIdentifier = [self getDigitalIdentifier];
    }
    return self;
}

- (void) dealloc{
    
    [oaiRecord release];
    [thumbnailData release];
    [pages release];
    
    [identifier release];
    [digitalIdentifier release];
    
    [super dealloc];
}

- (NSString *) getTitle{
    return [self getMetadataValueForSchema:@"dc" andElement:@"title"];
}

- (NSString *) getCreator{
    return [self getMetadataValueForSchema:@"dc" andElement:@"creator"];
}

- (NSString *) getDate{
    return [self getMetadataValueForSchema:@"dc" andElement:@"date"];
}

- (NSString *) getIdentifier{
    //return [self getMetadataValueForSchema:@"dc" andElement:@"digitalidentofier"];
    NSString *identifier = [self getMetadataValueForSchema:@"dc" andElement:@"identifier"];
    
    NSRange range = [identifier rangeOfString:@"/" options:NSBackwardsSearch];
    return [identifier substringFromIndex:(range.location+1)];
}

- (NSString *) getDigitalIdentifier{
    NSString *isShownBy = [self getMetadataValueForSchema:@"europeana" andElement:@"isShownBy"];
    
    NSRange range = [isShownBy rangeOfString:@"=" options:NSBackwardsSearch];
    
    return [isShownBy substringFromIndex:(range.location+1)];
}

- (NSString *) getMetadataValueForSchema:(NSString *)schema andElement:(NSString *)element{
    NSLog(@"element = %@", element);
    assert([NSThread isMainThread]);
    for (OAIMetadataValue *metadataValue in oaiRecord.metadata){
        if ([metadataValue.element isEqualToString:element] && [metadataValue.schema isEqualToString:schema]){
            return metadataValue.value;
        }
    }
    
    return @"---";
}

- (int) getPagesCount{
    if (!self.pages){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *basePath = [NSString stringWithFormat:@"%@/%@", APP_CACHE_FOLDER, self.identifier];
        if (![fileManager fileExistsAtPath:basePath]){
            NSError *error = nil;
            //Create base path
            [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        NSString *bookPath = [NSString stringWithFormat:@"%@/%@/book.txt", APP_CACHE_FOLDER, self.identifier];
        if (![fileManager fileExistsAtPath:bookPath]){
            //Must download book.txt and read it!
            NSData *bookTxtData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:URL_BOOK_TXT, self.digitalIdentifier]]];
            [bookTxtData writeToFile:bookPath atomically:YES];
        }
        
        NSString *contents = [NSString stringWithContentsOfFile:bookPath encoding:NSUTF8StringEncoding error:nil];
        NSMutableArray *lines = [NSMutableArray arrayWithArray:[contents componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]]];
        
        numberOfPages = [[lines objectAtIndex:0] intValue];
        [lines removeObjectAtIndex:0];
        
        NSMutableArray *allPages = [[NSMutableArray alloc] initWithCapacity:numberOfPages];
        for (NSString* line in lines) {
            if (line.length) {
                [allPages addObject:line];
            }
        }
        
        self.pages = allPages;
        [allPages release];
        
        return [self.pages count];
    }
    else {
        return [self.pages count];
    }
}

- (NSString *)getPage:(int)page {
    if (!self.pages){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *basePath = [NSString stringWithFormat:@"%@/%@", APP_CACHE_FOLDER, self.identifier];
        if (![fileManager fileExistsAtPath:basePath]){
            NSError *error = nil;
            //Create base path
            [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        NSString *bookPath = [NSString stringWithFormat:@"%@/%@/book.txt", APP_CACHE_FOLDER, self.identifier];
        if (![fileManager fileExistsAtPath:bookPath]){
            //Must download book.txt and read it!
            NSData *bookTxtData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:URL_BOOK_TXT, self.digitalIdentifier]]];
            [bookTxtData writeToFile:bookPath atomically:YES];
        }
        
        NSString *contents = [NSString stringWithContentsOfFile:bookPath encoding:NSUTF8StringEncoding error:nil];
        NSMutableArray *lines = [NSMutableArray arrayWithArray:[contents componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]]];
        
        numberOfPages = [[lines objectAtIndex:0] intValue];
        [lines removeObjectAtIndex:0];
        
        NSMutableArray *allPages = [[NSMutableArray alloc] initWithCapacity:numberOfPages];
        for (NSString* line in lines) {
            if (line.length) {
                [allPages addObject:line];
            }
        }
        
        self.pages = allPages;
        [allPages release];
        
        return [self.pages objectAtIndex:page];
    }
    else {
        return [self.pages objectAtIndex:page];
    }
}

@end
