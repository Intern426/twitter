//
//  ComposeViewController.m
//  twitter
//
//  Created by Kalkidan Tamirat on 6/29/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"
#import "Tweet.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.text = @"What's happening?";
    self.textView.textColor = UIColor.grayColor;
}

- (IBAction)tapTweet:(UIBarButtonItem *)sender {
    if (self.textView.text.length != 0) {
        [[APIManager shared] postStatusWithText:self.textView.text completion:^(Tweet *tweet, NSError *error) {
           if (tweet) {
               NSLog(@"😎😎😎 Successfully posted tweet");
               [self.delegate didTweet:tweet];
               [self dismissViewControllerAnimated:true completion:nil];
           } else {
               NSLog(@"😫😫😫 Error posting: %@", error.localizedDescription);
           }
       }];
    }
}

- (IBAction)tapClose:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
