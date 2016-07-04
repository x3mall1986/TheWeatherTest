//
//  TWTAPIClient.m
//  TheWeatherTest
//
//  Created by Dmytro Shevchuk on 03.07.16.
//  Copyright © 2016 PaksUkroInc. All rights reserved.
//

#import "TWTAPIClient.h"

static NSString *const kCKBaseURLString = @"http://api.openweathermap.org/data/2.5/";

static NSString *const kWeatherApiKey = @"459fe39d57f3098467c086eb7f763d91";
static NSString *const kWeatherUnits = @"metric";
static NSString *const kWeatherLang = @"ru";

@implementation TWTAPIClient

#pragma mark - Initialization
+ (TWTAPIClient *)sharedClient
{
    static TWTAPIClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kCKBaseURLString]];
    });
    
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (void)weatherByGeoCoordinates:(NSDictionary *)geocoordinates success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    [self sendGetRequestForUrlPath:@"weather" withParameters:geocoordinates success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

- (void)citiesByName:(NSString *)name success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSDictionary *parameters = @{@"q": name, @"type": @"like"};
    [self sendGetRequestForUrlPath:@"find" withParameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

#pragma mark - API Request
- (void)sendGetRequestForUrlPath:(NSString *)urlPath withParameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableDictionary *mutableParameters = [parameters mutableCopy];
    mutableParameters[@"appid"] = kWeatherApiKey;
    mutableParameters[@"units"] = kWeatherUnits;
    
    [self GET:urlPath parameters:mutableParameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

@end
