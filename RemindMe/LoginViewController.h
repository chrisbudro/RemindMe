//
//  LoginViewController.h
//  RemindMe
//
//  Created by Chris Budro on 9/1/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol LoginViewControllerDelegate <NSObject>

@optional
- (void)loginDidSucceedWithUser:(PFUser *)user;
- (void)loginDidFail;

@end

@interface LoginViewController : UIViewController

@property (weak, nonatomic) id <LoginViewControllerDelegate> delegate;

@end
