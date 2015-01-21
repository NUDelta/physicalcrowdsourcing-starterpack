//
//  ViewController.m
//  PhysicalCrowdsourcing
//
//  Created by Yongsung on 1/20/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Location Manager Setup
    [self locationManagerSetup];
    
    //Monitoring Region, default is delta lab
    [self monitoringRegionwithLatitude:42.056929 Longitude:-87.676519 Radius:100 Name:@"Delta Lab"];
    
    //MapView Setup
    [self mapViewSetup];
    
    //set departure and destination pins with latitude, longitude, and title
    [self setDeparturePinWithLatitude:42.052893 Longitude:-87.678309 Title:@"Departure"];
    [self setDestinationPinWithLatitude:42.056929 Longitude:-87.676519 Title:@"Destination"];
    
    //add pins to the map
    [self addPins];
    
    //Draw route from departure to destination pins
    [self drawRoute];
}

#pragma mark LocationManager Methods

- (void)locationManagerSetup {
    //Location Manager setup
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [self.locationManager requestAlwaysAuthorization];
    }
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)monitoringRegionwithLatitude: (float) latitude
                           Longitude: (float) longitude
                              Radius: (int) radius
                                Name: (NSString *) name
{

    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:center radius:radius identifier: name];
    [self.locationManager startMonitoringForRegion:region];
    [self.locationManager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Welcome to %@", region.identifier);
    [self triggerLocalNotification];
}

#pragma mark MapView Methods

- (void)mapViewSetup {
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
}

//Set region for map view
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    
    //one degree of latitude is always approximately 111 kilometers (69 miles).
    //one degree of longitude spans a distance of approximately 111 kilometers (69 miles) at the equator but shrinks to 0 kilometers at the poles.
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;
    [self.mapView setRegion:mapRegion animated: YES];
}

- (void)setDeparturePinWithLatitude: (float)latitude
                             Longitude: (float)longitude
                              Title: (NSString *)title
{
    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    self.departurePin = [[MKPointAnnotation alloc] init];
    self.departurePin.coordinate = center;
    self.departurePin.title = title;
}

- (void)setDestinationPinWithLatitude: (float)latitude
                            Longitude: (float)longitude
                                Title: (NSString *)title
{
    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    self.destinationPin = [[MKPointAnnotation alloc] init];
    self.destinationPin.coordinate = center;
    self.destinationPin.title = title;
}


- (void)addPins {
    [self.mapView addAnnotation:self.departurePin];
    [self.mapView addAnnotation:self.destinationPin];
}

- (void)drawRoute {
    MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:self.departurePin.coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil]];
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:self.destinationPin.coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil]];
    MKMapItem *srcMapItem = [[MKMapItem alloc] initWithPlacemark:source];
    MKMapItem *destMapItem = [[MKMapItem alloc] initWithPlacemark:destination];
    [srcMapItem setName:@"Departure"];
    [destMapItem setName:@"Destination"];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource: srcMapItem];
    [request setDestination: destMapItem];
    [request setTransportType:MKDirectionsTransportTypeWalking];
    
    //shows directions and draw route on the map
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSArray *arrayRoutes = [response routes];
        [arrayRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MKRoute *route = obj;
            MKPolyline *line = [route polyline];
            [self.mapView addOverlay:line];
            NSLog(@"Route Name: %@", route.name);
            NSLog(@"Total Distance :%f", route.distance);
            NSArray *steps = [route steps];
            NSLog(@"Total steps: %d", [steps count]);
            [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSLog(@"Route instruction : %@", [obj instructions]);
                NSLog(@"Route Distance: %f", [obj distance]);
            }];
        }];
    }];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *pview = [[MKPolylineView alloc] initWithOverlay:overlay];
        pview.strokeColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        pview.lineWidth = 17;
        return pview;
    }
    return nil;
}

//Can change annotation design here. By default departure pin color is green and destination pin color red.
- (MKAnnotationView *) mapView:(MKMapView *)mapView
             viewForAnnotation:(id <MKAnnotation>) annotation {
    MKPinAnnotationView *annotationView=[[MKPinAnnotationView alloc]
                                         initWithAnnotation:annotation reuseIdentifier:@"Source"];
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } else {
        if([[annotation title] isEqualToString:@"Departure"]) {
            annotationView.pinColor = MKPinAnnotationColorGreen;
        } else {
            annotationView.pinColor = MKPinAnnotationColorRed;
        }
        annotationView.canShowCallout = YES;
        return annotationView;
    }
}

- (void)triggerLocalNotification {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.alertBody = @"Physical Crowdsourcing!";

    localNotification.alertAction = @"Testing notification based on regions";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber]+1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
