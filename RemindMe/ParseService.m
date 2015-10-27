//
//  ReminderStore.m
//  RemindMe
//
//  Created by Chris Budro on 9/2/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import "ParseService.h"
#import "Reminder.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Constants.h"
#import "ReminderLocationManager.h"

@interface ParseService()

@property (strong, nonatomic) ReminderLocationManager *reminderLocationManager;

@end

@implementation ParseService

#pragma initialization

-(instancetype)init {
  if (self = [super init]) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newReminderFromNotification:) name:kNewReminderNotification object:nil];
    
    _reminderLocationManager = [[ReminderLocationManager alloc] init];
  }
  return self;
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)shared {
  static ParseService *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[self alloc] init];
  });
  return shared;
}

#pragma mark - Login Service

- (void)loginWithUsernameInBackground:(NSString *)username password:(NSString *)password block:(void (^)(User *user, NSError *error))handler {
  NSMutableArray *reminders = [User currentUser].reminders;
  [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
    if (error) {
      
      
    } else if (user) {
      User *newUser = (User *)user;
      if ([PFAnonymousUtils isLinkedWithUser:[User currentUser]]) {
        [newUser addUniqueObjectsFromArray:reminders forKey:@"reminders"];
        [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
          if (error) {
            NSLog(@"error: %@", error.localizedDescription);
            handler(newUser, error);
          } else if (succeeded) {
            NSLog(@"%@", reminders);
            for (Reminder *reminder in reminders) {
              reminder.user = newUser;
            }
            [PFObject saveAllInBackground:reminders block:^(BOOL succeeded, NSError *error) {
              if (error) {
                NSLog(@"Error saving reminders with new user");
                handler(newUser, error);
              } else if (succeeded) {
                NSLog(@"reminders saved successfully");
                handler(newUser, nil);
              }
            }];
          }
        }];
      } else {
        handler(newUser, nil);
      }
    }
  }];
}

- (void)logoutCurrentUserInBackgroundWithBlock:(void (^)(BOOL success, NSError *error))handler {
  [self fetchAllRemindersForCurrentUserWithBlock:^(NSArray *reminders, NSError *error) {
    if (error) {
      handler(false, error);
    } else {
      [self.reminderLocationManager stopMonitoringRegionsForReminders:reminders];
      [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
        if (error) {
          handler(false, error);
        } else {
          handler(true, nil);
        }
      }];
    }
  }];
}

#pragma mark - retrieve reminders

- (void)fetchAllRemindersForCurrentUserWithBlock:(void (^)(NSArray *reminders, NSError *error))handler {
  User *currentUser = [User currentUser];
  
  [PFObject fetchAllIfNeededInBackground:currentUser.reminders block:^(NSArray *reminders, NSError *error) {
    if (error) {
      handler(nil, error);
    } else {
      handler(reminders, nil);
    }
  }];
}

- (void)updateRegionsWithCloudReminders {
  [self fetchAllRemindersForCurrentUserWithBlock:^(NSArray *reminders, NSError *error) {
    if (error) {
      //handle error
    } else if (reminders) {
      [self.reminderLocationManager startMonitoringRemindersIfNeeded:reminders];
    }
  }];
}

- (void)cloudRemindersWithBlock:(void (^)(NSArray *reminders, NSError *error))handler {
  User *user = [User currentUser];
  if (!user.objectId) {
    [user saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
      PFQuery *query = [Reminder query];
      [query whereKey:@"user" equalTo:user];
      [query findObjectsInBackgroundWithBlock:^(NSArray *reminders, NSError *error) {
        handler(reminders, error);
      }];
    }];
  } else {
    NSLog(@"%@", user.objectId);
    PFQuery *query = [Reminder query];
    [query whereKey:@"user" equalTo:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *reminders, NSError *error) {
      handler(reminders, error);
    }];
  }
}

- (void)reminderWithObjectId:(NSString *)objectId withBlock:(void (^)(Reminder *reminder, NSError *error))handler {
  PFQuery *query = [Reminder query];
  [query whereKey:@"objectId" equalTo:objectId];
  [query findObjectsInBackgroundWithBlock:^(NSArray *reminders, NSError *error) {
    if (error) {
      NSLog(@"query error: %@", error.localizedDescription);
    } else if (reminders) {
      handler((Reminder *)reminders.firstObject, nil);
    }
  }];
}

#pragma mark - Create reminders

- (void)newReminderFromNotification:(NSNotification *)notification {
  NSDictionary * userInfo = notification.userInfo;
  Reminder *newReminder = userInfo[kReminder];
  [self addReminder:newReminder];
}

- (void)addReminder:(Reminder *)reminder {
  User *user = [User currentUser];
  reminder.user = user;
  
  [reminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    [self.reminderLocationManager startMonitoringReminder:reminder];
    if (error) {
      //Handle error
    } else if (succeeded) {
      [user addUniqueObject:reminder forKey:@"reminders"];
      [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //Handle error
      }];
    }
  }];
}

#pragma mark - delete reminders

- (void)removeReminder:(Reminder *)reminder {
  [self.reminderLocationManager stopMonitoringReminder:reminder];
  
  User *user = [User currentUser];
  if (user) {
    [user removeObject:reminder forKey:@"reminders"];
  }
  [reminder deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (error) {
      //Post notification for error
    }
  }];
}
@end
