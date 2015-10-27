//
//  SignupViewController.m
//  RemindMe
//
//  Created by Chris Budro on 9/1/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import "SignupViewController.h"
#import <Parse/Parse.h>
#import "User.h"

@interface SignupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}
#pragma mark - Helper Methods

//Will need to add input verification but didn't have the time

- (void)signupUser {
  
  if ([PFAnonymousUtils isLinkedWithUser:[User currentUser]]) {
    User *newUser = [User currentUser];
    newUser.username = self.usernameTextField.text;
    newUser.password = self.passwordTextField.text;
    newUser.email = self.emailTextField.text;
    
    [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      if (error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was a problem with the signup.  Please try again" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:alertController animated:true completion:nil];
      } else if (succeeded) {
        [self.navigationController popToRootViewControllerAnimated:true];
      }
    }];
  } else {
    User *newUser = [User object];
    newUser.username = self.usernameTextField.text;
    newUser.password = self.passwordTextField.text;
    newUser.email = self.emailTextField.text;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      if (error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was a problem with the signup.  Please try again" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:alertController animated:true completion:nil];
      } else if (succeeded) {
        [self.navigationController popToRootViewControllerAnimated:true];
      }
    }];
  }
}

#pragma mark - IBActions

- (IBAction)cancelWasPressed {
  [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)signupWasPressed {
  [self signupUser];
  
}



@end
