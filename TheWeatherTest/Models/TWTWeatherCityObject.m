//
//  TWTWeatherCityObject.m
//  TheWeatherTest
//
//  Created by Dmytro Shevchuk on 04.07.16.
//  Copyright © 2016 PaksUkroInc. All rights reserved.
//

#import "TWTWeatherCityObject.h"

@implementation TWTWeatherCityObject

- (instancetype)initWithDictionaryObject:(NSDictionary *)dictionaryObject
{
    self = [super init];
    
    if (self) {
        self.humidity = dictionaryObject[@"main"][@"humidity"];
        self.temperature = [NSString stringWithFormat:@"%.f", [dictionaryObject[@"main"][@"temp"] floatValue]];
        self.windSpeed = dictionaryObject[@"wind"][@"speed"];
        self.name = dictionaryObject[@"name"];
        self.coordinate = CLLocationCoordinate2DMake([dictionaryObject[@"coord"][@"lat"] floatValue],
                                                     [dictionaryObject[@"coord"][@"lon"] floatValue]);
    }
    
    return self;   
}

@end
