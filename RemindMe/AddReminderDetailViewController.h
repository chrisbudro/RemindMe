//
//  AddReminderDetailViewController.h
//  RemindMe
//
//  Created by Chris Budro on 8/31/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class Reminder;

@interface AddReminderDetailViewController : UIViewController

@property (strong, nonatomic) Reminder *reminder;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
