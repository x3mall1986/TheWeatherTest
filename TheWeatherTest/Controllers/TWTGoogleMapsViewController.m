//
//  TWTGoogleMapsViewController.m
//  TheWeatherTest
//
//  Created by Dmytro Shevchuk on 02.07.16.
//  Copyright © 2016 PaksUkroInc. All rights reserved.
//

#import "TWTGoogleMapsViewController.h"
@import GoogleMaps;

CLLocationCoordinate2D const TWGKyivLocationCoordinate = {50.429, 30.537};

@interface TWTGoogleMapsViewController ()<GMSMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, readonly, strong) CLLocation *userLocation;

@end

@implementation TWTGoogleMapsViewController {
    GMSMapView *mapView_;
}

#pragma mark - lifecycle Methods
- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        self.locationManager.distanceFilter = 500;
        self.locationManager.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mapView_ = [GMSMapView new];
    mapView_.myLocationEnabled = YES;
    mapView_.delegate = self;
    self.view = mapView_;
    
    [self createMarkerOnTheMapWithCoordinates:TWGKyivLocationCoordinate];
    
    [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark - Addition Methods
- (void)createMarkerOnTheMapWithCoordinates:(CLLocationCoordinate2D)coordinate
{
    [self changeCameraPositionWithCoordinates:coordinate];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = coordinate;
    marker.map = mapView_;
}

- (void)changeCameraPositionWithCoordinates:(CLLocationCoordinate2D)coordinate
{
    [self changeCameraPositionWithCoordinates:coordinate withZoom:10];
}

- (void)changeCameraPositionWithCoordinates:(CLLocationCoordinate2D)coordinate withZoom:(NSInteger)zoom
{
    [mapView_ clear];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:zoom];
    
    [mapView_ animateToCameraPosition:camera];
}

- (CLLocationCoordinate2D)userGeoPosition
{
    mapView_.myLocationEnabled = YES;
    
    return mapView_.myLocation.coordinate;
}

#pragma mark - GMSMapViewDelegate
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if ([self.delegate respondsToSelector:@selector(userDidTapAtCoordinate:)]) {
        [self.delegate userDidTapAtCoordinate:coordinate];
    }
    
    [self createMarkerOnTheMapWithCoordinates:coordinate];
}

@end
