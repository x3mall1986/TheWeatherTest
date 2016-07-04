//
//  TWTWeatherCityObject.h
//  TheWeatherTest
//
//  Created by Dmytro Shevchuk on 04.07.16.
//  Copyright © 2016 PaksUkroInc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface TWTWeatherCityObject : NSObject

@property (strong, nonatomic) NSString *humidity;
@property (strong, nonatomic) NSString *temperature;
@property (strong, nonatomic) NSString *windSpeed;
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

- (instancetype)initWithDictionaryObject:(NSDictionary *)dictionaryObject;

@end
