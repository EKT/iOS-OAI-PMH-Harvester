//
//  RecordGridViewController.m
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 12/2/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import "RecordGridViewController.h"

@interface RecordGridViewController ()

@end

@implementation RecordGridViewController

@synthesize allRecords, browseType, browseValue;

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
    
    [self fetchAllRecordsFromDB];
    if ([self.allRecords count] == 0){
        [NSThread detachNewThreadSelector:@selector(downloadRecords) toTarget:self withObject:nil];
    }
    
    //if ([allRecords count]<=4)
        gridView.centerGrid = NO;
    //else
    //    gridView.centerGrid = YES;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        gridView.minEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    else
        gridView.minEdgeInsets = UIEdgeInsetsMake(0, 45, 0, 0);
    [gridView reloadData];
    
    //Display right bar button
    if (!browseValue && !browseType){
        browseBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Browse" style:UIBarButtonItemStyleBordered target:self action:@selector(browsePressed:)];
        self.navigationItem.rightBarButtonItem = browseBarItem;
    }
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [allRecords release];
    [browseBarItem release];
    
    [browsePopOverController release];
    
    [browseType release];
    [browseValue release];
    
    [super dealloc];
}

#pragma mark - Rotation

- (BOOL) shouldAutorotate{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

//iOS5 support
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        gridView.minEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    else
        gridView.minEdgeInsets = UIEdgeInsetsMake(0, 45, 0, 0);
    [gridView reloadData];
}

#pragma mark -

- (void) fetchAllRecordsFromDB{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSFetchRequest *allRecordsRequest = [[NSFetchRequest alloc] init];
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
    
    
    [gridView reloadData];
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

#pragma mark - GMGridView
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [allRecords count];
}

- (CGSize)GMGridView:(GMGridView *)agridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(180, 256);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)agridView cellForItemAtIndex:(NSInteger)index
{
    RecordGridCell *cell = (RecordGridCell *)[agridView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"dsadsds_%i", index]];
    if (cell == nil) {
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"RecordGridCell" bundle:nil];
        cell = (RecordGridCell *)temporaryController.view;
        [[cell retain] autorelease];
        [temporaryController release];
    }
    
    OAIRecordHelper *recordHelper = [allRecords objectAtIndex:index];
    [recordHelper initialize];
    
    cell.titleLabel.text = [recordHelper getTitle];
     cell.creatorLabel.text = [recordHelper getCreator];
     cell.dateLabel.text = [recordHelper getDate];
    
    FastImageView *fastImageView = [[FastImageView alloc] initWithFrame:cell.imageView.frame forOAIRecord:recordHelper forPage:0 forLevel:0];
     fastImageView.contentMode = UIViewContentModeScaleToFill;
     [cell addSubview:fastImageView];
     [fastImageView release];
    
    return cell;
}

- (void)GMGridView:(GMGridView *)agridView didTapOnItemAtIndex:(NSInteger)position
{
    OAIRecordHelper *recordHelper = [allRecords objectAtIndex:position];
    
    MetadataViewController *controller = [[MetadataViewController alloc] initWithNibName:@"MetadataView" bundle:[NSBundle mainBundle] oaiRecordHelper:recordHelper];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

#pragma mark - Search Bar Delegate
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self fetchRecordsFromDBWithSearch:searchText];
}

#pragma mark - BrowseValue Delegate

- (void)didSelectToBrowseByType:(NSString *)type andValue:(NSString *)value{
    [browsePopOverController dismissPopoverAnimated:YES];
    
    RecordGridViewController *controller = [[RecordGridViewController alloc] initWithNibName:@"RecordGridView" bundle:[NSBundle mainBundle]];
    controller.browseType = type;
    controller.browseValue = value;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

@end
