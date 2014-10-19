//
//  ViewController.h
//  Magic8Bar
//
//  Created by Admin on 10/3/14.
//  Copyright (c) 2014 grizzchef. All rights reserved.


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kGOOGLE_API_KEY @"AIzaSyDtjV1ri5kZKMqkV6MDx_mhZgVlaBgzuRM"

@property (nonatomic, strong) CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property CLPlacemark *placemark;
@property CLGeocoder *geocoder;
@property float currentDist;
@property bool locationFound;

@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *latitude;

@property (strong, nonatomic) IBOutlet UILabel *firstLine;
@property (strong, nonatomic) IBOutlet UILabel *secondLine;
@property (strong, nonatomic) IBOutlet UILabel *thirdLine;
@property (strong, nonatomic) NSString *currentBar;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) IBOutlet UIButton *getDirections;
@property (strong, nonatomic) IBOutlet UILabel *allKnowingLabel;
@end

