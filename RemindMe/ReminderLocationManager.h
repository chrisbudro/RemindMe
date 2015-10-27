//
//  LocationManager.h
//  RemindMe
//
//  Created by Chris Budro on 8/31/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class Reminder;

@interface ReminderLocationManager : NSObject <CLLocationManagerDelegate>

-(void)requestAuthorizationWithBlock:(void (^)(BOOL success, NSString *error))handler;
- (void)startMonitoringReminder:(Reminder *)reminder;
- (void)stopMonitoringReminder:(Reminder *)reminder;
- (void)startMonitoringRemindersIfNeeded:(NSArray *)reminders;
- (void)stopMonitoringRegionsForReminders:(NSArray *)reminders;

@end
