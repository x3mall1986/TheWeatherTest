//
//  ViewController.m
//  TheWeatherTest
//
//  Created by Dmytro Shevchuk on 02.07.16.
//  Copyright © 2016 PaksUkroInc. All rights reserved.
//

#import "ViewController.h"
#import "TWTAPIClient.h"
#import "TWTGoogleMapsViewController.h"
#import "TWTWeatherCityObject.h"

@import MBProgressHUD;

@interface ViewController ()<TWTGoogleMapsEventsDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *dropdownCityTextField;
@property (weak, nonatomic) IBOutlet UITableView *autocompleteTableView;
@property (weak, nonatomic) IBOutlet UITextView *weatherInfoTextView;
@property (weak, nonatomic) IBOutlet UIButton *currentGeoButton;

@property (strong, nonatomic, readonly) TWTGoogleMapsViewController *googleMapViewController;
@property (strong, nonatomic) NSArray *cityObjects;
@property (strong, nonatomic) NSDictionary *cityWeatherValues;

- (IBAction)currentGeoButtonTapped:(UIButton *)sender;
- (IBAction)dropdownCityTextFieldValueChanged:(UITextField *)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.googleMapViewController.delegate = self;
    
    [self weatherByCoordinates:TWGKyivLocationCoordinate];
}

- (TWTGoogleMapsViewController *)googleMapViewController
{
    return self.childViewControllers.lastObject;
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section
{
    return [self.cityObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *autoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:autoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:autoCompleteRowIdentifier];
    }
    
    TWTWeatherCityObject *cityObject = self.cityObjects[indexPath.row];
    cell.textLabel.text = cityObject.name;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    self.dropdownCityTextField.text = selectedCell.textLabel.text;
    
    NSArray *filtered = [self.cityObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)",
                                                                       selectedCell.textLabel.text]];
    
    TWTWeatherCityObject *cityObject = [filtered firstObject];
    [self weatherByCoordinates:cityObject.coordinate];
    
    // Clean up UI
    [self.dropdownCityTextField resignFirstResponder];
    self.autocompleteTableView.hidden = YES;
}

#pragma mark - Addition Methods
- (void)weatherByCoordinates:(CLLocationCoordinate2D)coordinate
{
    self.currentGeoButton.enabled = YES;
    
    [self weatherByCoordinates:coordinate withMarker:YES];
}

- (void)weatherByCoordinates:(CLLocationCoordinate2D)coordinate withMarker:(BOOL)showMarker
{
    NSDictionary *dictionaryCoordinates = @{@"lat": @(coordinate.latitude),
                                            @"lon": @(coordinate.longitude)};
    
    if ([MBProgressHUD allHUDsForView:self.view].count == 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [[TWTAPIClient sharedClient] weatherByGeoCoordinates:dictionaryCoordinates success:^(NSURLSessionDataTask *task, id responseObject) {
        
        TWTWeatherCityObject *cityObject = [[TWTWeatherCityObject alloc] initWithDictionaryObject:responseObject];
        self.weatherInfoTextView.text = [NSString stringWithFormat:@"Город: %@\n\nТемпература на сегодня: %@\nВлажность: %@\nСкорость ветра: %@",
                                         cityObject.name, cityObject.temperature, cityObject.humidity, cityObject.windSpeed];
        
        if (showMarker) {
            [self.googleMapViewController createMarkerOnTheMapWithCoordinates:coordinate];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error.description);
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)searchCityByName:(NSString *)name
{
    if ([MBProgressHUD allHUDsForView:self.view].count == 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [[TWTAPIClient sharedClient] citiesByName:name success:^(NSURLSessionDataTask *task, id responseObject) {
        //        NSLog(@"%@", responseObject);
        
        NSMutableArray *cityObjectsMutable = [@[] mutableCopy];
        for (NSDictionary *cityDictionary in responseObject[@"list"]) {
            TWTWeatherCityObject *cityObject = [[TWTWeatherCityObject alloc] initWithDictionaryObject:cityDictionary];
            [cityObjectsMutable addObject:cityObject];
        }
        
        self.cityObjects = [cityObjectsMutable copy];
        
        if (((NSNumber *)(responseObject[@"count"])).integerValue > 0) {
            self.autocompleteTableView.hidden = NO;
        } else {
            self.autocompleteTableView.hidden = YES;
        }
        
        [self.autocompleteTableView reloadData];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error.description);
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - Actions
- (IBAction)currentGeoButtonTapped:(UIButton *)sender
{
    CLLocationCoordinate2D coordinate = [self.googleMapViewController userGeoPosition];
    
    if (coordinate.longitude == 0 && coordinate.latitude == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Координаты недоступны" message:@"Проверьте, включены ли в настройках приложения определения местоположения и разрешено ли использование местоположения пользователя для приложения" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    sender.enabled = NO;
    
    [self weatherByCoordinates:coordinate withMarker:NO];
    [self.googleMapViewController changeCameraPositionWithCoordinates:coordinate];
}

- (IBAction)dropdownCityTextFieldValueChanged:(UITextField *)sender
{
    // Delay the search 0.5 second to minimize outstanding requests
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(searchCityByName:) withObject:sender.text afterDelay:0.5];
}

#pragma mark - GoogleMapsEventsDelegate
- (void)userDidTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self weatherByCoordinates:coordinate];
}

@end
