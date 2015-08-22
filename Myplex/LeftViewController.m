//
//  LeftViewController.m
//  Myplex
//
//  Created by Igor Ostriz on 8/28/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "LeftViewController.h"

#import "SWRevealViewController.h"
#import "CardsViewController.h"
#import "MainNavigationController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GooglePlus/GooglePlus.h"
#import "AppData.h"
#import "SWRevealViewController.h"
#import "SettingsViewController.h"

@interface LeftViewController () {
    IBOutlet UITableView *menuTable;
    NSArray *menuItems;
    NSArray *menuImages;
}

@end

@implementation LeftViewController

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
    
    menuItems = [[NSArray alloc]initWithObjects:@"Profile",@"Movies",@"Live TV",@"Favorites",@"Settings", nil];
    menuImages = [[NSArray alloc]initWithObjects:@"",@"",@"",@"heart",@"", nil];
}

#pragma mark TableView DataSource Methods.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return menuItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 200;
    }
	return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    UIImageView *profileImageView = nil;;
	if(cell == nil)
	{
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        UIImageView *profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(80, 10, 160, 80)];
        profileImageView.tag = 1;
        [cell.contentView addSubview:profileImageView];
	}
    
    if (!profileImageView) {
        profileImageView = (UIImageView *)[cell.contentView viewWithTag:1];
    }
    if (indexPath.row == 0) {
        profileImageView.hidden = NO;
        profileImageView.image = [UIImage imageNamed:@""];
        cell.imageView.image = nil;
    } else {
        profileImageView.hidden = YES;
        cell.imageView.image = [UIImage imageNamed:[menuImages objectAtIndex:indexPath.row]];
        [cell.textLabel setText:[menuItems objectAtIndex:indexPath.row]];
         cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[menuItems objectAtIndex:indexPath.row] isEqualToString:@"Movies"] || [[menuItems objectAtIndex:indexPath.row] isEqualToString:@"Live TV"]|| [[menuItems objectAtIndex:indexPath.row] isEqualToString:@"Favorites"]) {
        MainNavigationController *mnc = (MainNavigationController*)[self revealViewController].frontViewController;
        [mnc popToRootViewControllerAnimated:YES];
    } else if([[menuItems objectAtIndex:indexPath.row] isEqualToString:@"Settings"]) {
        SWRevealViewController *revealController = self.revealViewController;
        
        SettingsViewController *settingsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsViewControllerID"];
        
        MainNavigationController *mnc = (MainNavigationController*)[self revealViewController].frontViewController;
        [mnc pushViewController:settingsVC animated:YES];
        //UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
        //settingsVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleBordered target:self action:@selector(showMenu:)];
        [revealController setFrontViewController:mnc animated:YES];
    }
    [[self revealViewController] revealToggle:nil];
}

//-(void)showMenu:(id)sender {
//    [self.revealViewController revealToggle:nil];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)logout:(UIButton *)sender
{
    //[Flurry logEvent:@"LoggedOut"];

    [FBSession.activeSession closeAndClearTokenInformation];
    
    [[GPPSignIn sharedInstance] signOut];
    
    [[[AppData shared]data]setObject:[NSNumber numberWithBool:NO] forKey:@"stayLoggedIn"];
    [[AppData shared]save];
    
    [self.revealViewController revealToggleAnimated:YES];

    MainNavigationController *mnc = (MainNavigationController*)[self revealViewController].frontViewController;
    [mnc fullRefresh:YES];
}

@end
