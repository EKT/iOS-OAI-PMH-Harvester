//
//  MetadataViewController.m
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/22/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import "MetadataViewController.h"

@interface MetadataViewController ()

@end

@implementation MetadataViewController

@synthesize metadataDictionary, thumbImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil oaiRecordHelper:(OAIRecordHelper *)oaiRecordHelper
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        recordHelper = [oaiRecordHelper retain];
        self.metadataDictionary = [recordHelper getMetadataDictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(tmp) userInfo:nil repeats:NO];
}

- (void) tmp {
    FastImageView *fastImageView = [[FastImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-50, 10, 100, 128) forOAIRecord:recordHelper forPage:0 forLevel:0];
    fastImageView.contentMode = UIViewContentModeScaleToFill;
    fastImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:fastImageView];
    [fastImageView release];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = fastImageView.frame;
    [self.view addSubview:button];
    [button addTarget:self action:@selector(readerPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    
    [recordHelper release];
    [thumbImageView release];
    
    [super dealloc];
}

- (BOOL) shouldAutorotate{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

#pragma mark - UITableView Datasource/Delegate

- (int)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.metadataDictionary count];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dict = [self.metadataDictionary objectAtIndex:section];
    NSArray *values = [[dict allValues] objectAtIndex:0];
    return [values count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 38;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSDictionary *dict = [self.metadataDictionary objectAtIndex:section];
    NSString *key = [[dict allKeys] objectAtIndex:0];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 38)];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 38)];
    bgImageView.contentMode = UIViewContentModeScaleToFill;
    bgImageView.image = [UIImage imageNamed:@"recent_header_bg.png"];
    [view addSubview:bgImageView];
    [bgImageView release];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-30, 38)];
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(key, @"");
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = [UIColor colorWithRed:95/255.0f green:103/255.0f blue:118/255.0f alpha:1];
    [view addSubview:label];
    [label release];
    
    return [view autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dict = [self.metadataDictionary objectAtIndex:indexPath.section];
    NSArray *values = [[dict allValues] objectAtIndex:0];
    NSString *value = [values objectAtIndex:indexPath.row];
    
	CGSize aSize = [value sizeWithFont:[UIFont systemFontOfSize:12]
                     constrainedToSize:CGSizeMake((self.view.frame.size.width-30), 1000.0)
                         lineBreakMode:UILineBreakModeWordWrap];
    
	return 5+5+aSize.height+20;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.metadataDictionary objectAtIndex:indexPath.section];
    NSArray *values = [[dict allValues] objectAtIndex:0];
    NSString *value = [values objectAtIndex:indexPath.row];
    
	CGSize aSize = [value sizeWithFont:[UIFont systemFontOfSize:12]
                     constrainedToSize:CGSizeMake(self.view.frame.size.width-30, 1000.0)
                         lineBreakMode:UILineBreakModeWordWrap];
    
    MetadataCell *cell = (MetadataCell *)[aTableView dequeueReusableCellWithIdentifier:@"metadata_cell"];
    if (cell == nil) {
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"MetadataCell" bundle:nil];
        cell = (MetadataCell *)temporaryController.view;
        [[cell retain] autorelease];
        [temporaryController release];
    }
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
    bgImageView.contentMode = UIViewContentModeScaleToFill;
    bgImageView.image = [UIImage imageNamed:@"identify_cell_bg.png"];
    cell.backgroundView = bgImageView;
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    [bgImageView release];
    
    CGRect frame = cell.value.frame;
    frame.size.height = aSize.height+20;
    frame.size.width = self.view.frame.size.width -30;
    frame.origin.y = 5;
    [[cell value] setFrame:frame];
    [cell.value setNumberOfLines:20];
    cell.value.lineBreakMode = UILineBreakModeWordWrap;
    //cell.value.backgroundColor = [UIColor yellowColor];
    
    cell.value.text = [NSString stringWithFormat:@"%@", value];
    
    return cell;
}

#pragma mark - Actions

- (void)readerPressed:(UIButton *)sender{
    ReaderViewController *pageViewController = [[ReaderViewController alloc] initWithOAIRecordHelper:recordHelper];
    [self.navigationController pushViewController:pageViewController animated:YES];
    [pageViewController didMoveToParentViewController:self];
    [pageViewController release];
}

@end
