//
//  BrowseTypeViewController.m
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/24/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import "BrowseTypeViewController.h"
#import "RecordListViewController.h"

@interface BrowseTypeViewController ()

@end

@implementation BrowseTypeViewController

@synthesize tableView, mainController;

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
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"OAIMetadataValue"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OAIMetadataValue" inManagedObjectContext:oaiApp.managedObjectContext];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"schema" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc]
                                        initWithKey:@"element" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor, sortDescriptor2]];
    
    // Required! Unless you set the resultType to NSDictionaryResultType, distinct can't work.
    // All objects in the backing store are implicitly distinct, but two dictionaries can be duplicates.
    // Since you only want distinct names, only ask for the 'name' property.
    fetchRequest.resultType = NSDictionaryResultType;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:[[entity propertiesByName] objectForKey:@"element"],[[entity propertiesByName] objectForKey:@"schema"], nil];
    fetchRequest.returnsDistinctResults = YES;
    
    // Now it should yield an NSArray of distinct values in dictionaries.
    NSArray *dictionaries = [oaiApp.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
    allTypes = [[NSMutableArray alloc] init];
    for( NSDictionary* obj in dictionaries ) {
            [allTypes addObject:[NSString stringWithFormat:@"%@.%@",[obj objectForKey:@"schema"],[obj objectForKey:@"element"]]];
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
    [allTypes release];
    [mainController release];
    
    [super dealloc];
}

#pragma mark - UITableView Datasource/Delegate

- (int)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [allTypes count];
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
    
    cell.textLabel.text = [allTypes objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BrowseValueViewController *controller = [[BrowseValueViewController alloc] initWithNibName:@"BrowseValueView" bundle:[NSBundle mainBundle] withBrowseType:[allTypes objectAtIndex:indexPath.row]];
    controller.delegate = mainController;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}


@end
