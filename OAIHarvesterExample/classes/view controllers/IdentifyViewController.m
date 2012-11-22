//
//  ViewController.m
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/1/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import "IdentifyViewController.h"

@interface IdentifyViewController ()

@end

@implementation IdentifyViewController

@synthesize harvester, listTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBar.tintColor = APP_BASE_COLOR;
    self.title = NSLocalizedString(@"Identify", @"");
    
    listTableView.delegate = self;
    
    self.harvester = [[[OAIHarvester alloc] initWithBaseURL:APP_BASE_URL] autorelease];
    harvester.metadataPrefix = @"oai_dc";
}

#pragma mark - Memory management

- (void) dealloc{
    
    [harvester release];
    [listTableView release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - UITableView Datasource/Delegate

- (int)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row>5) return 45;
    
    NSString *displayValue = nil;
    
    switch (indexPath.row) {
        case 0:
            displayValue = harvester.identify.repositoryName;
            break;
        case 1:
            displayValue = harvester.identify.baseURL;
            break;
        case 2:
            displayValue = harvester.identify.protocolVersion;
            break;
        case 3:
            displayValue = [harvester.identify.adminEmails objectAtIndex:0];
            break;
        case 4:
            displayValue = harvester.identify.earliestDatestamp;
            break;
        case 5:
            displayValue = harvester.identify.granularity;
            break;
        default:
            break;
    }
    
	CGSize aSize = [displayValue sizeWithFont:[UIFont systemFontOfSize:12]
							constrainedToSize:CGSizeMake(304.0, 1000.0)
								lineBreakMode:UILineBreakModeWordWrap];
    
	return 5+5+15+5+aSize.height;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"identify_cell_%i", indexPath.row];
	
    NSString *displayValue = nil;
    NSString *displayLabel = nil;
    
    switch (indexPath.row) {
        case 0:
            displayLabel = @"[Repository Name]";
            displayValue = harvester.identify.repositoryName;
            break;
        case 1:
            displayLabel = @"[Base URL]";
            displayValue = harvester.identify.baseURL;
            break;
        case 2:
            displayLabel = @"[Protocol Version]";
            displayValue = harvester.identify.protocolVersion;
            break;
        case 3:
            displayLabel = @"[Admin Email]";
            displayValue = [harvester.identify.adminEmails objectAtIndex:0];
            break;
        case 4:
            displayLabel = @"[Earliest Datestamp]";
            displayValue = harvester.identify.earliestDatestamp;
            break;
        case 5:
            displayLabel = @"[Granularity]";
            displayValue = harvester.identify.granularity;
            break;
        default:
            break;
    }
    
    if (indexPath.row<=5){
        IdentifyCell *cell = (IdentifyCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"IdentifyCell" bundle:nil];
            cell = (IdentifyCell *)temporaryController.view;
            [[cell retain] autorelease];
            [temporaryController release];
        }
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
        bgImageView.contentMode = UIViewContentModeScaleToFill;
        bgImageView.image = [UIImage imageNamed:@"identify_cell_bg.png"];
        cell.backgroundView = bgImageView;
        cell.backgroundView.backgroundColor = [UIColor clearColor];
        [bgImageView release];
        
        
        cell.label.font = [UIFont systemFontOfSize:12];
        cell.label.textColor = APP_BASE_COLOR;
        cell.label.text = displayLabel;
        //cell.label.backgroundColor = [UIColor grayColor];
        
        CGSize aSize = [displayValue sizeWithFont:[UIFont systemFontOfSize:12]
                                constrainedToSize:CGSizeMake(304.0, 1000.0)
                                    lineBreakMode:UILineBreakModeWordWrap];
        
        CGRect frame = cell.value.frame;
        frame.size.height = aSize.height;
        [[cell value] setFrame:frame];
        [cell.value setNumberOfLines:20];
        //cell.value.backgroundColor = [UIColor yellowColor];
        
        cell.value.text = [NSString stringWithFormat:@"%@", displayValue];
        
        
        return cell;
    }
    else {
        IdentifyButtonCell *cell = (IdentifyButtonCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"IdentifyButtonCell" bundle:nil];
            cell = (IdentifyButtonCell *)temporaryController.view;
            [[cell retain] autorelease];
            [temporaryController release];
        }
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
        bgImageView.contentMode = UIViewContentModeScaleToFill;
        bgImageView.image = [UIImage imageNamed:@"identify_cell_bg.png"];
        cell.backgroundView = bgImageView;
        cell.backgroundView.backgroundColor = [UIColor clearColor];
        [bgImageView release];
    
        cell.value.text = @"List Records";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
        return cell;
    }
    
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row==6){
        RecordListViewController *controller = [[RecordListViewController alloc] initWithNibName:@"RecordListView" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
}

@end
