//
//  CircleOverlay.h
//  RemindMe
//
//  Created by Chris Budro on 9/5/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CircleOverlay : MKCircle <MKOverlay>

@property (strong, nonatomic) UIColor *fillColor;
@property (strong, nonatomic) UIColor *strokeColor;

@end
