//
//  User.h
//  RemindMe
//
//  Created by Chris Budro on 9/1/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface User : PFUser <PFSubclassing>

@property (strong, nonatomic) NSMutableArray *reminders;


@end
