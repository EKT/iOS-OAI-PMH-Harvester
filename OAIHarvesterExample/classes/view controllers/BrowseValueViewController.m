//
//  BrowseTypeViewController.m
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/24/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import "BrowseValueViewController.h"
#import "RecordListViewController.h"

@interface BrowseValueViewController ()

@end

@implementation BrowseValueViewController

@synthesize tableView, browseType, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withBrowseType:(NSString *)type
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.browseType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"OAIMetadataValue"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OAIMetadataValue" inManagedObjectContext:oaiApp.managedObjectContext];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"value" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSRange range = [browseType rangeOfString:@"."];
    NSString *schema = [browseType substringToIndex:(range.location)];
    NSString *element = [browseType substringFromIndex:(range.location + 1)];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"element = %@ AND schema = %@", element, schema];
    fetchRequest.predicate = predicate;
    
    // Required! Unless you set the resultType to NSDictionaryResultType, distinct can't work.
    // All objects in the backing store are implicitly distinct, but two dictionaries can be duplicates.
    // Since you only want distinct names, only ask for the 'name' property.
    fetchRequest.resultType = NSDictionaryResultType;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"value"]];
    fetchRequest.returnsDistinctResults = YES;
    
    // Now it should yield an NSArray of distinct values in dictionaries.
    NSArray *dictionaries = [oaiApp.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
    allValues = [[NSMutableArray alloc] init];
    for( NSDictionary* obj in dictionaries ) {
            [allValues addObject:[obj objectForKey:@"value"]];
    }
    
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    
    [tableView release];
    [browseType release];
    [allValues release];
    [delegate release];
    
    [super dealloc];
}

#pragma mark - UITableView Datasource/Delegate

- (int)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [allValues count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"browse_type_cell";//[NSString stringWithFormat:@"identify_cell_%i", indexPath.row];
	
    UITableViewCell *cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [allValues objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (delegate && [delegate respondsToSelector:@selector(didSelectToBrowseByType:andValue:)]){
        [delegate didSelectToBrowseByType:browseType andValue:[allValues objectAtIndex:indexPath.row]];
    }
}


@end
