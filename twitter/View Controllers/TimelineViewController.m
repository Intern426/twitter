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
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self loadTweets];
    
    [self.refreshControl addTarget:self action:@selector(loadTweets) forControlEvents:UIControlEventValueChanged]; //Deprecated and only used for older objects
    [self.tableView insertSubview:self.refreshControl atIndex:0]; // controls where you put it in the view hierarchy
    
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
    /*  [self.loadingActivityView startAnimating];
     NSURL *url =
     NSURLRequest *request = [NSURLRequest requestWithURL:nil cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
     NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
     session.configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
     
     NSURLSessionDataTask *task = session dataTaskWithRequest:request completionHandler: [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
     if (tweets) {
     NSLog(@"😎😎😎 Successfully loaded home timeline");
     self.arrayOfTweets = (NSMutableArray*) tweets;
     [self.tableView reloadData];
     [self.loadingActivityView stopAnimating];
     [self.refreshControl endRefreshing];
     } else {
     NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
     }
     }]; */
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
    UINavigationController *navigationControl = [segue destinationViewController];
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    Tweet* tweet = self.arrayOfTweets[indexPath.row];
    if (tweet == nil) {
        ComposeViewController *composeController = (ComposeViewController*)navigationControl.topViewController;
        composeController.delegate = self;
    } else {
        
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.tweet = tweet;
    }
}


- (void)didTweet:(Tweet *)tweet{
    [self.arrayOfTweets addObject:tweet];
    [self.tableView reloadData];
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
    Tweet* tweet = self.arrayOfTweets[indexPath.row];
    cell.tweet = tweet;
    cell.usernameLabel.text = tweet.user.name;
    cell.screenNameLabel.text = tweet.user.screenName;
    cell.bodyLabel.text = tweet.text;
    cell.dateLabel.text = tweet.createdAtString;
    NSString *favoriteCount = [NSString stringWithFormat:@"%d", tweet.favoriteCount];
    NSString *retweetCount = [NSString stringWithFormat:@"%d", tweet.retweetCount];
    [cell.favoriteButton setTitle:favoriteCount forState:UIControlStateNormal];
    [cell.retweetButton setTitle:retweetCount forState:UIControlStateNormal];
    
    [cell.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateSelected];
    [cell.retweetButton setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
    [cell.favoriteButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateSelected];
    [cell.favoriteButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
    
    if(tweet.favorited == YES)
        cell.favoriteButton.selected = YES;
    if(tweet.retweeted == YES)
        cell.retweetButton.selected = YES;
    
    NSString *URLString = tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    UIImage *image =  [UIImage imageWithData:urlData];
    [cell.profileView setImage:image];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTweets.count;
}


@end
