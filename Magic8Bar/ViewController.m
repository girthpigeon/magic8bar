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
    
    [self fuckWithLayout];
    
    self.currentDist = 9000.0;
    //[self getCurrentLocation];
    
    
    self.lookingForBars = true;
}

-(void)fuckWithLayout
{
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    UIImage *image = [UIImage imageNamed:@"background"];
    
    CGRect frame = CGRectMake(0, 0, iOSDeviceScreenSize.width, iOSDeviceScreenSize.height);
    UIGraphicsBeginImageContext(frame.size);
    [image drawInRect:frame];
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(newPic);
    UIImage *resizedImage = [UIImage imageWithData:imageData];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:resizedImage]];

    
    //iphone 4
    if (iOSDeviceScreenSize.height == 480)
    {
        self.segmentedControl.transform = CGAffineTransformMakeTranslation(0, 100);
        self.shakebutton.transform = CGAffineTransformMakeTranslation(0, -40);
    }
    
    //iphone 5
    else if (iOSDeviceScreenSize.height == 568){
        
    }
    
    //iphone 6 and above
    else if (iOSDeviceScreenSize.height > 568){
        self.segmentedControl.transform = CGAffineTransformMakeTranslation(0, -50);
        //self.backgroundimage.transform = CGAffineTransformMakeTranslation(0, 200);
        //self.shakebutton.transform = CGAffineTransformMakeTranslation(0, 200);
    }
}

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake){
        [self fadeOut:self.triangle withDuration:2.0 andWait:0.0 FadeLevel:0.0];
        [self fadeOut:self.firstLine withDuration:2.0 andWait:0.0 FadeLevel:0.0];
        [self fadeOut:self.secondLine withDuration:2.0 andWait:0.0 FadeLevel:0.0];
        [self fadeOut:self.thirdLine withDuration:2.0 andWait:0.0 FadeLevel:0.0];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        //[self findBars:self];
        [self fadeIn:self.triangle withDuration:2.0 andWait:0.0 FadeLevel:1.0];
        [self fadeIn:self.firstLine withDuration:2.0 andWait:0.0 FadeLevel:1.0];
        [self fadeIn:self.secondLine withDuration:2.0 andWait:0.0 FadeLevel:1.0];
        [self fadeIn:self.thirdLine withDuration:2.0 andWait:0.0 FadeLevel:1.0];
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
    if(self.lookingForBars){
        if(!self.currentLocation){
            [self getCurrentLocation];
        } else {
            [self chooseASacrifice];
        }
    } else {
        [self chooseADrink];
    }

}

-(void)chooseADrink
{
    if (!self.drinks){
        [self getDrinks];
    } else {
        [self chooseAWhistleWetter];
    }
}

-(void)chooseAWhistleWetter
{
    self.firstLine.text = @"";
    self.secondLine.text = @"";
    self.thirdLine.text = @"";
    int theChosenOne = arc4random_uniform([self.drinks count]);
    NSString *winner = [self.drinks objectAtIndex:theChosenOne];
    
    [self parseResults:winner];
    
    //self.firstLine.text = [winner substringToIndex:winner.length-1];
}

-(void)getDrinks
{
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"drinklist" ofType:@"rtf"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
        NSLog(@"Error reading file: %@", error.localizedDescription);
    
    
    NSArray *listArray = [fileContents componentsSeparatedByString:@"\n"];
    NSLog(@"items = %@", listArray);
    
    self.drinks = [[NSMutableArray alloc] initWithArray:listArray];
    
    [self chooseAWhistleWetter];
    
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

-(void) queryGooglePlaces: (NSString *) placeType {
    
    //NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/xml?query=bars+in+Madison&key=AIzaSyDtjV1ri5kZKMqkV6MDx_mhZgVlaBgzuRM"];
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/radarsearch/json?location=%f,%f&radius=%f&types=%@&sensor=true&key=%@", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, self.currentDist, placeType, kGOOGLE_API_KEY];

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
    
    self.bars = [[NSMutableArray alloc] initWithArray:places];
    [self chooseASacrifice];
}

-(void)chooseASacrifice
{
    int theChosenOne = arc4random_uniform([self.bars count]);
    NSDictionary *winner = [self.bars objectAtIndex:theChosenOne];
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
    NSDictionary* geom = [christianValues objectForKey:@"geometry"];
    NSDictionary *point =  [geom objectForKey:@"location"];
    self.currentBarsLatitude = [point objectForKey:@"lat"];
    self.currentBarsLongitude = [point objectForKey:@"lng"];

    self.currentBar = saintName;
    [self parseResults:saintName];
}

-(void)parseResults:(NSString*)saintName
{
    NSInteger numChars = saintName.length;
    NSMutableArray *words = [[NSMutableArray alloc] init];
    NSMutableArray *wordLengths = [[NSMutableArray alloc] init];
    
    NSString *tempWord = @"";
    float tempLength = 0.0;
    for(int i=0; i < numChars; i++){
        char c = [saintName characterAtIndex:i];
        
        if(c == ' ' || i == numChars -1){
            
            if(i == numChars -1){
                tempWord = [NSString stringWithFormat:@"%@%c", tempWord, c];
                tempLength = tempLength + 1.0;
            }
            
            [words addObject:tempWord];
            [wordLengths addObject:[NSNumber numberWithFloat:tempLength]];
            tempLength = 0;
            tempWord = @"";
        } else {
            tempWord = [NSString stringWithFormat:@"%@%c", tempWord, c];
            tempLength = tempLength + 1.0;
        }
    }
    
    //divy it up
    //5/10 on first line
    //3/10 on second line
    //2/10 on the third line
    
    float cumalitve = 0.0f;
    
    self.firstLine.text = @"";
    self.secondLine.text = @"";
    self.thirdLine.text = @"";
    self.firstLine.transform = CGAffineTransformMakeTranslation(0, -10);
    self.secondLine.transform = CGAffineTransformMakeTranslation(0, -10);
    self.thirdLine.transform = CGAffineTransformMakeTranslation(0, -10);
    
    for(int i=0; i < [words count]; i++){
        NSString *word = [words objectAtIndex:i];
        float len = [[wordLengths objectAtIndex:i] floatValue];
        float percent = 10.0f * (len / numChars);
        cumalitve = cumalitve + percent;
        self.firstLine.alpha = 0;
        
        if( [word characterAtIndex:word.length-1] == '\\'){
            word = [word substringToIndex:word.length-1];
        }
        
        if(cumalitve < 6.0f || [self.firstLine.text isEqualToString:@""]){
            self.firstLine.text = [NSString stringWithFormat:@"%@ %@", self.firstLine.text, word];
        }
        else if (cumalitve < 8.0f || [self.secondLine.text isEqualToString:@""]){
            self.secondLine.text = [NSString stringWithFormat:@"%@ %@", self.secondLine.text, word];
        } else {
            self.thirdLine.text = [NSString stringWithFormat:@"%@ %@", self.thirdLine.text, word];
        }
    }
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         // moves label down 100 units in the y axis
                         self.firstLine.transform = CGAffineTransformMakeTranslation(0, 10);
                         // fade label in
                         self.firstLine.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                     }];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         // moves label down 100 units in the y axis
                         self.secondLine.transform = CGAffineTransformMakeTranslation(0, 10);
                         // fade label in
                         self.secondLine.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                     }];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         // moves label down 100 units in the y axis
                         self.thirdLine.transform = CGAffineTransformMakeTranslation(0, 10);
                         // fade label in
                         self.thirdLine.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                     }];

    
    NSLog(@"%@", words);
    
    //self.allKnowingLabel.text = saintName;
}

- (IBAction)getDirections:(id)sender {
    
    if(self.lookingForBars){
    
        if(![self.firstLine.text isEqualToString:@"Where should"]){
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f",[self.currentBarsLatitude floatValue], [self.currentBarsLongitude floatValue]]];
    //if (![[UIApplication sharedApplication] canOpenURL:url]) {
        NSLog(@"Google Maps app is not installed");
        
        //use maps
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.currentBarsLatitude floatValue], [self.currentBarsLongitude floatValue]);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
        item.name = self.currentBar;
        [item openInMapsWithLaunchOptions:nil];
        
        //left as an exercise for the reader: open the Google Maps mobile website instead!
    //} else {
      //  [[UIApplication sharedApplication] openURL:url];
    //}
        }
        
    } else {
        //google the drink
    }
}
- (IBAction)switched:(id)sender {
    if(self.segmentedControl.selectedSegmentIndex == 1){
        self.firstLine.text = @"What should";
        self.secondLine.text = @"I drink";
        self.thirdLine.text = @"tonight?";
        self.lookingForBars = false;
    } else {
        self.firstLine.text = @"Where should";
        self.secondLine.text = @"I go";
        self.thirdLine.text = @"tonight?";
        self.lookingForBars = true;
    }
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

-(void)fadeOut:(UIView*)viewToDissolve withDuration:(NSTimeInterval)duration
       andWait:(NSTimeInterval)wait FadeLevel:(float) fadeLevel
{
    [UIView beginAnimations: @"Fade Out" context:nil];
    [UIView setAnimationDelay:wait];
    [UIView setAnimationDuration:duration];
    viewToDissolve.alpha = fadeLevel;
    [UIView commitAnimations];
}

-(void)fadeIn:(UIView*)viewToFadeIn withDuration:(NSTimeInterval)duration
      andWait:(NSTimeInterval)wait FadeLevel:(float) fadeLevel
{
    [UIView beginAnimations: @"Fade In" context:nil];
    [UIView setAnimationDelay:wait];
    [UIView setAnimationDuration:duration];
    viewToFadeIn.alpha = fadeLevel;
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
