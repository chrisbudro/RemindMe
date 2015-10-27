//
//  Reminder.h
//  RemindMe
//
//  Created by Chris Budro on 8/31/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

typedef NS_ENUM(NSInteger, WhenToNotify) {
  NotifyWhenLeaving,
  NotifyWhenArriving,
};

@interface Reminder : PFObject <MKAnnotation, PFSubclassing>

@property (copy, readonly, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *reminderName;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) PFGeoPoint *geoPoint;
@property (strong, nonatomic) PFUser *user;
@property (nonatomic) CLLocationDistance regionRadius;
@property (strong, nonatomic) MKCircle *circleOverlay;
@property (nonatomic) enum WhenToNotify whenToNotify;

@end
