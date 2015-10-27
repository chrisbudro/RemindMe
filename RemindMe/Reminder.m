//
//  Reminder.m
//  RemindMe
//
//  Created by Chris Budro on 8/31/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import "Reminder.h"

@implementation Reminder

@dynamic reminderName;
@dynamic geoPoint;
@dynamic user;
@synthesize regionRadius = _regionRadius;
@dynamic whenToNotify;
@synthesize circleOverlay = _circleOverlay;

+ (NSString *)parseClassName {
  return @"Reminder";
}

#pragma mark - Getters/Setters

- (CLLocationCoordinate2D)coordinate {
  double latitude = self.geoPoint.latitude;
  double longitude = self.geoPoint.longitude;
  return CLLocationCoordinate2DMake(latitude, longitude);
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
  double latitude = coordinate.latitude;
  double longitude = coordinate.longitude;
  
  self.geoPoint = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
}

-(NSString *)title {
  return self.reminderName;
}

-(MKCircle *)circleOverlay {
  if (!_circleOverlay) {
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.coordinate radius:self.regionRadius];
    _circleOverlay = circle;
  }
  return _circleOverlay;
}

-(void)setRegionRadius:(CLLocationDistance)regionRadius {
  NSNumber *radius = [NSNumber numberWithDouble:regionRadius];
  [self setObject:radius forKey:@"regionRadius"];
  self.circleOverlay = [MKCircle circleWithCenterCoordinate:self.coordinate radius:regionRadius];
}

-(CLLocationDistance)regionRadius {
  NSNumber *radius = [self objectForKey:@"regionRadius"];
  return radius.doubleValue;
}

@end
