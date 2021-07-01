//
//  TweetCell.m
//  twitter
//
//  Created by Kalkidan Tamirat on 6/29/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "TweetCell.h"
#import "APIManager.h"

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void) setTweet:(Tweet *)tweet{
    _tweet = tweet;
    self.usernameLabel.text = tweet.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    self.bodyLabel.text = tweet.text;
    self.dateLabel.text = tweet.createdAtString;
    NSString *favoriteCount = [NSString stringWithFormat:@"%d", tweet.favoriteCount];
    NSString *retweetCount = [NSString stringWithFormat:@"%d", tweet.retweetCount];
    [self.favoriteButton setTitle:favoriteCount forState:UIControlStateNormal];
    [self.retweetButton setTitle:retweetCount forState:UIControlStateNormal];
    
    [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateSelected];
    [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateSelected];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
    
    if(tweet.favorited == YES)
        self.favoriteButton.selected = YES;
    if(tweet.retweeted == YES)
        self.retweetButton.selected = YES;
    
    NSString *URLString = tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    UIImage *image =  [UIImage imageWithData:urlData];
    [self.profileView setImage:image];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)didTapRetweet:(UIButton *)sender {
    if (self.tweet.retweeted == NO) {
        //Retweet
        self.tweet.retweeted = YES;
        self.tweet.retweetCount++;
        
        [[APIManager shared] retweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error retweeting: %@", error.localizedDescription);
            }
            else{
                self.retweetButton.selected = YES;
                NSLog(@"Successfully retweeted the following Tweet: %@", tweet.text);
                [self refreshData];
            }
        }];
    } else {
        // Unretweet
        self.tweet.retweeted = NO;
        self.tweet.retweetCount--;
        self.retweetButton.selected = NO;
        
        [[APIManager shared] unretweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error unretweeting: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully unretweeted the following Tweet: %@", tweet.text);
                [self refreshData];
            }
        }];
    }
}

- (IBAction)didTapFavorite:(UIButton *)sender {
    if (self.tweet.favorited == NO) {
        self.tweet.favorited = YES;
        self.tweet.favoriteCount++;
        
        [self.favoriteButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateSelected];
        
        [self.favoriteButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
        
        self.favoriteButton.selected = YES;
        
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully favorited the following Tweet: %@", tweet.text);
                [self refreshData];
            }
        }];
    } else {
        self.tweet.favorited = NO;
        self.tweet.favoriteCount--;
        self.favoriteButton.selected = NO;
        
        [[APIManager shared] unfavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error unfavoriting tweet: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully unfavorited the following Tweet: %@", tweet.text);
                [self refreshData];
            }
        }];
    }
}

-(void) refreshData {
    self.usernameLabel.text = self.tweet.user.name;
    self.bodyLabel.text = self.tweet.text;
    NSString *favoriteCount = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
    NSString *retweetCount = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
    [self.favoriteButton setTitle:favoriteCount forState:UIControlStateNormal];
    [self.retweetButton setTitle:retweetCount forState:UIControlStateNormal];
}



@end
