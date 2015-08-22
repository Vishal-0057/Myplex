//
//  ViewController.m
//  Search
//
//  Created by shiva on 8/27/13.
//  Copyright (c) 2013 Apalya Technlologies Pvt. Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SearchViewController.h"
#import "CustomButton.h"
#import "UIView+Genie.h"
#import "UIColor+Hex.h"
#import "AppData.h"
#import "NSDate+ServerDateFormat.h"
#import "Notifications.h"
#import "UIAlertView+ReportError.h"
#import "Search.h"
#import "AppDelegate.h"
#import "Reachability.h"

//#import "Content+Utils.h"
#import "GetCards.h"
#import "NSManagedObjectContext+Utils.h"
#import "CardsViewController.h"
#import "ServerStandardRequest.h"

#import "IpadMainViewController.h"
#import "AMBlurView.h"

@class DetailViewController;


const int numberOfSections = 5;

#define HEADER_FONT_NAME @"Helvetica-Light"
#undef TAG_FONT_NAME
#define TAG_FONT_NAME @"Helvetica-Light"

#define MAIN_HEADER_FONT_SIZE 16
#define HEADER_FONT_SIZE 17
#define TAG_FONT_SIZE 14

#define MAIN_HEADER_BACKGROUND_COLOR @"393939"
#define MAIN_HEADER_TITLE_COLOR @"FFFFFF"
#define HEADER_TITLE_COLOR @"606366"
#define HEADER_BACKGROUND_COLOR @"fcfcfc"
#define TAG_TITLE_COLOR @"54B5E9"
#define TAG_BORDER_COLOR @"54B5E9"

#define LEFT_PADDING 15
#define TAG_BUTTON_HEIGHT 27
#define TAG_TITLE_PADDING 24
#define TAG_TOP_PADDING 12
#define TAG_SPACE_PADDING 9
#define TAG_BUTTON_RADIUS 14
#define TAG_BOARDER_WIDTH 1.5
#define TAG_RIGHT_PADDING 30.0f
#define TAG_MAX_WIDTH 275.f

#define IOS7 if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)

@interface SearchViewController () <UITableViewDelegate,UITableViewDelegate,TITokenFieldDelegate>
{
    __weak IBOutlet UIButton *buttonResults;
    NSMutableArray      *sectionArray;
    NSMutableDictionary *sectionContentDict;
}
@property (nonatomic, retain) id delegate;
- (void)resizeViews;
@end

NSLineBreakMode const kLineBreakModeTruncatingTail = NSLineBreakByTruncatingTail;

@implementation SearchViewController {
    TITokenFieldView * _tokenFieldView;
}

-(void)search:(id)sender {
    
    [_tokenFieldView.tokenField resignFirstResponder];
    
    if (_tokenFieldView.tokenField.tokens.count > 0) {
        
        NSMutableString *tagsSelected = [[NSMutableString alloc]init];
        NSMutableString *categorySelected = [[NSMutableString alloc]init];
        for (TIToken *token in _tokenFieldView.tokenField.tokens) {
            NSLog(@"token title %@ and token Id %@",token.title,token.id_);
            
            if (token.title) {
                [tagsSelected appendString:[NSString stringWithFormat:@"%@,",token.title]];
                [categorySelected appendString:[NSString stringWithFormat:@"%@,",token.category]];
            }
        }
        
        NSString *query = nil;
        if (![tagsSelected length] > 0)
        {
            return;
        }
        query = [tagsSelected substringToIndex:[tagsSelected length] - 1];

        //[Flurry logEvent:@"Search- Query" withParameters:@{@"tags selected": tagsSelected,@"tags categories selected":categorySelected,@"Network":ReachableViaWiFi?@"WIFI":@"Cellular Network"} timed:YES];

        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        BOOL clientKeyValid = [appDelegate isClientKeyValid];
        
        if (clientKeyValid) {
            [self makeSearchRequestWithQuery:query withClientKey:[AppData shared].data[@"clientKey"]];
        } else {
            [appDelegate requestForClientKeyGenerationWithCompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
                if (success) {
                    [self makeSearchRequestWithQuery:query withClientKey:[AppData shared].data[@"clientKey"]];
                }
            }];
        }
    } else { //please enter some search phrase
        
    }
    [self textFieldShouldClear:_tokenFieldView.tokenField];
}

-(void)setDelegateWithViewController:(id)delegate
{
    self.delegate = delegate;
}

- (void)makeSearchRequestWithQuery:(NSString *)query withClientKey:(NSString *)clientKey
{

    [Analytics logEvent:EVENT_SEARCH parameters:@{SEARCH_TYPE_PROPERTY:SEARCH_TYPES_STRING(SearchDiscover),SEARCH_QUERY_PROPERTY:query?:@"",SEARCH_STATUS_PROPERTY:SEARCH_STATUS_TYPES_STRING(SearchClicked),EVENT_TIMED:[NSDate date]} timed:YES];
    
    isIPhone
    {
        CardsViewController *cvc;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[CardsViewController class]]) {
                cvc = (CardsViewController *)vc;
                break;
            }
        }
        
        [cvc refreshWithSearchQuery:query];
        [self.navigationController popToViewController:cvc animated:YES];
    }
    else
    {
        // TODO : research
        self.delegate = [(IpadMainViewController *)self.parentViewController getDelegate];

        [self.delegate refreshWithSearchQuery:query];
       UIButton *button = (UIButton *)[[[[(IpadMainViewController *)self.parentViewController view] viewWithTag:103] viewWithTag:104] viewWithTag:105];
        [(IpadMainViewController *)self.parentViewController toggleColorForButton:button];
        [self ButtonAction_Back:nil];
    }

    
//    [AppDelegate showActivityIndicatorWithText:@"Loading..."];
//
//    GetCards *getter = [[GetCards alloc] initWithManagedObjectContext:[NSManagedObjectContext childUIManagedObjectContext]];
//    getter.pageSize = 30;
//    [getter getCardsWithQuery:query andPage:0 andCompletionHandler:^(NSArray *array, NSError *error) {
//        
//        if (!error) {
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                CardsViewController *cvc;
//                for (UIViewController *vc in self.navigationController.viewControllers) {
//                    if ([vc isKindOfClass:[CardsViewController class]]) {
//                        cvc = (CardsViewController *)vc;
//                        [cvc refreshWithCards:array];
//                        break;
//                    }
//                }
//                [AppDelegate removeActivityIndicator];
//                [Flurry endTimedEvent:@"Search- Query" withParameters:@{@"Status":@"Success"}];
//                [self.navigationController popViewControllerAnimated:YES];
//            });
//        }
//        else {
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [AppDelegate removeActivityIndicator];
//
//                NSLog(@"Detailed error: %@", error.localizedDescription);
//                [UIAlertView showAlertWithError:error];
//                
//                [Flurry logError:@"Search- Query" message:@"Search- Query Failed" error:error];
//                
//                [Flurry endTimedEvent:@"Search- Query" withParameters:@{@"Status":@"Failure"}];
//            });
//        }
//    }];
}

-(void)searchQueryDidSuccess:(NSNotification *)notification {
    
    [AppDelegate removeActivityIndicator];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)searchQueryDidFail:(NSNotification *)notification {
    
    [AppDelegate removeActivityIndicator];
    
    NSError *error = nil;
    
    if ([notification.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *response = notification.object;
        error = [NSError errorWithDomain:kServerErrors andCode:kServerErrorNotAuthorized andDescriptionKey:response[@"message"] andUnderlying:0];
        
    } else if([notification.object isKindOfClass:[NSError class]]){
        error = notification.object;
        
    }
    [UIAlertView showAlertWithError:error];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    uiactivityIndicatorView = [[UIActivityIndicatorView alloc]init];
    [searchTable addSubview:uiactivityIndicatorView];
    
    [buttonResults addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    searchTable.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.4];
    searchTable.backgroundView = [[AMBlurView alloc] initWithFrame:CGRectMake(searchTable.backgroundView.frame.origin.x, searchTable.backgroundView.frame.origin.y, searchTable.backgroundView.frame.size.width, searchTable.backgroundView.frame.size.height)];
    searchTable.sectionIndexBackgroundColor  = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.4];
    
    downloadProgressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, 4.0f)];
    [self.view addSubview:downloadProgressView];
    //downloadProgressView.hidden = YES;
    downloadProgressView.tintColor = [UIColor whiteColor];

    // Fetching/Parsing tags logic goes here.
    NSDictionary *searchTagsDict = [AppData shared].data[@"searchTagsResponse"];
    BOOL fetchTagsFromServer = YES;
    if (searchTagsDict) {
        BOOL responseValid = [self validateSearchTagsResponse];
        if (responseValid) {
            if (!sectionContentDict.count > 0) {
                [self formatTagsDataForCategory:nil];
            }
            fetchTagsFromServer = NO;
        }
    }
    
    if (fetchTagsFromServer) {
        [self getSearchTags];
    }
    
//    IOS7 {
//        self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:MAIN_HEADER_BACKGROUND_COLOR];
//    } else {
//        self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:MAIN_HEADER_BACKGROUND_COLOR];
//    }
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    NSString *headerTitle = [NSString stringWithFormat:@"Search %@",kAppTitle];
    self.title = headerTitle;
//    CGSize size = [headerTitle sizeWithFont:[UIFont fontWithName:HEADER_FONT_NAME size:MAIN_HEADER_FONT_SIZE] forWidth:260 lineBreakMode:kLineBreakModeTruncatingTail];
//    CGFloat arrowWidth = 12;
//    CGFloat titleArrowGap = 25;
//    
//    navTitleViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [navTitleViewBtn setTitle:headerTitle forState:UIControlStateNormal];
//     [navTitleViewBtn setTitleColor:[UIColor colorWithHexString:MAIN_HEADER_TITLE_COLOR] forState:UIControlStateNormal];
//    navTitleViewBtn.frame = CGRectMake(0, 0, size.width + arrowWidth + 5, self.navigationItem.titleView.frame.size.height);
//    navTitleViewBtn.tag = 1;
//    navTitleViewBtn.titleLabel.font = [UIFont fontWithName:HEADER_FONT_NAME size:MAIN_HEADER_FONT_SIZE];
//    [navTitleViewBtn addTarget:self action:@selector(showFilterItems:) forControlEvents:UIControlEventTouchUpInside];
//    navTitleViewBtn.backgroundColor = [UIColor redColor];
//    self.navigationItem.titleView = navTitleViewBtn;
//    
//    UIImageView *upDownArrow        = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exposewhite"]];
//    upDownArrow.autoresizingMask    = UIViewAutoresizingFlexibleLeftMargin;
//    upDownArrow.frame               = CGRectMake(size.width + titleArrowGap, -4, 12, 7);
//    upDownArrow.tag = 100;
//    //[navTitleViewBtn addSubview:upDownArrow];
//    [navTitleViewBtn addSubview: upDownArrow];
    
    isIPhone
        _tokenFieldView = [[TITokenFieldView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(downloadProgressView.frame) + 2, 320, 38)]; // Vishal added self.view.frame.size.width --> 320
    else
        _tokenFieldView = [[TITokenFieldView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(downloadProgressView.frame) + 44, 320, 38)];
    
    [self.view addSubview:_tokenFieldView];
    
    [_tokenFieldView.tokenField setDelegate:self];
    [_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:(UIControlEvents)TITokenFieldControlEventFrameDidChange];
    [_tokenFieldView.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",;."]]; // Default is a comma
    [_tokenFieldView.tokenField setPromptText:nil];
    [_tokenFieldView.tokenField setPlaceholder:@"Search..."];
    _tokenFieldView.tokenField.clearButtonMode = UITextFieldViewModeAlways;
    [_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidBegin];
    [_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidEnd];
    
    [searchTable setFrame:CGRectMake(0, CGRectGetMaxY(_tokenFieldView.frame),self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_tokenFieldView.frame))];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveResponse:) name:kDownloadingStarted object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didFailWithError:) name:kDownloadingError  object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveData:) name:kDownloadingDataReceived object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(connectionDidFinishDownloading:) name:kDownloadingSucess  object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tagsFetchingDidSuccess:) name:kNotificationSearchTagsFetched object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tagsFetchingDidFail:) name:kNotificationSearchTagsFetchingError object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(searchQueryDidSuccess:) name:kNotificationSearchQueryFetched object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(searchQueryDidFail:) name:kNotificationSearchQueryFetchingError object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [Analytics logEvent:EVENT_SEARCH parameters:@{SEARCH_SCREEN_PROPERTY:@"Appear"} timed:NO];
    //[Flurry logEvent:@"Search- Screen Shown" timed:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [searchTable setFrame:CGRectMake(0, CGRectGetMaxY(_tokenFieldView.frame),self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_tokenFieldView.frame))];
    searchTable.sectionIndexColor = [UIColor colorWithRed:200.0f/255.0f green:16.0f/255.0f blue:26.0f/255.0f alpha:1.0f];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [Analytics logEvent:EVENT_SEARCH parameters:@{SEARCH_SCREEN_PROPERTY:@"Disappear"} timed:NO];
}

-(void)didReceiveResponse:(NSNotificationCenter *)notification {
   // downloadProgressView.progress = 0.6f;
   // downloadProgressView.hidden = NO;
}

-(void)didFailWithError:(NSNotificationCenter *)notification {
    downloadProgressView.hidden = YES;
}

-(void)didReceiveData:(NSNotification *)notification {
    ServerStandardRequest *serverStandardRequest = notification.object;
    double progress = (double)serverStandardRequest.data.length / (double)serverStandardRequest.expectedSize;
#if DEBUG
    NSLog(@"search tags data progress %f",progress);
#endif
    downloadProgressView.progress = progress;
}

-(void)connectionDidFinishDownloading:(NSNotification *)notification {
    ServerStandardRequest *serverStandardRequest = notification.object;
    double progress = (double)serverStandardRequest.data.length / (double)serverStandardRequest.expectedSize;
#if DEBUG
    NSLog(@"search tags datafinish progress %f",progress);
#endif
    downloadProgressView.progress = progress;
    downloadProgressView.hidden = YES;
}

-(BOOL)validateSearchTagsResponse {
    
    BOOL responseValid = NO;
    NSDate *currentDate = [NSDate GMTDate];
    NSDate *clientExpirationDate = [NSDate formatStringToDate:[AppData shared].data[@"searchTagsResponseExpiry"]];
    if ([currentDate compare:clientExpirationDate] == NSOrderedDescending) {
        NSLog(@"currentDate is later than searchTagsResponseExpiry");
        responseValid = YES;
    }
    return responseValid;
}

-(void)getSearchTags {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    BOOL clientKeyValid = [appDelegate isClientKeyValid];
    
    if (clientKeyValid) {
        [self makeSearchTagsReuqest:[AppData shared].data[@"clientKey"]];
    } else {
        [appDelegate requestForClientKeyGenerationWithCompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
            if (success) {
                [self makeSearchTagsReuqest:[AppData shared].data[@"clientKey"]];
            }
        }];
    }
}

-(void)makeSearchTagsReuqest:(NSString *)clientKey {
    
    [uiactivityIndicatorView startAnimating];
    
    downloadProgressView.hidden = NO;
    downloadProgressView.progress = 0.5;
    
    //[AppDelegate showActivityIndicatorWithText:@"Loading..."];
    Search *search = [[Search alloc]initWithManagedObjectContext:[NSManagedObjectContext tempManagedObjectContext]];
    [search getTagsWithCategory:nil qualifier:@"all" numPerQualifier:@"-1" startLetter:@"all" numStartLetter:@"-1" clientKey:clientKey];

}

-(void)tagsFetchingDidSuccess:(NSNotification *)notification {
    //[AppDelegate removeActivityIndicator];
    [uiactivityIndicatorView stopAnimating];
    [[AppData shared].data setObject:@"Wed, 06 Nov 2013 11:35:08 GMT" forKey:@"searchTagsResponseExpiry"];
    [self formatTagsDataForCategory:nil];
}

-(void)tagsFetchingDidFail:(NSNotification *)notification {
    //[AppDelegate removeActivityIndicator];
    [uiactivityIndicatorView stopAnimating];
    [self formatTagsDataForCategory:nil];
    if ([notification.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *response = notification.object;
        [UIAlertView showAlertWithError:[NSError errorWithDomain:kServerErrors andCode:kServerErrorNotAuthorized andDescriptionKey:response[@"message"] andUnderlying:0]];
        
    } else if([notification.object isKindOfClass:[NSError class]]){
        NSError *error = notification.object;
        
        [UIAlertView showAlertWithError:error];
    }
}

-(void)formatTagsDataForCategory:(NSString *)category {
    
    //get All Qualifiers.
    NSDictionary *qualifiers = [AppData shared].data[@"searchTagsResponse"][@"qualifiers"];
    NSDictionary *startLetters = [AppData shared].data[@"searchTagsResponse"][@"startLetters"];
    
    //get all Qualifier Names and sort it in ascending
    NSMutableArray *sectionNames = [[NSMutableArray alloc]init];
    if ([qualifiers allKeys]) {
        [sectionNames addObjectsFromArray:[[qualifiers allKeys]sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    }
    if ([startLetters allKeys]) {
        [sectionNames addObjectsFromArray:[[startLetters allKeys]sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    }
   
    //sectionTitleArray = sectionNames; // all qualifier names.
    
    sectionTitleArray = [[NSMutableArray alloc]init];
    sectionContentDict  = [[NSMutableDictionary alloc] init]; //holds the qualifier info.

    sectionArray = [[NSMutableArray alloc]init]; //holds the expand & collapse status of the cell and also updates the row height.
    
    NSMutableArray *categoriesM = [[NSMutableArray alloc]init];
    [categoriesM addObject:@"All"];
   NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"category=='%@'",category]];
    for (NSString *qualifierName in sectionNames) {
        NSArray *categories_ = nil;
        BOOL addSection = NO;
        if (qualifiers[qualifierName]) {
            categories_ = [qualifiers[qualifierName][@"values"] valueForKey:@"category"]; //get the categories from tag
            if (category) {
                if ([categories_ containsObject:category]) {
                    addSection = YES;
                    NSArray *allQualifiersData = [qualifiers allValues];
                    NSArray *allQualifierValues = [allQualifiersData valueForKey:@"values"];
                    NSMutableArray *allQualifierValuesM = [[NSMutableArray alloc]init];
                    for (NSArray *values in allQualifierValues) {
                        [allQualifierValuesM addObjectsFromArray:values];
                    }
                    NSArray *filteredQualifiers = [allQualifierValuesM filteredArrayUsingPredicate:predicate];
                    NSMutableDictionary *qualifier = [[NSMutableDictionary alloc]initWithDictionary:qualifiers[qualifierName]];
                    [qualifier setObject:filteredQualifiers forKey:@"values"];
                    [sectionContentDict setObject:qualifier forKey:qualifierName];
                    [sectionTitleArray addObject:qualifierName];
                }
            } else {
                addSection = YES;
                [sectionContentDict setObject: qualifiers[qualifierName] forKey:qualifierName];
                [sectionTitleArray addObject:qualifierName];
            }
        } else {
            categories_ = [startLetters[qualifierName][@"values"] valueForKey:@"category"]; //get the categories from tags
            if (category) {
                if ([categories_ containsObject:category]) {
                    addSection = YES;
                    NSArray *allStartLettersData = [startLetters allValues];
                    NSArray *allStartLetterValues = [allStartLettersData valueForKey:@"values"];
                    NSMutableArray *allStartLetterValuesM = [[NSMutableArray alloc]init];
                    for (NSArray *values in allStartLetterValues) {
                        [allStartLetterValuesM addObjectsFromArray:values];
                    }
                    NSArray *filteredStartLetters = [allStartLetterValuesM filteredArrayUsingPredicate:predicate];
                    NSMutableDictionary *startLetterValue = [[NSMutableDictionary alloc]initWithDictionary:startLetters[qualifierName]];
                    [startLetterValue setObject:filteredStartLetters forKey:@"values"];
                    [sectionContentDict setObject:startLetterValue forKey:qualifierName];
                    [sectionTitleArray addObject:qualifierName];
                }
            } else {
                addSection = YES;
                [sectionContentDict setObject: startLetters[qualifierName] forKey:qualifierName];
                [sectionTitleArray addObject:qualifierName];
            }
        }
        if (categories_.count > 0) {
            [categoriesM addObjectsFromArray:categories_];
        }
        if (addSection) {
            NSMutableDictionary *sectionDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"expandstatus",qualifierName,@"title",[NSNumber numberWithInt:TAG_TOP_PADDING + TAG_BUTTON_HEIGHT + TAG_TOP_PADDING],@"height", nil];
            [sectionArray addObject:sectionDict];
        }
    }
    
    if (sectionTitleArray.count > 0) {
        [sectionTitleArray insertObject:@"recent tags" atIndex:0];
    } else {
        [sectionTitleArray addObject:@"recent tags"];
    }
    
    NSMutableDictionary *sectionDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"expandstatus",@"recent tags",@"title",[NSNumber numberWithInt:TAG_TOP_PADDING + TAG_BUTTON_HEIGHT + TAG_TOP_PADDING],@"height", nil];
    if (sectionArray.count > 0) {
        [sectionArray insertObject:sectionDict atIndex:0];
    } else {
        [sectionTitleArray addObject:sectionDict];
    }
    
    //get the recentlyselectedcategories data from userdefaults
    [self setRecentTags];
    
    // get unique categories.
    NSMutableSet *uniqueStates = [NSMutableSet setWithArray:categoriesM];
    [uniqueStates removeObject:@""]; //remove the empty text categories.
    categories = [uniqueStates allObjects]; //here are the unique categories,pass it to fiterTable.
#ifdef DEBUG
    NSLog(@"Categories %@: tags %@ for category %@",categories,sectionContentDict,category);
#endif
    
    [searchTable reloadData];
}

-(void)addRecentTag:(NSString *)tag {
    
    NSMutableArray *recentTags = [[NSMutableArray alloc]initWithArray:[[AppData shared]data][@"recentlyselectedtags"]];
    //remove if current selected category item exist in the recentySlctdCtgrs_Marray_ list and insert the current selected item at index 0.
    for (int i = 0; i < recentTags.count; i++) {
        if([[recentTags objectAtIndex:i][@"name"] isEqualToString:tag]){
            [recentTags removeObjectAtIndex:i];
            break;
        }
    }
    //insert recently selected item at index 0 as it is the recently selected category
    NSDictionary *recentTag = [[NSDictionary alloc]initWithObjectsAndKeys:tag,@"name",@"",@"qualifier",@"",@"_id", nil];
    [recentTags insertObject:recentTag atIndex:0];
    
    //remove the last recently selected tag from recentlyslctdctgrs_Marray_ list if the items are greater than 10.
    if (recentTags.count > 10) {
        [recentTags removeObjectsInRange:NSMakeRange(10, recentTags.count - 10)];
    }
    [[[AppData shared]data] setObject:recentTags forKey:@"recentlyselectedtags"];
    [[AppData shared]save];
    [self setRecentTags];
    
    [searchTable reloadData];
}

-(void)setRecentTags {
    NSMutableArray *recentTags = [[NSMutableArray alloc]initWithArray:[[AppData shared]data][@"recentlyselectedtags"]];
    NSMutableDictionary *recentTagsDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:recentTags,@"values", nil];
    [sectionContentDict setObject:recentTagsDict forKey:@"recent tags"];
}
//-(void)filterTagsWithCategory:(NSString *)category {
//    
//    //get All Qualifiers.
//    NSDictionary *qualifiers = [AppData shared].data[@"searchTagsResponse"][@"qualifiers"];
//    NSDictionary *startLetters = [AppData shared].data[@"searchTagsResponse"][@"startLetters"];
//    
//
//    NSArray *allQualifiersData = [qualifiers allValues];
//    NSArray *allQualifierValues = [allQualifiersData valueForKey:@"values"];
//    NSMutableArray *allQualifierValuesM = [[NSMutableArray alloc]init];
//    for (NSArray *values in allQualifierValues) {
//        [allQualifierValuesM addObjectsFromArray:values];
//    }
//    NSArray *filteredQualifiers = [allQualifierValuesM filteredArrayUsingPredicate:predicate];
//    NSArray *keys = [[NSDictionary ] allKeysForObject:category];
//
//    NSArray *allStartLettersData = [startLetters allValues];
//    NSArray *allStartLetterValues = [allStartLettersData valueForKey:@"values"];
//    NSArray *filteredStartLetters = [allStartLetterValues filteredArrayUsingPredicate:predicate];
//    
//    //get all Qualifier Names and sort it in ascending
//    NSMutableArray *sectionNames = [[NSMutableArray alloc]init];
//    if ([qualifiers allKeysForObject:category]) {
//        [sectionNames addObjectsFromArray:[[qualifiers allKeysForObject:category]sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
//    }
//    if ([startLetters allKeysForObject:category]) {
//        [sectionNames addObjectsFromArray:[[startLetters allKeysForObject:category]sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
//    }
//
//    sectionTitleArray = sectionNames; // all qualifier names.
//    
//    sectionContentDict  = [[NSMutableDictionary alloc] init]; //holds the qualifier info.
//    
//    sectionArray = [[NSMutableArray alloc]init]; //holds the expand & collapse status of the cell and also updates the row height.
//    
//    NSMutableArray *categoriesM = [[NSMutableArray alloc]init];
//    [categoriesM addObject:@"All"];
//    
//    for (NSString *qualifierName in sectionTitleArray) {
//        if (qualifiers[qualifierName]) {
//            [sectionContentDict setObject: qualifiers[qualifierName] forKey:qualifierName];
//        } else {
//            [sectionContentDict setObject: startLetters[qualifierName] forKey:qualifierName];
//        }
//        
//        NSMutableDictionary *sectionDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"expandstatus",qualifierName,@"title",[NSNumber numberWithInt:TAG_TOP_PADDING + TAG_BUTTON_HEIGHT + TAG_TOP_PADDING],@"height", nil];
//        [sectionArray addObject:sectionDict];
//    }
//    
//    [searchTable reloadData];
//}

- (void)resizeViews {
    [_tokenFieldView setFrame:((CGRect){_tokenFieldView.frame.origin, {self.view.bounds.size.width, 44}})];
}

- (BOOL)tokenField:(TITokenField *)tokenField willRemoveToken:(TIToken *)token {
	
	if ([token.title isEqualToString:@"Tom Irving"]){
		return NO;
	}
	
	return YES;
}

- (void)tokenFieldChangedEditing:(TITokenField *)tokenField {
	// There's some kind of annoying bug where UITextFieldViewModeWhile/UnlessEditing doesn't do anything.
	[tokenField setRightViewMode:(tokenField.editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever)];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    [_tokenFieldView.tokenField removeAllTokens];
    [textField performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.05];
    
    isIPhone {} else  [self resizeViews];
   
	return YES;
}

-(void)showFilterItems:(UIButton *)sender {
    
    [_tokenFieldView.tokenField resignFirstResponder];
    
    UIImageView *updownArrow = (UIImageView *)[sender viewWithTag:100];
    CGRect frame = [sender.titleLabel.text boundingRectWithSize:CGSizeMake(260, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:HEADER_FONT_NAME size:MAIN_HEADER_FONT_SIZE]} context:nil];
    CGSize size = frame.size;
    //below API is deprecated
    //CGSize size = [sender.titleLabel.text sizeWithFont:[UIFont fontWithName:HEADER_FONT_NAME size:MAIN_HEADER_FONT_SIZE] forWidth:260 lineBreakMode:kLineBreakModeTruncatingTail];
    
    CGFloat arrowWidth = 12;
    CGFloat titleArrowGap = 25;
    sender.frame = CGRectMake(sender.frame.origin.x, sender.frame.origin.y, size.width + arrowWidth + 5, self.navigationItem.titleView.frame.size.height);
    updownArrow.frame               = CGRectMake(size.width + titleArrowGap, -4, 12, 7);
    
    if (sender.tag == 1) {
        sender.tag = 2;
        [updownArrow setImage:[UIImage imageNamed:@"hidewhite"]];
        
        filterTable = [[FilterTableViewController alloc]initWithNibName:@"FilterTableViewController" bundle:nil];
        filterTable.delegate = self;
        filterTable.filterItems = categories;
        filterTable.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:filterTable.view];
        
        [UIView beginAnimations:@"filterTable" context:nil];
        [UIView setAnimationDuration:0.8];
        [UIView setAnimationDelegate:self];
        //position off screen
        [filterTable.view setFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];
        //[UIView setAnimationDidStopSelector:@selector(finishAnimation:finished:context:)];
        //animate off screen
        [UIView commitAnimations];
    } else {
        [updownArrow setImage:[UIImage imageNamed:@"exposewhite"]];
        
        sender.tag = 1;
        [UIView beginAnimations:@"filterTable" context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        //position off screen
        [filterTable.view setFrame:CGRectMake(0,-self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        //[UIView setAnimationDidStopSelector:@selector(finishAnimation:finished:context:)];
        //animate off screen
        [UIView commitAnimations];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [sectionArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //    if ([[arrayForBool objectAtIndex:section] boolValue]) {
    //        return [[sectionContentDict valueForKey:[sectionTitleArray objectAtIndex:section]] count];
    //    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
   
    UIView *headerView              = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 26)];
    headerView.tag                  = section;
    headerView.backgroundColor      = [UIColor colorWithHexString:HEADER_BACKGROUND_COLOR];
    
    isIPhone {} else
        headerView.alpha = 0.7;
    
    headerView.layer.borderColor = [UIColor colorWithHexString:@"e5e5e5"].CGColor;
    headerView.layer.borderWidth = 0.5f;
    
    UILabel *headerLbl           = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, 0, self.view.frame.size.width-20-50, 26)];
    headerLbl.textAlignment      = NSTextAlignmentLeft;
    headerLbl.textColor          = [UIColor colorWithHexString:HEADER_TITLE_COLOR];
    headerLbl.font               = [UIFont fontWithName:HEADER_FONT_NAME size:HEADER_FONT_SIZE];
    headerLbl.backgroundColor    = [UIColor clearColor];
    NSString *sectionTitle = nil;
    NSMutableDictionary *sectionInfo = nil;
    sectionInfo = [sectionArray objectAtIndex:section];
    sectionTitle = [sectionInfo objectForKey:@"title"];
    headerLbl.text = sectionTitle;
    [headerView addSubview:headerLbl];
    
    UITapGestureRecognizer  *headerTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
    [headerView addGestureRecognizer:headerTapped];
    
    BOOL collapsed                  = [[sectionInfo objectForKey:@"expandstatus"] boolValue];
    //up or down arrow depending on the bool
    UIImageView *upDownArrow        = [[UIImageView alloc] initWithImage:collapsed ? [UIImage imageNamed:@"hide-12"] : [UIImage imageNamed:@"expose-12"]];
    upDownArrow.autoresizingMask    = UIViewAutoresizingFlexibleLeftMargin;
    upDownArrow.frame               = CGRectMake(self.view.frame.size.width-40, 9.5, 12, 7);
    [headerView addSubview:upDownArrow];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 26;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *sectionInfo = [sectionArray objectAtIndex:indexPath.section];
    
    return [[sectionInfo objectForKey:@"height"] intValue];
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //return sectionTitleArray;
    
    NSMutableArray *sectionedArray = [[NSMutableArray alloc]init];
    [sectionedArray addObject:@"#"];
    for(char c ='A' ; c <= 'Z' ;  c++)
    {
        [sectionedArray addObject:[NSString stringWithFormat:@"%c",c]];
    }

    return sectionedArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger count = 0;
    for(NSString *indexString in sectionTitleArray)
    {
        if([indexString isEqualToString:title])
        {
            return count;
        }
        count ++;
    }
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    NSString *cellIdentifier = [NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row];
    CustomButton *tagBtn = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSMutableDictionary *sectionInfo = [sectionArray objectAtIndex:indexPath.section];
    NSArray *tags = sectionContentDict[sectionInfo[@"title"]][@"values"];
    
    UIFont *font = [UIFont fontWithName:TAG_FONT_NAME size:TAG_FONT_SIZE];
    CGFloat height = 0.0f;
    CGFloat width = LEFT_PADDING;
    int x = LEFT_PADDING;

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        BOOL manyCells                  = [[sectionInfo objectForKey:@"expandstatus"] boolValue];
        
        if (!manyCells) {
           
            //cell.textLabel.text = @"";
             //int y = 0;
            
            
            for (int i = 0; i < tags.count; i++) {
               
                NSString *title = [tags objectAtIndex:i][@"name"];
                NSString *id_ = [tags objectAtIndex:i][@"_id"];

                CGRect frame = [title boundingRectWithSize:CGSizeMake(TAG_MAX_WIDTH, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
                CGSize size = frame.size;
                //CGSize size = [title sizeWithFont:font forWidth:TAG_MAX_WIDTH lineBreakMode:NSLineBreakByWordWrapping];
                height += size.height;
                width += (size.width + TAG_TITLE_PADDING + TAG_SPACE_PADDING);
                
                if (width < self.view.frame.size.width - TAG_RIGHT_PADDING) {
                    tagBtn = [CustomButton buttonWithType:UIButtonTypeCustom];
                    tagBtn.buttonId = id_;
                    tagBtn.category = sectionInfo[@"title"];
                    tagBtn.indexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                    tagBtn.tag = [[NSString stringWithFormat:@"%d%d",indexPath.section,i+1]integerValue];
                    tagBtn.frame = CGRectMake(x, TAG_TOP_PADDING, size.width + TAG_TITLE_PADDING, TAG_BUTTON_HEIGHT);
                    [tagBtn setTitle:title forState:UIControlStateNormal];
                    tagBtn.titleLabel.font = [UIFont fontWithName:TAG_FONT_NAME size:TAG_FONT_SIZE];
                    [tagBtn setTitleColor:[UIColor colorWithHexString:TAG_TITLE_COLOR] forState:UIControlStateNormal] ;
                    [tagBtn addTarget:self action:@selector(searchTagTapped:) forControlEvents:UIControlEventTouchUpInside];
                    // Must set the label background to clear so the layer background shows
                   isIPhone
                        tagBtn.backgroundColor = [UIColor clearColor];
                    else
                        tagBtn.backgroundColor = [UIColor whiteColor];
                
                    
                    // Set UILabel.layer.backgroundColor not UILabel.backgroundColor otherwise the background is not masked to the rounded border.
                    //tagBtn.layer.backgroundColor = [UIColor colorWithRed:0 green:0.15 blue:0.15 alpha:0.8].CGColor;
                    tagBtn.layer.cornerRadius = TAG_BUTTON_RADIUS;
                    tagBtn.layer.borderColor = [UIColor colorWithHexString:TAG_BORDER_COLOR].CGColor;
                    tagBtn.layer.borderWidth = TAG_BOARDER_WIDTH;
                    
                    [cell.contentView addSubview:tagBtn];
                    x += (size.width + TAG_TITLE_PADDING + TAG_SPACE_PADDING);
                } else {
                    break;
                }
            }
        }
    } else {
        for (int i = 0; i < tags.count; i++) {
            CustomButton *tagBtn = (CustomButton *)[cell.contentView viewWithTag:[[NSString stringWithFormat:@"%d%d",indexPath.section,i+1]intValue]];
            if (!tagBtn) {
                tagBtn = [CustomButton buttonWithType:UIButtonTypeCustom];
                tagBtn.titleLabel.font = [UIFont fontWithName:TAG_FONT_NAME size:TAG_FONT_SIZE];
                [tagBtn setTitleColor:[UIColor colorWithHexString:TAG_TITLE_COLOR] forState:UIControlStateNormal] ;
                [tagBtn addTarget:self action:@selector(searchTagTapped:) forControlEvents:UIControlEventTouchUpInside];
                // Must set the label background to clear so the layer background shows
                isIPhone
                    tagBtn.backgroundColor = [UIColor clearColor];
                else
                    tagBtn.backgroundColor = [UIColor whiteColor];
                // Set UILabel.layer.backgroundColor not UILabel.backgroundColor otherwise the background is not masked to the rounded border.
                //tagBtn.layer.backgroundColor = [UIColor colorWithRed:0 green:0.15 blue:0.15 alpha:0.8].CGColor;
                tagBtn.layer.cornerRadius = TAG_BUTTON_RADIUS;
                tagBtn.layer.borderColor = [UIColor colorWithHexString:TAG_BORDER_COLOR].CGColor;
                tagBtn.layer.borderWidth = TAG_BOARDER_WIDTH;
                [cell.contentView addSubview:tagBtn];
            }
            NSString *title = [tags objectAtIndex:i][@"name"];
            NSString *id_ = [tags objectAtIndex:i][@"_id"];
            CGRect frame = [title boundingRectWithSize:CGSizeMake(TAG_MAX_WIDTH, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
            CGSize size = frame.size;
            //CGSize size = [title sizeWithFont:font forWidth:TAG_MAX_WIDTH lineBreakMode:NSLineBreakByWordWrapping];
            height += size.height;
            width += (size.width + TAG_TITLE_PADDING + TAG_SPACE_PADDING);
            
            if (width < self.view.frame.size.width - TAG_RIGHT_PADDING) {
                tagBtn.frame = CGRectMake(x, TAG_TOP_PADDING, size.width + TAG_TITLE_PADDING, TAG_BUTTON_HEIGHT);
                tagBtn.buttonId = id_;
                tagBtn.category = sectionInfo[@"title"];
                tagBtn.indexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                tagBtn.tag = [[NSString stringWithFormat:@"%d%d",indexPath.section,i+1]integerValue];
                [tagBtn setTitle:title forState:UIControlStateNormal];
                
                x += (size.width + TAG_TITLE_PADDING + TAG_SPACE_PADDING);
                
            } else {
                break;
            }
        }
    }
    isIPhone {} else {
        cell.backgroundColor = [UIColor clearColor];
//        cell.backgroundView = [[AMBlurView alloc] initWithFrame:CGRectMake(cell.backgroundView.frame.origin.x, cell.backgroundView.frame.origin.y, cell.backgroundView.frame.size.width, cell.backgroundView.frame.size.height)];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //[searchTable deselectRowAtIndexPath:indexPath animated:YES];
//    DetailViewController *dvc;
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
//        dvc = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone"  bundle:[NSBundle mainBundle]];
//    }else{
//        dvc = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad"  bundle:[NSBundle mainBundle]];
//    }
//    //dvc.title        = [sectionTitleArray objectAtIndex:indexPath.section];
//    //dvc.detailItem   = [[sectionContentDict valueForKey:[sectionTitleArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
//    [self.navigationController pushViewController:dvc animated:YES];
    
}

-(void)searchTagTapped:(CustomButton *)buttonRef {
   
    buttonRef.enabled = NO;
    buttonRef.layer.backgroundColor = [UIColor colorWithHexString:TAG_BORDER_COLOR].CGColor;
    buttonRef.layer.borderWidth = 0.0;
    [buttonRef setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    NSMutableArray *recentTags = [[NSMutableArray alloc]initWithArray:[[AppData shared]data][@"recentlyselectedtags"]];
    NSArray *names = [recentTags valueForKey:@"name"];
    if (![names containsObject:buttonRef.titleLabel.text]) {
        [self addRecentTag:buttonRef.titleLabel.text];
    }
    
    [_tokenFieldView.tokenField addTokenWithTitle:buttonRef.titleLabel.text id:buttonRef.buttonId category:buttonRef.category representedObject:buttonRef];
    [_tokenFieldView.tokenField resignFirstResponder];
}

-(void)selectedFilterItem:(NSString *)filterItem {
    
    if ([filterItem isEqualToString:@"All"]) {
        filterItem = [NSString stringWithFormat:@"Search %@",kAppTitle];
        [self formatTagsDataForCategory:nil];
    } else {
        [self formatTagsDataForCategory:filterItem];
    }
    
    [navTitleViewBtn setTitle:filterItem forState:UIControlStateNormal];
    [self showFilterItems:navTitleViewBtn];
    
}

#pragma mark - gesture tapped
- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    if (indexPath.row == 0) {
        
        NSMutableDictionary *sectionInfo = [sectionArray objectAtIndex:indexPath.section];
        BOOL collapsed                  = [[sectionInfo objectForKey:@"expandstatus"] boolValue];
        UITableViewCell *cell = [searchTable cellForRowAtIndexPath:indexPath];
        
        collapsed       = !collapsed;
        
        int height = TAG_TOP_PADDING + TAG_BUTTON_HEIGHT + TAG_TOP_PADDING;
        CGFloat width = LEFT_PADDING;
        //int x = LEFT_PADDING;
        //int y = 10;
        
        if (collapsed) {
            NSArray *tags = sectionContentDict[sectionInfo[@"title"]][@"values"];
            for (int i = 0; i < tags.count; i++) {
                CGSize size = [[tags objectAtIndex:i][@"name"] sizeWithFont:[UIFont fontWithName:TAG_FONT_NAME size:TAG_FONT_SIZE] forWidth:TAG_MAX_WIDTH lineBreakMode:kLineBreakModeTruncatingTail];
                //height += (size.height + 6);
                width += (size.width + TAG_TITLE_PADDING + TAG_SPACE_PADDING);
                
                if (width < (self.view.frame.size.width - TAG_RIGHT_PADDING)) {
                    
                } else {
                    width = size.width;
                   // x = LEFT_PADDING;
                    height += TAG_BUTTON_HEIGHT + TAG_TOP_PADDING;
                }
            }
        }
        [sectionInfo setObject:[NSNumber numberWithBool:collapsed] forKey:@"expandstatus"];
        [sectionInfo setObject:[NSNumber numberWithInt:height] forKey:@"height"];
        
        [sectionArray replaceObjectAtIndex:indexPath.section withObject:sectionInfo];
        
        
        if (!collapsed) {
            NSArray *tags = sectionContentDict[sectionInfo[@"title"]][@"values"];
            //cell.textLabel.text = @"";
            CGFloat height = 0.0f;
            CGFloat width = LEFT_PADDING;
            int x = LEFT_PADDING;
            //int y = 0;
            
            for (int i = 0; i < tags.count; i++) {
                CGSize size = [[tags objectAtIndex:i][@"name"] sizeWithFont:[UIFont fontWithName:TAG_FONT_NAME size:TAG_FONT_SIZE] forWidth:TAG_MAX_WIDTH lineBreakMode:kLineBreakModeTruncatingTail];
                height += size.height;
                width += (size.width + TAG_TITLE_PADDING + TAG_SPACE_PADDING);
                
                CustomButton *tagBtn = (CustomButton *)[cell.contentView viewWithTag:[[NSString stringWithFormat:@"%d%d",indexPath.section,i+1]intValue]];
                
                if (width < self.view.frame.size.width - TAG_RIGHT_PADDING) {
                    
                    if (!tagBtn) {
                        tagBtn = [CustomButton buttonWithType:UIButtonTypeCustom];
                    }
                    tagBtn.buttonId = [tags objectAtIndex:i][@"_id"];
                    tagBtn.category = sectionInfo[@"title"];
                    tagBtn.indexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                    tagBtn.tag = [[NSString stringWithFormat:@"%d%d",indexPath.section,i+1]integerValue];
                    tagBtn.titleLabel.font = [UIFont fontWithName:TAG_FONT_NAME size:TAG_FONT_SIZE];
                    tagBtn.frame = CGRectMake(x, TAG_TOP_PADDING, size.width + TAG_TITLE_PADDING, TAG_BUTTON_HEIGHT);
                    [tagBtn setTitle:[tags objectAtIndex:i][@"name"] forState:UIControlStateNormal];
                    [tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal] ;
                    [tagBtn addTarget:self action:@selector(searchTagTapped:) forControlEvents:UIControlEventTouchUpInside];
                    
                    // Must set the label background to clear so the layer background shows
                    isIPhone
                        tagBtn.backgroundColor = [UIColor clearColor];
                    else
                        tagBtn.backgroundColor = [UIColor whiteColor];
                    // Set UILabel.layer.backgroundColor not UILabel.backgroundColor otherwise the background is not masked to the rounded border.
                    if (!tagBtn.enabled) {
                        tagBtn.enabled = NO;
                         [tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal] ;
                        tagBtn.layer.backgroundColor = [UIColor colorWithHexString:TAG_BORDER_COLOR].CGColor;
                        tagBtn.layer.borderWidth = 0.0;
                    }else {
                        isIPhone
                            tagBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
                        else
                            tagBtn.layer.backgroundColor = [UIColor whiteColor].CGColor;
                        [tagBtn setTitleColor:[UIColor colorWithHexString:TAG_TITLE_COLOR] forState:UIControlStateNormal];
                        tagBtn.layer.borderWidth = TAG_BOARDER_WIDTH;
                    }
                    tagBtn.layer.cornerRadius = TAG_BUTTON_RADIUS;
                    tagBtn.layer.borderColor = [UIColor colorWithHexString:TAG_BORDER_COLOR].CGColor;
                    
                    
                    [cell.contentView addSubview:tagBtn];
                    x += (size.width + TAG_TITLE_PADDING + TAG_SPACE_PADDING);
                } else {
                    tagBtn.hidden = YES;
                }
            }
        } else {
            NSArray *tags = sectionContentDict[sectionInfo[@"title"]][@"values"];
            //cell.textLabel.text = @"";
            CGFloat height = 0.0f;
            CGFloat width = LEFT_PADDING;
            int x = LEFT_PADDING;
            int y = TAG_TOP_PADDING;
            int numberOfElementsInRow = 0;
            
            for (int i = 0; i < tags.count; i++) {
                CGSize size = [[tags objectAtIndex:i][@"name"] sizeWithFont:[UIFont fontWithName:TAG_FONT_NAME size:TAG_FONT_SIZE] forWidth:TAG_MAX_WIDTH lineBreakMode:NSLineBreakByWordWrapping];
                height += size.height;
                width += (size.width + TAG_TITLE_PADDING + TAG_SPACE_PADDING);
                numberOfElementsInRow++;
                if (width < (self.view.frame.size.width - TAG_RIGHT_PADDING)) {
                    
                } else {
                    numberOfElementsInRow = 0;
                    width = (LEFT_PADDING + size.width + TAG_TITLE_PADDING + TAG_SPACE_PADDING);
                    x = LEFT_PADDING;
                    y += TAG_BUTTON_HEIGHT + TAG_TOP_PADDING;
                }
                
                CustomButton *tagBtn = (CustomButton *)[cell.contentView viewWithTag:[[NSString stringWithFormat:@"%d%d",indexPath.section,i+1]intValue]];
                if (!tagBtn) {
                    tagBtn = [CustomButton buttonWithType:UIButtonTypeCustom];
                }
                tagBtn.hidden = NO;
                tagBtn.buttonId = [tags objectAtIndex:i][@"_id"];
                tagBtn.category = sectionInfo[@"title"];
                tagBtn.indexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                tagBtn.tag = [[NSString stringWithFormat:@"%d%d",indexPath.section,i+1]integerValue];
                tagBtn.titleLabel.font = [UIFont fontWithName:TAG_FONT_NAME size:TAG_FONT_SIZE];
                tagBtn.frame = CGRectMake(x, y, size.width + TAG_TITLE_PADDING, TAG_BUTTON_HEIGHT);
                [tagBtn setTitle:[tags objectAtIndex:i][@"name"] forState:UIControlStateNormal];
                [tagBtn addTarget:self action:@selector(searchTagTapped:) forControlEvents:UIControlEventTouchUpInside];
                // Must set the label background to clear so the layer background shows
                isIPhone
                    tagBtn.backgroundColor = [UIColor clearColor];
                else
                    tagBtn.backgroundColor = [UIColor whiteColor];
                // Set UILabel.layer.backgroundColor not UILabel.backgroundColor otherwise the background is not masked to the rounded border.
                if (!tagBtn.enabled) {
                    tagBtn.enabled = NO;
                    [tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal] ;
                    tagBtn.layer.backgroundColor = [UIColor colorWithHexString:TAG_BORDER_COLOR].CGColor;
                    tagBtn.layer.borderWidth = 0.0;
                }else {
                    isIPhone
                        tagBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
                    else
                        tagBtn.layer.backgroundColor = [UIColor whiteColor].CGColor;
                    [tagBtn setTitleColor:[UIColor colorWithHexString:TAG_TITLE_COLOR] forState:UIControlStateNormal] ;
                    tagBtn.layer.borderWidth = TAG_BOARDER_WIDTH;
                }
                tagBtn.layer.cornerRadius = TAG_BUTTON_RADIUS;
                tagBtn.layer.borderColor = [UIColor colorWithHexString:TAG_BORDER_COLOR].CGColor;
                
                [cell.contentView addSubview:tagBtn];
                x += (size.width + TAG_TITLE_PADDING + TAG_SPACE_PADDING);
            }
        }
        
        [searchTable reloadData];
        
        //reload specific section animated
        //NSRange range   = NSMakeRange(indexPath.section, 1);
        //NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        //[searchTable reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
        //UIView *headerView = [searchTable headerViewForSection:indexPath.section];
        
        [searchTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        [searchTable beginUpdates];
        [searchTable endUpdates];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//#if DEBUG
//    NSLog(@"scrollViewWillBeginDragging %@",[NSString stringWithFormat:@"%f",scrollView.contentOffset.y]);
//#endif
    //[Flurry logEvent:@"Search- Scroll" withParameters:@{@"Starting Location": [NSString stringWithFormat:@"%f",scrollView.contentOffset.y]}];

}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//#if DEBUG
//    NSLog(@"scrollViewDidEndDecelerating %@",[NSString stringWithFormat:@"%f",scrollView.contentOffset.y]);
//#endif
    //[Flurry logEvent:@"Search- Scroll" withParameters:@{@"Ending Location": [NSString stringWithFormat:@"%f",scrollView.contentOffset.y]}];
    
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

-(IBAction)ButtonAction_Back:(id)sender
{
    [self textFieldShouldClear:_tokenFieldView.tokenField];
    [(IpadMainViewController *)self.parentViewController searchViewTransition];
}

@end
