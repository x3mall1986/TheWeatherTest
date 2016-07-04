//
//  TWTGoogleMapsViewController.h
//  TheWeatherTest
//
//  Created by Dmytro Shevchuk on 02.07.16.
//  Copyright © 2016 PaksUkroInc. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;

@protocol TWTGoogleMapsEventsDelegate <NSObject>

- (void)userDidTapAtCoordinate:(CLLocationCoordinate2D)coordinate;

@end

@interface TWTGoogleMapsViewController : UIViewController

@property (weak, nonatomic) id<TWTGoogleMapsEventsDelegate>delegate;

- (void)createMarkerOnTheMapWithCoordinates:(CLLocationCoordinate2D)coordinate;
- (CLLocationCoordinate2D)userGeoPosition;
- (void)changeCameraPositionWithCoordinates:(CLLocationCoordinate2D)coordinate;

extern CLLocationCoordinate2D const TWGKyivLocationCoordinate;

@end
