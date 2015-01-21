//
//  ViewController.h
//  PhysicalCrowdsourcing
//
//  Created by Yongsung on 1/20/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController : UIViewController
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CMMotionActivityManager *motionManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKPointAnnotation *departurePin;
@property (strong, nonatomic) MKPointAnnotation *destinationPin;

@end

