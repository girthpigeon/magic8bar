//
//  ViewController.m
//  Magic8Bar
//
//  Created by Admin on 10/3/14.
//  Copyright (c) 2014 grizzchef. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currenDist = 9000.0;
    //[self getCurrentLocation];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self getCurrentLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    self.latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    self.currentLocation = location;
    
    
    
    NSLog(@"new coords: %@, %@", self.longitude, self.latitude);
    // Stop Location Manager
    [self.locationManager stopUpdatingLocation];
    
    [self queryGooglePlaces:@"bar"];
    
}


- (void)getCurrentLocation {
    
    if([CLLocationManager locationServicesEnabled])
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services are not enabled");
    }
    
}
- (IBAction)findBars:(id)sender {
    //[self queryGooglePlaces:@"bar"];
    [self getCurrentLocation];

}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}
/*
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = (CLLocation*)[locations objectAtIndex:[locations count] - 1];
    self.currentLocation = newLocation;
    self.longitude = [NSString stringWithFormat:@"%.8f", self.currentLocation.coordinate.longitude];
    self.latitude = [NSString stringWithFormat:@"%.8f", self.currentLocation.coordinate.latitude];
    
    NSLog(@"new coords: %@, %@", self.longitude, self.latitude);
    // Stop Location Manager
    [self.locationManager stopUpdatingLocation];
    
    //NSLog(@"Resolving the Address");
    [self.geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            self.placemark = [placemarks lastObject];
            self.country = self.placemark.country;
            self.state = self.placemark.administrativeArea;
            self.zip = self.placemark.postalCode;
            self.city = self.placemark.locality;
            self.address = [NSString stringWithFormat:@"%@, %@", self.placemark.subThoroughfare, self.placemark.thoroughfare];
            
            [self queryGooglePlaces:@"bars"];

        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}
*/
-(void) queryGooglePlaces: (NSString *) placeType {
    //NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/xml?query=bars+in+Madison&key=AIzaSyDtjV1ri5kZKMqkV6MDx_mhZgVlaBgzuRM"];
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/radarsearch/json?location=-33.8634,151.211&radius=3200.0&types=%@&sensor=true&key=%@", placeType, kGOOGLE_API_KEY];

    //NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&types=%@&sensor=true&key=%@", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, placeType, kGOOGLE_API_KEY];
    
    //Formulate the string as a URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

-(void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    int theChosenOne = arc4random_uniform([places count]);
    NSDictionary *winner = [places objectAtIndex:theChosenOne];
    NSString *savage = [winner objectForKey:@"place_id"];
    
    [self bringHimToMe:savage];
}

-(void)bringHimToMe:(NSString *)hisPagonName
{
    NSString *baptismHymn = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@", hisPagonName, kGOOGLE_API_KEY];
    
    
    NSURL *sacrificialURL=[NSURL URLWithString:baptismHymn];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* cleansingWaters = [NSData dataWithContentsOfURL: sacrificialURL];
        [self performSelectorOnMainThread:@selector(tellUsHisChristianName:) withObject:cleansingWaters waitUntilDone:YES];
    });

    
}

-(void)tellUsHisChristianName:(NSData *)johnTheBaptist
{
    NSError* heHasRebelled;
    NSDictionary* heHasBeenSaved = [NSJSONSerialization
                          JSONObjectWithData:johnTheBaptist
                          
                          options:kNilOptions
                          error:&heHasRebelled];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSDictionary* christianValues = [heHasBeenSaved objectForKey:@"result"];
    NSString *saintName = [christianValues objectForKey:@"name"];
    self.allKnowingLabel.text = saintName;
}


-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
