//
//  LocationManager.m
//  RemindMe
//
//  Created by Chris Budro on 8/31/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import "ReminderLocationManager.h"
#import "Reminder.h"
#import "User.h"
#import <Parse/Parse.h>
#import "ParseService.h"
#import "Constants.h"

CLLocationDistance kStandardRegionRadius = (double)50.0;

@interface ReminderLocationManager()
@property (strong, nonatomic) CLLocationManager *manager;
@property (copy, nonatomic) void (^locationAuthHandler)(BOOL success, NSString *error);
@end

@implementation ReminderLocationManager

- (instancetype)init {
  if (self = [super init]) {
    _manager = [[CLLocationManager alloc] init];
    _manager.delegate = self;
  }
  return self;
}

- (void)requestAuthorizationWithBlock:(void (^)(BOOL success, NSString *error))handler {
  if ([CLLocationManager locationServicesEnabled] &&
      [CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
    switch ([CLLocationManager authorizationStatus]) {
      case kCLAuthorizationStatusAuthorizedAlways:
      case kCLAuthorizationStatusAuthorizedWhenInUse:
        handler(true, nil);
        break;
      case kCLAuthorizationStatusNotDetermined:
        self.locationAuthHandler = handler;
        [self.manager requestAlwaysAuthorization];
        break;
      default:
        handler(false, @"Not authorized");
        break;
    }
  } else {
    handler(false, @"Location Services are not available");
  }
}

- (void)startMonitoringReminder:(Reminder *)reminder {
  NSLog(@"%f, %f", reminder.coordinate.latitude, reminder.coordinate.longitude);
  NSLog(@"%@", reminder.objectId);
  CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:reminder.coordinate radius:reminder.regionRadius identifier:reminder.objectId];
  [self.manager startMonitoringForRegion:region];
}

- (void)stopMonitoringReminder:(Reminder *)reminder {
  for (CLCircularRegion *region in self.manager.monitoredRegions) {
    if ([region.identifier isEqualToString:reminder.objectId]) {
      [self.manager stopMonitoringForRegion:region];
    }
  }
}

- (void)startMonitoringRemindersIfNeeded:(NSArray *)reminders {
  for (Reminder *reminder in reminders) {
    BOOL isMonitored = false;
    for (CLCircularRegion *region in self.manager.monitoredRegions) {
      if ([reminder.objectId isEqualToString:region.identifier]) {
        isMonitored = true;
        break;
      }
    }
    if (!isMonitored) {
      CLCircularRegion *newRegion = [[CLCircularRegion alloc] initWithCenter:reminder.coordinate radius:reminder.regionRadius identifier:reminder.objectId];
      [self.manager startMonitoringForRegion:newRegion];
    }
  }
}

- (void)stopMonitoringRegionsForReminders:(NSArray *)reminders {
  
  for (Reminder *reminder in reminders) {
    for (CLCircularRegion *region in self.manager.monitoredRegions) {
      if ([region.identifier isEqualToString:reminder.objectId]) {
        [self.manager stopMonitoringForRegion:region];
      }
    }
  }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
      [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
    
    if (self.locationAuthHandler) {
      self.locationAuthHandler(true, nil);
    }
  } else {
    if (self.locationAuthHandler) {
      self.locationAuthHandler(false, @"Not authorized");
    }
  }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
  [[ParseService shared] reminderWithObjectId:region.identifier withBlock:^(Reminder *reminder, NSError *error) {
    if (reminder) {
      if (reminder.whenToNotify == NotifyWhenArriving) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertTitle = reminder.title;
        notification.alertBody = reminder.title;
        notification.userInfo = [NSDictionary dictionaryWithObject:reminder.title forKey:kReminder];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
      }
    } else {
      [manager stopMonitoringForRegion:region];
    }
  }];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
  [[ParseService shared] reminderWithObjectId:region.identifier withBlock:^(Reminder *reminder, NSError *error) {
    if (reminder) {
      if (reminder.whenToNotify == NotifyWhenLeaving) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertTitle = reminder.title;
        notification.alertBody = reminder.title;
        notification.userInfo = [NSDictionary dictionaryWithObject:reminder.title forKey:kReminder];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
      }
    } else {
      [manager stopMonitoringForRegion:region];
    }
  }];
}

@end
