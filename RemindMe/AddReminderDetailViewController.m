//
//  AddReminderDetailViewController.m
//  RemindMe
//
//  Created by Chris Budro on 8/31/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

#import "AddReminderDetailViewController.h"
#import "Reminder.h"
#import "Constants.h"

CLLocationDistance kInitialRegionRadius = 50;

@interface AddReminderDetailViewController () <UITextFieldDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *reminderTitleTextField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *whenToNotifySegmentedControl;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (nonatomic) CLLocationDistance regionRadius;
@property (strong, nonatomic) MKCircle *regionCircle;
@property (weak, nonatomic) IBOutlet UILabel *radiusDisplayLabel;

@end

@implementation AddReminderDetailViewController

#pragma mark - Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
  self.mapView.delegate = self;
  [self.radiusSlider addTarget:self action:@selector(radiusSliderChanged:) forControlEvents:UIControlEventValueChanged];
  
  if (self.reminder.regionRadius) {
    self.regionRadius = self.reminder.regionRadius;
  } else {
    self.regionRadius = kInitialRegionRadius;
  }
  self.radiusSlider.value = self.regionRadius;

  if (self.reminder.whenToNotify) {
    self.whenToNotifySegmentedControl.selectedSegmentIndex = self.reminder.whenToNotify;
  } else {
    self.reminder.whenToNotify = self.whenToNotifySegmentedControl.selectedSegmentIndex;
  }

  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneWasPressed)];
  self.navigationItem.rightBarButtonItem = doneButton;
  
  if (self.reminder.title) {
    self.reminderTitleTextField.text = self.reminder.title;
  }
  MKCoordinateRegion reminderRegion = MKCoordinateRegionMakeWithDistance(self.reminder.coordinate, self.regionRadius * 2, self.regionRadius * 2);
  MKCoordinateRegion viewRegion = [self.mapView regionThatFits:reminderRegion];
  [self.mapView setRegion:viewRegion];
  
  [self.mapView addAnnotation:self.reminder];

  self.reminderTitleTextField.delegate = self;
  [self.reminderTitleTextField becomeFirstResponder];
  
}

#pragma mark - Helper Methods
- (void)newReminderWithTitle:(NSString *)title {
  if (![title isEqualToString:@""]) {
  self.reminder.reminderName = title;
  self.reminder.regionRadius = self.regionRadius;
  
  NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.reminder forKey:kReminder];
  [[NSNotificationCenter defaultCenter] postNotificationName:kNewReminderNotification object:nil userInfo:userInfo];
  }
}

- (void)radiusSliderChanged:(UISlider *)slider {
    self.regionRadius = slider.value;
}

- (void)updateUI {
  if (self.regionCircle) {
    [self.mapView removeOverlay:self.regionCircle];
  }
  self.regionCircle = [MKCircle circleWithCenterCoordinate:self.reminder.coordinate radius:self.regionRadius];
  [self.mapView addOverlay:self.regionCircle];
  self.radiusDisplayLabel.text = [NSString stringWithFormat:@"%.0fm", self.regionRadius];
}

#pragma mark - Actions

- (void)doneWasPressed {
  [self newReminderWithTitle:self.reminderTitleTextField.text];
  [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)whenToNotifySegControlWasPressed:(UISegmentedControl *)sender {
  self.reminder.whenToNotify = sender.selectedSegmentIndex;
}

#pragma mark - MapView Delegate

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
  
  MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
  renderer.strokeColor = [UIColor blueColor];
  renderer.lineWidth = 0.5;
  renderer.fillColor = [UIColor colorWithRed:204/255 green:175/255 blue:255/255 alpha:0.4];
  
  return renderer;
}

#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return true;
}

-(void)setRegionRadius:(CLLocationDistance)regionRadius {
  _regionRadius = regionRadius;
  [self updateUI];
}
@end
