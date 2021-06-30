//
//  Tweet.m
//  twitter
//
//  Created by Kalkidan Tamirat on 6/28/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "Tweet.h"
#import "User.h"
#import "DateTools.h"

@implementation Tweet


- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        
        // Handle retweet
        NSDictionary *originalTweet = dictionary[@"retweeted_status"];
        if(originalTweet != nil){
            NSDictionary *userDictionary = dictionary[@"user"];
            self.retweetedByUser = [[User alloc] initWithDictionary:userDictionary];
            
            // Change tweet to original tweet
            dictionary = originalTweet;
        }
        self.idStr = dictionary[@"id_str"];
        self.text = dictionary[@"full_text"];
        self.favoriteCount = [dictionary[@"favorite_count"] intValue];
        self.favorited = [dictionary[@"favorited"] boolValue];
        self.retweetCount = [dictionary[@"retweet_count"] intValue];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
        
        // initialize user
        NSDictionary* user = dictionary[@"user"];
        self.user = [[User alloc] initWithDictionary:user];
        
        // Format createdAt date string
        NSString *createdAtOriginalString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        // Configure the input format to parse the date string
        formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
        
        // Convert String to Date
        NSDate *date = [formatter dateFromString:createdAtOriginalString];
        NSDate *today = [NSDate date];
        
        NSInteger yearsApart = [today yearsFrom:date];
        NSInteger hoursApart = [today hoursFrom:date];
        NSInteger minutesApart = [today minutesFrom:date];
        
        if (yearsApart == 0) {
            // Format Date as # (hours/minutes) ago
            if (hoursApart == 0) {
                self.createdAtString = [NSString stringWithFormat:@"%dm", minutesApart];
            } else if (hoursApart < 24){
                self.createdAtString = [NSString stringWithFormat:@"%dh", hoursApart];
            } else {
                // Format Date as Month Day, Year
                formatter.dateStyle = NSDateFormatterMediumStyle;
            }
        } else {
            formatter.dateStyle = NSDateFormatterNoStyle;
            formatter.timeStyle = NSDateFormatterShortStyle;
            self.createdAtString = [formatter stringFromDate:date];
        }
    }
    return self;
}

+ (NSMutableArray *)tweetsWithArray:(NSArray *)dictionaries{
    NSMutableArray *tweets = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:dictionary];
        [tweets addObject:tweet];
    }
    return tweets;
}
@end
