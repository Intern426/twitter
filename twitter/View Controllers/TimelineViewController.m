//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "APIManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TweetCell.h"
#import "ComposeViewController.h"
#import "DetailsViewController.h"



@interface TimelineViewController () <UITableViewDelegate, UITableViewDataSource, ComposeViewControllerDelegate>
@property (strong, nonatomic) NSMutableArray* arrayOfTweets;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityView;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero]; // While the table view is empty (i.e. fetching tweets),
                                                                               // keeps lines from showing up
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadTweets) forControlEvents:UIControlEventValueChanged]; //Deprecated and only used for older objects
    [self.tableView insertSubview:self.refreshControl atIndex:0]; // controls where you put it in the view hierarchy
    
    [self loadTweets];
}

-(void) loadTweets{
    // Get timeline
    [self.loadingActivityView startAnimating];
    
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            self.arrayOfTweets = (NSMutableArray*) tweets;
            [self.tableView reloadData];
            [self.loadingActivityView stopAnimating];
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:@"composeTweet"]) {
        UINavigationController *navigationControl = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationControl.topViewController;
        composeController.delegate = self;
    } else {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Tweet* tweet = self.arrayOfTweets[indexPath.row];
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.tweet = tweet;
    }
}


- (void)didTweet:(Tweet *)tweet{
    [self.arrayOfTweets addObject:tweet];
    [self loadTweets];
}

- (IBAction)logout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil]; // Access Main.storyboard
    
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"]; // Call forth the login view controller
    
    appDelegate.window.rootViewController = loginViewController; // Switch to the login screen
    
    [[APIManager shared] logout];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    cell.tweet = self.arrayOfTweets[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTweets.count;
}


@end
