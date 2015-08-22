//
//  SettingsViewController.m
//  Myplex
//
//  Created by shiva on 10/3/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "SettingsViewController.h"
#import "FeedbackViewController.h"
#import "AppData.h"
#import "RESideMenu.h"
#import "AppDelegate.h"
#import "AppWebViewController.h"

@interface SettingsViewController () {
    NSArray *settings;
    AppDelegate *_appDelegate;
}

@end

@implementation SettingsViewController

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
    self.title = @"settings";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    settings = [[NSArray alloc]initWithObjects:@"app settings",@"Viva 2.0", nil];
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
}

#pragma mark TableView DataSource Methods.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return settings.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [settings objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if(section == 1) {
        return 4;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
    //cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	//if(cell == nil)
	//{
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	//}
    
    if (indexPath.section == 0) { //WIFI Only
        if (indexPath.row == 0) {
            cell.textLabel.text = @"synchronize wifi only";
            wifiSwitch = [[UISwitch alloc]init];
            
            isIPhone
                wifiSwitch.frame = CGRectMake(250, 10, 0, 0);
            else
                wifiSwitch.frame = CGRectMake(450, 10, 0, 0);
            
            wifiSwitch.onTintColor = [UIColor colorWithRed:200.0f/255.0f green:16.0f/255.0f blue:26.0f/255.0f alpha:1.0f];
            wifiSwitch.on = YES;
            _appDelegate.synchronizeOnWIFI = wifiSwitch.on;
            [wifiSwitch addTarget:self action:@selector(wifiValueChanged:)
                 forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:wifiSwitch];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    if (indexPath.section == 1) { //Feedback
        if (indexPath.row == 0) {
            cell.textLabel.text = @"feedback";
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"terms & conditions";
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"privacy policy";
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = @"help";
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView *cellSelectedBGView = [[UIView alloc]init];
        cellSelectedBGView.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:16.0f/255.0f blue:26.0f/255.0f alpha:1.0f];
        cell.selectedBackgroundView = cellSelectedBGView;
    }
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) { //WIFI
        //[self logout];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) { //Feedback
        FeedbackViewController *feedbackVC = [[FeedbackViewController alloc]initWithNibName:@"FeedbackViewController" bundle:nil];
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:feedbackVC];
        
        isIPhone
        {
            [self presentViewController:navController animated:YES completion:nil];
        }
        else
        {
            navController.modalPresentationStyle = UIModalPresentationPageSheet;
            navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:navController animated:YES completion:nil];
        }
        
    } else if (indexPath.section == 1 ) {
        AppWebViewController *appWebViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AppWebViewControllerID"];
        if (indexPath.row == 1) {
            appWebViewController.webLink = @"http://help.myplex.com/terms-of-use/";
            appWebViewController.navigationItem.title = @"terms & conditions";
            isIPhone {} else appWebViewController.navigationItem.rightBarButtonItem = UIBarButtonSystemItemDone;
        } else if (indexPath.row == 2) {
            appWebViewController.webLink = @"http://help.myplex.com/privacy-policy/";
            appWebViewController.navigationItem.title = @"privacy policy";
        } else if (indexPath.row == 3) {
            appWebViewController.webLink = @"http://help.myplex.com/";
            appWebViewController.navigationItem.title = @"help";
        }

        isIPhone
            [self.navigationController pushViewController:appWebViewController animated:YES];
        else
        {
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:appWebViewController];
            navController.modalPresentationStyle = UIModalPresentationPageSheet;
            navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
}

-(void)showMenu:(id)sender {
    [self.sideMenu show];  
}

-(void)wifiValueChanged:(UISwitch *)sender
{
    NSLog(@"wifi value = %d", sender.on);
    _appDelegate.synchronizeOnWIFI = sender.on;
    [[AppData shared].data setObject:[NSNumber numberWithBool:_appDelegate.synchronizeOnWIFI] forKey:@"synchronizeOnWIFI"];
}

//For iOS 6
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    } else {
        return NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) closePageSheetWithViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
