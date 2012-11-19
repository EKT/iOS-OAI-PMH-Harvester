//
//  RecordListViewController.m
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/11/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import "RecordListViewController.h"

@interface RecordListViewController ()

@end

@implementation RecordListViewController

@synthesize allRecords, recordTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    recordTable.delegate = self;
    
    [self fetchAllRecordsFromDB];
//    [self performSelectorOnMainThread:@selector(fetchAllRecordsFromDB) withObject:nil waitUntilDone:YES];
    if ([self.allRecords count] == 0){
        [NSThread detachNewThreadSelector:@selector(downloadRecords) toTarget:self withObject:nil];
    }
}

#pragma mark - Rotation

- (BOOL) shouldAutorotate{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

//iOS5 support
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [allRecords release];
    [recordTable release];
    
    [super dealloc];
}

#pragma mark -

- (void) fetchAllRecordsFromDB{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSFetchRequest * allRecordsRequest = [[NSFetchRequest alloc] init];
    [allRecordsRequest setEntity:[NSEntityDescription entityForName:@"OAIRecord" inManagedObjectContext:oaiApp.managedObjectContext]];
    [allRecordsRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * records = [[oaiApp.managedObjectContext executeFetchRequest:allRecordsRequest error:&error] retain];
    [allRecordsRequest release];
    
    //[pool release];
    
    NSMutableArray *helperArray = [[NSMutableArray alloc] initWithCapacity:[records count]];
    for (OAIRecord *record in records){
        OAIRecordHelper *helper = [[OAIRecordHelper alloc] initWithOAIRecord:record];
        [helperArray addObject:helper];
    }
    [records release];
    
    self.allRecords = [helperArray autorelease];
}

- (void) deleteAllRecordsFromDB{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSFetchRequest * allRecordsRequest = [[NSFetchRequest alloc] init];
    [allRecordsRequest setEntity:[NSEntityDescription entityForName:@"OAIRecord" inManagedObjectContext:oaiApp.managedObjectContext]];
    [allRecordsRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * records = [oaiApp.managedObjectContext executeFetchRequest:allRecordsRequest error:&error];
    [allRecords release];
    //error handling goes here
    
    for (NSManagedObject * record in records) {
        [oaiApp.managedObjectContext deleteObject:record];
    }
    NSError *saveError = nil;
    [oaiApp.managedObjectContext save:&saveError];
    
    [pool release];
}

- (void) downloadRecords{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    OAIHarvester *harvester = [[OAIHarvester alloc] initWithBaseURL:APP_BASE_URL];
    harvester.metadataPrefix = APP_BASE_METADATA_PREFIX;
    
    NSError *error = nil;
    NSArray *newrecords = [harvester listAllRecordsWithError:&error];
    
    if (error){
        
        return;
    }
    
    error = nil;
    
    for (Record *record in newrecords){
        
        OAIRecord *oaiRecord = [NSEntityDescription insertNewObjectForEntityForName:@"OAIRecord" inManagedObjectContext:oaiApp.managedObjectContext];
        oaiRecord.identifier = record.recordHeader.identifier;
        oaiRecord.datestamp = record.recordHeader.datestamp;
        
        for (MetadataElement *metadataElement in record.recordMetadata.metadataElements){
            OAIMetadataValue *oaiMetadataValue = [NSEntityDescription insertNewObjectForEntityForName:@"OAIMetadataValue" inManagedObjectContext:oaiApp.managedObjectContext];
            
            oaiMetadataValue.record = oaiRecord;
            oaiMetadataValue.schema = metadataElement.prefix;
            oaiMetadataValue.value = metadataElement.value;
            oaiMetadataValue.element = metadataElement.name;
        }
    }
    
    [oaiApp performSelectorOnMainThread:@selector(saveContextWithError:) withObject:error waitUntilDone:NO];
    
    if (error){
        NSLog(@"error = %@", [error localizedDescription]);
    }
    
    [pool release];
}

#pragma mark - UITableView Datasource/Delegate

- (int)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [allRecords count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"record_cell";//[NSString stringWithFormat:@"identify_cell_%i", indexPath.row];
	
    RecordCell *cell = (RecordCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"RecordCell" bundle:nil];
        cell = (RecordCell *)temporaryController.view;
        [[cell retain] autorelease];
        [temporaryController release];
    }
    
    OAIRecordHelper *recordHelper = [allRecords objectAtIndex:indexPath.row];
    [recordHelper initialize];
    //OAIRecord *record = recordHelper.oaiRecord;
        
    cell.titleLabel.text = [recordHelper getTitle];
    cell.creatorLabel.text = [recordHelper getCreator];
    cell.dateLabel.text = [recordHelper getDate];
    
    FastImageView *fastImageView = [[FastImageView alloc] initWithFrame:cell.imageView.frame forOAIRecord:recordHelper forPage:0 forLevel:0];
    fastImageView.contentMode = UIViewContentModeScaleToFill;
    [cell addSubview:fastImageView];
    [fastImageView release];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OAIRecordHelper *recordHelper = [allRecords objectAtIndex:indexPath.row];
    
    ReaderViewController *pageViewController = [[ReaderViewController alloc] initWithOAIRecordHelper:recordHelper];
    [self.navigationController pushViewController:pageViewController animated:YES];
    [pageViewController didMoveToParentViewController:self];
    
}



@end
