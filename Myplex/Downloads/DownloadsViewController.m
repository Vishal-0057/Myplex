//
//  DownloadsViewController.m
//  Myplex
//
//  Created by shiva on 10/3/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "DownloadsViewController.h"
#import "RESideMenu.h"
#import "NSManagedObjectContext+Utils.h"
#import "Download.h"
#import "Notifications.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "UIAlertView+Blocks.h"
#import "CardsViewController.h"
#import "ToastMessageView.h"
//#import "CardDetailsViewController.h"
#import "NSManagedObject+Utils.h"
#import "CardDetailsViewController.h"
#import "UIColor+Hex.h"

@interface DownloadsViewController ()

@end

@implementation DownloadsViewController {
    CGFloat _progressValue;
    UIProgressView *_progressView;
    UILabel *_status;
}

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
    TCSTART
    [super viewDidLoad];
    self.title = @"downloads";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTable:) name:kNotificationRefreshSomething object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloadStarted:) name:kNotificationDownloadStarted object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloadPaused:) name:kNotificationDownloadPaused object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloadResumed:) name:kNotificationDownloadResumed object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloadFinished:) name:kNotificationDownloadFinished object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloadFailed:) name:kNotificationDownloadFailed object:nil];
    
    TCEND
}

-(void)viewWillAppear:(BOOL)animated {
    TCSTART
    [super viewWillAppear:YES];
    
    self.navigationController.delegate = nil;

    [self loadDownloads];
    
    if ((!self.downloadedVideos || self.downloadedVideos.count == 0) && [self.navigationController.topViewController isKindOfClass:[DownloadsViewController class]]) {
        NSString *title = @"myplex";
        
        [UIAlertView alertViewWithTitle:title message:kNoDownloadsMessage cancelBlock:^(int buttonIndex) {
#if DEBUG
            NSLog(@"Trending content...");
#endif
            isIPhone
                [self showMenu:nil];
            else
                [self closePageSheetWithViewController];

        } dismissBlock:^(int buttonIndex) {
        } cancelButtonTitle:@"discover trending content?" otherButtonsTitles:nil, nil];
    }
    downloadsTableView.delegate = self;
    [downloadsTableView reloadData];
    TCEND
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    //[self.navigationController popViewControllerAnimated:NO];
}

-(void)loadDownloads
{
    TCSTART
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.downloadedVideos = [[NSMutableArray alloc]initWithArray:[appDelegate.managedObjectContext fetchObjectsForEntityName:@"Download" withPredicate:nil]];
    TCEND
}

-(void)showMenu:(id)sender {
    TCSTART
    //downloadsTableView.delegate = nil;
    [self.sideMenu show];
    TCEND
}

-(void)reloadTable:(NSNotification *)notification {
    TCSTART
    _progressValue = [notification.object floatValue];
    if (!_progressView || _progressValue == 1.0f) {
        _progressView = nil;
        _progressValue = 0.0;
       [downloadsTableView reloadData];
    }
    _progressView.progress = _progressValue;
    [_status setText:[NSString stringWithFormat:@"downloading...%.1f%%",_progressValue*100.0f]];
    
    //[downloadsTableView reloadData];
    TCEND
}

-(void)downloadStarted:(NSNotification *)notification
{
    TCSTART
    [self loadDownloads];
    [downloadsTableView reloadData];
    TCEND
}

-(void)downloadPaused:(NSNotification *)notification
{
    [downloadsTableView reloadData];
}

-(void)downloadResumed:(NSNotification *)notification
{
    [downloadsTableView reloadData];
}

-(void)downloadFinished:(NSNotification *)notification
{
    NSLog(@"Refreshing the downloadfinished status");
    [downloadsTableView reloadData];
}

-(void)downloadFailed:(NSNotification *)notification
{
    
}

//-(void)updateProgress:(NSNotification *)notification {
//    for (int i = 0; i < self.downloadedVideos.count; i++) {
//        Download *downloadedVideo = nil;
//        
//        downloadedVideo = [self.downloadedVideos objectAtIndex:i];
//        if (downloadedVideo.downloading && !downloadedVideo.downloaded) {
//            NSIndexPath *indexPath = [
//        }
//    }
//}

#pragma mark TableView DataSource Methods.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.downloadedVideos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCSTART
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1/500.0;
    [cell.layer setTransform:transform];
    
    UIImageView *videoThumbnailView = nil;
    UILabel *title = nil;
    UILabel *status = nil;
    UIProgressView *progressView = nil;
    UIImageView *statusImgView;
    
	if(cell == nil)
	{
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        
        videoThumbnailView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 60, 90)];
        videoThumbnailView.tag = 1;
        videoThumbnailView.contentMode = UIViewContentModeScaleToFill;
//        CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
//        CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
//        CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
        videoThumbnailView.backgroundColor = [UIColor getPlaceHolderColor];
        [cell.contentView addSubview:videoThumbnailView];
        
        title = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(videoThumbnailView.frame) + 5, 15, 180, 20)];
        title.tag = 2;
        title.textColor = [UIColor blackColor];
        title.font = [UIFont fontWithName:@"MuseoSansRounded-700" size:16.0];
        [cell.contentView addSubview:title];
        
        status = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(videoThumbnailView.frame) + 5, CGRectGetMaxY(title.frame) + 15, 230, 40)];
        status.tag = 3;
        status.numberOfLines = 0;
        status.textColor = [UIColor blackColor];
        status.font = [UIFont fontWithName:@"MuseoSansRounded-700" size:14.0];
        [cell.contentView addSubview:status];

        statusImgView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(title.frame) + 15, 5, 50, 50)];
        statusImgView.tag = 4;
        [cell.contentView addSubview:statusImgView];
        
        progressView = [[UIProgressView alloc]init];
        progressView.tag = 5;
        progressView.frame = CGRectMake(210, CGRectGetMaxY(title.frame) + 35, 100, 10);
        progressView.tintColor = [UIColor blueColor];
        [cell.contentView addSubview:progressView];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    if (!videoThumbnailView) {
        videoThumbnailView = (UIImageView *)[cell.contentView viewWithTag:1];
    }
    if (!title) {
        title = (UILabel *)[cell.contentView viewWithTag:2];
    }
    if (!status) {
        status = (UILabel *)[cell.contentView viewWithTag:3];
    }
    if (!statusImgView) {
        statusImgView = (UIImageView *)[cell.contentView viewWithTag:4];
    }
    if (!progressView) {
        progressView = (UIProgressView *)[cell.contentView viewWithTag:5];
    }
    
    progressView.hidden = YES;
    
	Download *downloadedVideo = nil;
	
    //NSLog(@"IndexPath row is %d",indexPath.row);
	downloadedVideo = [self.downloadedVideos objectAtIndex:indexPath.row];
	
    
    if(downloadedVideo.downloadedToTempDir.boolValue && !downloadedVideo.downloaded.boolValue) {
        statusImgView.image = nil;//[UIImage imageNamed:@"dlcomplete"];
        [status setText:[NSString stringWithFormat:kDownloadCopyingToMyplexSpace,downloadedVideo.videoName?:@""]];
    } else if (downloadedVideo.downloading.boolValue && !downloadedVideo.downloaded.boolValue) {
        
        progressView.hidden = NO;
        progressView.progress = _progressValue;
        _status = status;
        
        if (_progressValue > 0.0) {
            [status setText:[NSString stringWithFormat:@"downloading...%.1f%%",_progressValue*100.0f]];
        } else {
            //progressView.hidden = YES;
            [status setText:@"downloading..."];
        }

        _progressView = progressView;

        statusImgView.image = [UIImage imageNamed:@"dlprogress"];
    } else if(downloadedVideo.waiting.boolValue) {
        [status setText:@"waiting..."];
    } else if(downloadedVideo.paused.boolValue){
        [status setText:[NSString stringWithFormat:@"paused at:%.1f%%",downloadedVideo.downlodPercentage.floatValue*100.0f]];
    } else if(downloadedVideo.downloaded.boolValue) {
        if(!downloadedVideo.drmRightsAcquired.boolValue) {
            statusImgView.image = nil;
            [status setText:[NSString stringWithFormat:kDownloadDRMRightsPending,downloadedVideo.videoName?:@""]];
        } else {
            statusImgView.image = [UIImage imageNamed:@"dlcomplete"];
            [status setText:[NSString stringWithFormat:kDownloadPlay,downloadedVideo.videoName?:@""]];
        }
    }  else {
        statusImgView.image = [UIImage imageNamed:@"dlpending"];
        [status setText:@"waiting..."];
    }
    
    [videoThumbnailView setImageWithURL:[NSURL URLWithString:downloadedVideo.image]];
    if (downloadedVideo.videoName) {
        [title setText:downloadedVideo.videoName];
    } else {
        [title setText:@""];
    }
        
    UIView *cellSelectedBGView = [[UIView alloc]init];
    cellSelectedBGView.backgroundColor = [UIColor colorWithRed:87.0f/255.0f green:200.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
    cell.selectedBackgroundView = cellSelectedBGView;
    
	return cell;
    TCEND
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    Download *downloadedVideo = nil;
	downloadedVideo = [self.downloadedVideos objectAtIndex:indexPath.row];
    
    BOOL canEdit = NO;
    if (downloadedVideo.downloaded.boolValue || (downloadedVideo.temporaryDestinationFilePath.length > 0 && ![[NSFileManager defaultManager] fileExistsAtPath:downloadedVideo.temporaryDestinationFilePath])) {
        canEdit = YES;
    }
    return canEdit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Download *downloadedVideo = nil;
        downloadedVideo = [self.downloadedVideos objectAtIndex:indexPath.row];
        [UIAlertView alertViewWithTitle:@"" message:[NSString stringWithFormat:@"Delete %@ permanently?",downloadedVideo.videoName] cancelBlock:^{
            
        } dismissBlock:^(int buttonIndex) {
            
            NSError *error = nil;
            NSDictionary *attributes = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:downloadedVideo.destinationPath error:&error];
            CGFloat sizeInGB = 0.0f;
            if (!error) {
                NSNumber *size = [attributes objectForKey:NSFileSize];
                sizeInGB = [size doubleValue]/(1024*1024*1024);
            }
            [UIAlertView alertViewWithTitle:@"" message:[NSString stringWithFormat:@"Deleting %@ of size %.2f GB permanently from this device. Downloading again is time consuming and may incur charges.",downloadedVideo.videoName,sizeInGB] cancelBlock:^{
                
            } dismissBlock:^(int buttonIndex) {
                
                NSError *error = nil;
                if ([[NSFileManager defaultManager]fileExistsAtPath:downloadedVideo.destinationPath]) {
                    [[NSFileManager defaultManager]removeItemAtPath:downloadedVideo.destinationPath error:&error];
                }
                
                if (!error) {
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    [appDelegate.managedObjectContext deleteObject:downloadedVideo];
                    
                    [appDelegate.managedObjectContext save:&error];
                    
                    if (!error) {
                        [self.downloadedVideos removeObject:downloadedVideo];
                        // Delete the row from the data source
                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
            } cancelButtonTitle:@"No, Keep" otherButtonsTitles:@"Yes, Delete", nil];
            
        } cancelButtonTitle:@"Cancel" otherButtonsTitles:@"Confirm", nil];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    Download *download = nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

	download = [self.downloadedVideos objectAtIndex:indexPath.row];
    if (download.downloaded.boolValue) {
        Content *content = (Content *)[Content fetchByRemoteId:download.remoteId context:appDelegate.managedObjectContext];
        isIPhone {
            [self performSelector:@selector(openDetailsForContent:) withObject:content afterDelay:0.1];
        }
        else {
            NSString *videoName = [download.videoName stringByReplacingOccurrencesOfString:@" " withString:@""];
            [appDelegate initPlayerWithUrl:[NSString stringWithFormat:@"%@%@.wvm",videoName,download.remoteId] contentId:download.remoteId title:download.videoName profile:download.profile drmEnabled:YES     streaming:NO delegate:self.playerDelegate elapsedTime:[content.elapsedTime integerValue]];
            [self closePageSheetWithViewController];
        }
    } else {
        ToastMessageView *toastMessageView = [[ToastMessageView alloc]initWithFrame:CGRectMake(0, 0, appDelegate.window.frame.size.width, 50)];
        [appDelegate.window addSubview:toastMessageView];
        [toastMessageView showForegroundNotificationBanner:[NSString stringWithFormat:@"wait untill complete the download"]];
    }
}

- (void)openDetailsForContent:(Content *)content
{
    CardDetailsViewController *cd = [[UIStoryboard storyboardWithName:@"Details" bundle:nil] instantiateViewControllerWithIdentifier:@"CardDetailsViewControllerID"];
    [cd view];
    cd.content = content;
    [self.navigationController pushViewController:cd animated:YES];

}


//For iOS 6
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    isIPhone
        return UIInterfaceOrientationMaskPortrait;
    return UIInterfaceOrientationMaskLandscape;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    isIPhone
        return UIInterfaceOrientationPortrait;
    return UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
//        return YES;
//    } else {
//        return NO;
//    }
//}

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
