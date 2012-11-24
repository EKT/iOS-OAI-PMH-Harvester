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

@synthesize allRecords, recordTable, browseType, browseValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        browseType = nil;
        browseValue = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    recordTable.delegate = self;
    
    [self fetchAllRecordsFromDB];
    if ([self.allRecords count] == 0){
        [NSThread detachNewThreadSelector:@selector(downloadRecords) toTarget:self withObject:nil];
    }
    
    //Display right bar button
    if (!browseValue && !browseType){
        browseBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Browse" style:UIBarButtonItemStyleBordered target:self action:@selector(browsePressed:)];
        self.navigationItem.rightBarButtonItem = browseBarItem;
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
    [browseBarItem release];
    
    [browsePopOverController release];
    
    [browseType release];
    [browseValue release];
    
    [super dealloc];
}

#pragma mark -

- (void) fetchAllRecordsFromDB{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSFetchRequest * allRecordsRequest = [[NSFetchRequest alloc] init];
    [allRecordsRequest setEntity:[NSEntityDescription entityForName:@"OAIRecord" inManagedObjectContext:oaiApp.managedObjectContext]];
    [allRecordsRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"identifier" ascending:YES];
    [allRecordsRequest setSortDescriptors:@[sortDescriptor]];
    
    
    if (browseType && browseValue){
        NSRange range = [browseType rangeOfString:@"."];
        NSString *schema = [browseType substringToIndex:(range.location)];
        NSString *element = [browseType substringFromIndex:(range.location + 1)];
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(metadata, $b, $b.value CONTAINS[cd] %@ AND $b.element==[cd] %@ AND $b.schema==[cd] %@).@count > 0", browseValue, element, schema];
        
        [allRecordsRequest setPredicate:predicate];
        allRecordsRequest.predicate = predicate;
    }

    
    
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

- (void) fetchRecordsFromDBWithSearch:(NSString *)search{
    NSFetchRequest * allRecordsRequest = [[NSFetchRequest alloc] init];
    [allRecordsRequest setEntity:[NSEntityDescription entityForName:@"OAIRecord" inManagedObjectContext:oaiApp.managedObjectContext]];
    [allRecordsRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    
    if (![search isEqualToString:@""]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(metadata, $b, $b.value CONTAINS[cd] %@).@count > 0", search];
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(metadata, $b, $b.value CONTAINS[cd] %@ AND $b.element==[cd] 'title').@count > 0", search];
        [allRecordsRequest setPredicate:predicate];
        
        //[allRecords filteredArrayUsingPredicate:predicate];
        //[recordTable reloadData];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"identifier" ascending:YES];
    [allRecordsRequest setSortDescriptors:@[sortDescriptor]];
    
    
    
    NSError * error = nil;
    NSArray * records = [[oaiApp.managedObjectContext executeFetchRequest:allRecordsRequest error:&error] retain];
    [allRecordsRequest release];
    
    NSMutableArray *helperArray = [[NSMutableArray alloc] initWithCapacity:[records count]];
    for (OAIRecord *record in records){
        OAIRecordHelper *helper = [[OAIRecordHelper alloc] initWithOAIRecord:record];
        [helperArray addObject:helper];
    }
    [records release];
    
    if (self.allRecords){
        [allRecords release];
        allRecords = nil;
    }
    allRecords = [[helperArray retain] autorelease];
    
    [recordTable reloadData];
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

- (void) browsePressed:(id)sender {
    BrowseTypeViewController *browseTypeController  = [[BrowseTypeViewController alloc] initWithNibName:@"BrowseTypeView" bundle:[NSBundle mainBundle]];
    browseTypeController.mainController = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:browseTypeController];
    browsePopOverController = [[UIPopoverController alloc] initWithContentViewController:navController];
    [browsePopOverController presentPopoverFromBarButtonItem:browseBarItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [navController release];
    [browseTypeController release];
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
    
    MetadataViewController *controller = [[MetadataViewController alloc] initWithNibName:@"MetadataView" bundle:[NSBundle mainBundle] oaiRecordHelper:recordHelper];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    
    /*
    ReaderViewController *pageViewController = [[ReaderViewController alloc] initWithOAIRecordHelper:recordHelper];
    [self.navigationController pushViewController:pageViewController animated:YES];
    [pageViewController didMoveToParentViewController:self];
    */
}

#pragma mark - Search Bar Delegate
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self fetchRecordsFromDBWithSearch:searchText];
}

#pragma mark - BrowseValue Delegate

- (void)didSelectToBrowseByType:(NSString *)type andValue:(NSString *)value{
    [browsePopOverController dismissPopoverAnimated:YES];
    
    RecordListViewController *controller = [[RecordListViewController alloc] initWithNibName:@"RecordListView" bundle:[NSBundle mainBundle]];
    controller.browseType = type;
    controller.browseValue = value;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

@end
