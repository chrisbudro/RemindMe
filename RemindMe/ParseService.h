//
//  ReminderStore.h
//  RemindMe
//
//  Created by Chris Budro on 9/2/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class Reminder;

@interface ParseService : NSObject

@property (strong, nonatomic) NSMutableSet *reminderSet;
@property (strong, nonatomic) NSMutableArray *reminders;

+ (instancetype)shared;

- (void)cloudRemindersWithBlock:(void (^)(NSArray *reminders, NSError *error))handler;
- (void)reminderWithObjectId:(NSString *)objectId withBlock:(void (^)(Reminder *reminder, NSError *error))handler;

- (void)loginWithUsernameInBackground:(NSString *)username password:(NSString *)password block:(void (^)(User *user, NSError *error))handler;
- (void)logoutCurrentUserInBackgroundWithBlock:(void (^)(BOOL success, NSError *error))handler;

@end
