//
//  TWTAPIClient.h
//  TheWeatherTest
//
//  Created by Dmytro Shevchuk on 03.07.16.
//  Copyright © 2016 PaksUkroInc. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface TWTAPIClient : AFHTTPSessionManager

+ (TWTAPIClient *)sharedClient;

#pragma mark -
- (void)weatherByGeoCoordinates:(NSDictionary *)geocoordinates
                        success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                        failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)citiesByName:(NSString *)name
             success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
             failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
