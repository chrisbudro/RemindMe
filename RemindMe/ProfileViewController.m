//
//  ProfileViewController.m
//  RemindMe
//
//  Created by Chris Budro on 9/1/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "User.h"
#import "ParseService.h"

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  LoginViewController *loginVC = (LoginViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
  
  if ([PFAnonymousUtils isLinkedWithUser:[User currentUser]]) {
    [self.navigationController pushViewController:loginVC animated:true];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  if ([PFUser currentUser]) {
    
  }
}
- (IBAction)logoutWasPressed:(UIButton *)sender {
  [[ParseService shared] logoutCurrentUserInBackgroundWithBlock:^(BOOL success, NSError *error) {
    if (error) {
      //handle error
    } else if (success) {
      
      LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
      [self.navigationController pushViewController:loginVC animated:true];
    }
  }];
  
}

@end
