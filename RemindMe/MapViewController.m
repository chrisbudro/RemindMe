//
//  ViewController.m
//  RemindMe
//
//  Created by Chris Budro on 8/31/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ReminderLocationManager.h"
#import "AddReminderDetailViewController.h"
#import "Reminder.h"
#import <Parse/Parse.h>
#import "User.h"
#import "ParseService.h"
#import "Constants.h"
#import "CircleOverlay.h"

NSString *const kNewReminderPlaceholderText = @"New Reminder";
NSString *const kNewReminderPlaceholderSubtitle = @"add a reminder";

@interface MapViewController () <MKMapViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) ReminderLocationManager *locationManager;
@property (strong, nonatomic) MKPointAnnotation *placeholderAnnotation;
@property (strong, nonatomic) NSMutableDictionary *overlayForReminderIdDictionary;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation MapViewController

#pragma mark - Life Cycle Methods
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.overlayForReminderIdDictionary = [[NSMutableDictionary alloc] init];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newReminderAdded:) name:kNewReminderNotification object:nil];
  
  self.mapView.delegate = self;
  self.locationManager = [[ReminderLocationManager alloc] init];
  
  [self addSavedRemindersToMapView];
  [self showCurrentLocation];

  [self initLongPressGesture];
}

#pragma mark - Helper Methods
- (void)initLongPressGesture {
  self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
  [self.mapView addGestureRecognizer: self.longPressGesture];
}

- (void)addSavedRemindersToMapView {
  [[ParseService shared] cloudRemindersWithBlock:^(NSArray *allReminders, NSError *error) {
    if (error) {
      //Handle error
    }
    if (allReminders.count > 0) {
      [self.mapView showAnnotations:allReminders animated:true];
      for (Reminder *reminder in allReminders) {
        [self.overlayForReminderIdDictionary setObject:reminder.circleOverlay forKey:reminder.objectId];
        NSLog(@"reminder circle %@", reminder.circleOverlay);
        [self.mapView addOverlay:reminder.circleOverlay];
      }
    } else {
      [self goToCurrentLocation];
    }
  }];
}

- (void)showCurrentLocation {
  [self.locationManager requestAuthorizationWithBlock:^(BOOL success, NSString *error) {
    if (error) {
      NSLog(@"error: %@", error);
    } else if (success) {
      [self.mapView setShowsUserLocation:true];
    }
  }];
}

- (void)goToCurrentLocation {
  
}

- (void)newReminderAdded:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  Reminder *newReminder = userInfo[kReminder];
  [self.mapView addAnnotation:newReminder];
  [self.mapView selectAnnotation:newReminder animated:true];
  if (newReminder.objectId) {
    MKCircle *oldOverlay = [self.overlayForReminderIdDictionary objectForKey:newReminder.objectId];
    [self.mapView removeOverlay:oldOverlay];
    [self.overlayForReminderIdDictionary setObject:newReminder.circleOverlay forKey:newReminder.objectId];
  }
  [self.mapView addOverlay:newReminder.circleOverlay];
  self.placeholderAnnotation = nil;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
  if (gesture.state == UIGestureRecognizerStateEnded) {
    CGPoint pointInView = [gesture locationInView: self.mapView];
    CLLocationCoordinate2D coordinateInView = [self.mapView convertPoint:pointInView toCoordinateFromView:self.mapView];

    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinateInView;
    annotation.title = kNewReminderPlaceholderText;
    annotation.subtitle = kNewReminderPlaceholderSubtitle;
    self.placeholderAnnotation = annotation;
  }
}

- (void)presentCancelButton {
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelReminderCreation)];
  self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)dismissCancelButton {
  self.navigationItem.leftBarButtonItem = nil;
}

- (void)cancelReminderCreation {
  [self.mapView removeAnnotation:self.placeholderAnnotation];
  self.placeholderAnnotation = nil;
}

#pragma mark - Map View Delegate 

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return nil;
  }
  
  MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"PinAnnotationView"];
  
  
  if (pinView) {
    pinView.annotation = annotation;
  } else {
    pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PinAnnotationView"];
  }
  
  pinView.canShowCallout = true;
  
  if (![annotation isKindOfClass:[Reminder class]]) {
    pinView.animatesDrop = true;
  }
  
  UIButton *disclosureButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
//  [disclosureButton addTarget:nil action:nil forControlEvents: UIControlEventTouchUpInside];
  pinView.rightCalloutAccessoryView = disclosureButton;
  
  return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

  Reminder *reminder;
  
  if ([view.annotation isKindOfClass:[Reminder class]]) {
    reminder = (Reminder *)view.annotation;
  } else {
    reminder = [Reminder object];
    reminder.coordinate = view.annotation.coordinate;
  }

  AddReminderDetailViewController *reminderVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"ReminderDetailVC"];

  reminderVC.reminder = reminder;

  [self.navigationController pushViewController:reminderVC animated:true];
  
  [self.mapView deselectAnnotation:view.annotation animated:true];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
  if (mapView.annotations.count <= 1) {
    MKCoordinateRegion userRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 50, 50);
    MKCoordinateRegion viewRegion = [self.mapView regionThatFits:userRegion];
    [self.mapView setRegion:viewRegion animated:true];
  }
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {

  MKCircle *circle = (MKCircle *)overlay;
  MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithOverlay:circle];


  renderer.strokeColor = [UIColor blackColor];
  renderer.lineWidth = 0.5;
  renderer.fillColor = [UIColor colorWithRed:150/255 green:150/255 blue:255/255 alpha:0.3];
  return renderer;
}

#pragma mark - Setters/Getters

-(void)setPlaceholderAnnotation:(MKPointAnnotation *)placeholderAnnotation {
  if (placeholderAnnotation) {
    [self.mapView addAnnotation: placeholderAnnotation];
    [self.mapView selectAnnotation:placeholderAnnotation animated:true];
    [self presentCancelButton];
    self.longPressGesture.enabled = false;
  } else {
    [self.mapView removeAnnotation:_placeholderAnnotation];
    [self dismissCancelButton];
    self.longPressGesture.enabled = true;
  }
  _placeholderAnnotation = placeholderAnnotation;
}


@end



















