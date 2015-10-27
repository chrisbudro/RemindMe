//
//  LoginViewController.m
//  RemindMe
//
//  Created by Chris Budro on 9/1/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Reminder.h"
#import "ParseService.h"



@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

-(void)dealloc {
  
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)loginWasPressed {
  NSString *username = self.usernameTextField.text;
  NSString *password = self.passwordTextField.text;
  
  [[ParseService shared] loginWithUsernameInBackground:username password:password block:^(User *user, NSError *error) {
    if (error) {
      UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login Error" message:@"There was an error logging in.  Please try again." preferredStyle:UIAlertControllerStyleAlert];
      
      [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
      
      [self presentViewController:alert animated:true completion:nil];
    } else if (user) {
      [self.navigationController popToRootViewControllerAnimated:true];
    }
  }];
}

- (IBAction)signupWasPressed {
  [self performSegueWithIdentifier:@"ShowSignupVC" sender:self];
}

- (IBAction)cancelWasPressed {
  [self.navigationController popToRootViewControllerAnimated:true];
}

@end
