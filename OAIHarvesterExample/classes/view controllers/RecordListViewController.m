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
    
    NSArray *array = [self fetchAllRecordsFromDB];
    if ([array count] == 0){
        [NSThread detachNewThreadSelector:@selector(downloadRecords) toTarget:self withObject:nil];
    }
    self.allRecords = array;
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

- (NSArray *) fetchAllRecordsFromDB{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSFetchRequest * allRecordsRequest = [[NSFetchRequest alloc] init];
    [allRecordsRequest setEntity:[NSEntityDescription entityForName:@"OAIRecord" inManagedObjectContext:oaiApp.managedObjectContext]];
    [allRecordsRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * records = [[oaiApp.managedObjectContext executeFetchRequest:allRecordsRequest error:&error] retain];
    [allRecordsRequest release];
    
    [pool release];
    
    NSMutableArray *helperArray = [[NSMutableArray alloc] initWithCapacity:[records count]];
    for (OAIRecord *record in records){
        OAIRecordHelper *helper = [[OAIRecordHelper alloc] initWithOAIRecord:record];
        [helperArray addObject:helper];
    }
    [records release];
    
    return [helperArray autorelease];
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
    harvester.metadataPrefix = @"ese";
    
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
    OAIRecord *record = recordHelper.oaiRecord;
        
    cell.titleLabel.text = [recordHelper getTitle];
    cell.creatorLabel.text = [recordHelper getCreator];
    cell.dateLabel.text = [recordHelper getDate];
    
    FastImageView *fastImageView = [[FastImageView alloc] initWithFrame:cell.imageView.frame forOAIRecord:recordHelper forPage:0 forLevel:0];
    fastImageView.contentMode = UIViewContentModeScaleToFill;
    [cell addSubview:fastImageView];
    [fastImageView release];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OAIRecordHelper *recordHelper = [allRecords objectAtIndex:indexPath.row];
    
    NSDictionary *options =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                forKey: UIPageViewControllerOptionSpineLocationKey];
    
    UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    pageViewController.dataSource = self;
    pageViewController.delegate = self;
    
    PageViewController *notesPageController = [[PageViewController alloc]
                                                initWithNibName:@"PageView" bundle:nil oaiRecordHelper:recordHelper andPage:0];
    NSArray *pageViewControllers = [NSArray arrayWithObjects:notesPageController, nil];
    [pageViewController setViewControllers:pageViewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];

    
//    [self.view addSubview:pageViewController.view];
//    pageViewController.view.frame = CGRectMake(0, 0, 320, 416);
    [self.navigationController pushViewController:pageViewController animated:YES];
    [pageViewController didMoveToParentViewController:self];
    
  //  [pageViewController release];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    PageViewController *controller = (PageViewController *)viewController;
    
    int oldPage = controller.page;
    //if (oldPage==0)
    //    return nil;
    
    PageViewController *notesPageController = [[PageViewController alloc]
                                               initWithNibName:@"PageView" bundle:nil oaiRecordHelper:controller.oaiRecordHelper andPage:(oldPage+1)];
    
    return [notesPageController autorelease];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    PageViewController *controller = (PageViewController *)viewController;
    
    int oldPage = controller.page;
    if (oldPage==0)
        return nil;
    
    PageViewController *notesPageController = [[PageViewController alloc]
                                               initWithNibName:@"PageView" bundle:nil oaiRecordHelper:controller.oaiRecordHelper andPage:(oldPage-1)];
    
    return [notesPageController autorelease];
}


@end
