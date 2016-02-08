//
//  ASMapViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 27/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASMapViewController.h"
#import "AGApiController.h"
#import "UIStoryboard+ASHelper.h"
#import "ASModel.h"
#import "ASPointAnnotation.h"
#import "ASFriendAnnotation.h"
#import "ASLastPointAnnotation.h"
#import "UIImage+ASAnnotations.h"
#import "UIColor+ASColor.h"
#import "ASMapDetailsView.h"
#import "ASDashedLine.h"
#import <THDatePickerViewController.h>
#import "ASDisplayOptionsViewController.h"

#define QUERY_RATE_IN_SECONDS 15

@interface ASMapViewController () <MKMapViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource, THDatePickerDelegate>
- (IBAction)tapHandle:(id)sender;

@property (weak, nonatomic) IBOutlet UIView           *filterPlank;
@property (weak, nonatomic) IBOutlet UITextField      *filterTextField;
@property (weak, nonatomic) IBOutlet ASMapDetailsView *detailsPlank;
@property (weak, nonatomic) IBOutlet ASDashedLine     *dashedLineView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureDetails;

@property (nonatomic        ) NSArray                    *originalPointsData;
@property (nonatomic        ) CLLocationManager          *locationManager;
@property (nonatomic        ) NSTimer                    *timer;
@property (nonatomic        ) NSTimer                    *timerForTrackQuery;
@property (nonatomic        ) CAShapeLayer               *shapeLayer;
@property (nonatomic        ) NSDate                     *selectedDate;

@property (nonatomic        ) AGApiController            *apiController;
@property (nonatomic        ) THDatePickerViewController *datePicker;

@property (nonatomic        ) ASFriendModel              *userToFilter;

@property (nonatomic        ) NSDictionary *colorsDictionary;
@property (nonatomic, assign) BOOL isFirstLaunch;
@property (nonatomic, assign) BOOL isUserLocationCentered;
@end

@implementation ASMapViewController

objection_requires(@keypath(ASMapViewController.new, apiController))

+(instancetype)initialize
{
    return [[UIStoryboard mapStoryboard] instantiateInitialViewController];
}

#pragma mark - view controller methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    self.isFirstLaunch = YES;
    [self configFilter];
    
    UIBarButtonItem *rightBBI;

    if (self.isHistoryMode) {
        rightBBI = [[UIBarButtonItem alloc] initWithTitle:@""
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(calendarTap:)];
        rightBBI.image = [UIImage imageNamed:@"calendarIcon"];
    } else {
        rightBBI = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Remove tracks", nil)
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(removeTracksTap)];
    }
    
    self.navigationItem.rightBarButtonItem = rightBBI;
    
    self.mapView.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
//    [self.locationManager startUpdatingLocation];
    
    [self changeMapType:2];

    self.mapView.showsUserLocation = YES;
    
    self.filterTextField.enabled = NO;
    
//    NSDate *from = [NSDate dateWithTimeIntervalSince1970:1410739200];
//    NSDate *to = [NSDate dateWithTimeIntervalSince1970:1410868800];
//    [self loadTrackingPointsFrom:from to:to];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.016
                                                  target:self
                                                selector:@selector(timerTick:)
                                                userInfo:nil
                                                 repeats:YES];
    self.timerForTrackQuery = [NSTimer scheduledTimerWithTimeInterval:QUERY_RATE_IN_SECONDS
                                                               target:self
                                                             selector:@selector(timerForQueryTick:)
                                                             userInfo:nil
                                                              repeats:YES];
    [self.timerForTrackQuery fire];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshLine];
}

#pragma mark - IBActions and Handlers

- (IBAction)photoActionTap:(id)sender {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Screenshot taken", nil)
                               message:NSLocalizedString(@"Saved in Gallery", nil)
                              delegate:nil
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil] show];
}

- (IBAction)mapTypeValueChanged:(UISegmentedControl*)sender {
    [self changeMapType:sender.selectedSegmentIndex];
}

-(void)changeMapType:(NSInteger)mapType {
    if (mapType == 0) {
        self.mapView.mapType = MKMapTypeSatellite;
        [self.mapView removeOverlays:self.mapView.overlays];
    } else if (mapType == 1) {
        self.mapView.mapType = MKMapTypeStandard;
        [self.mapView removeOverlays:self.mapView.overlays];
    } else {
        static NSString * const templateWorld = @"http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}";
        MKTileOverlay *overlayWorld = [[MKTileOverlay alloc] initWithURLTemplate:templateWorld];
        overlayWorld.canReplaceMapContent = YES;
        [self.mapView addOverlay:overlayWorld
                           level:MKOverlayLevelAboveLabels];
        
        static NSString * const templateNorway = @"http://opencache.statkart.no/gatekeeper/gk/gk.open_gmaps?layers=topo2&zoom={z}&x={x}&y={y}&format=image/png";
        MKTileOverlay *overlayNorway = [[MKTileOverlay alloc] initWithURLTemplate:templateNorway];
        overlayNorway.canReplaceMapContent = YES;
        [self.mapView addOverlay:overlayNorway
                           level:MKOverlayLevelAboveLabels];
        
    }
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    }
    
    return nil;
}

-(void)doneTapped:(id)sender
{
    [self.filterTextField resignFirstResponder];
}

-(void)removeTracksTap
{
    [self.mapView removeAnnotations:self.mapView.annotations];
}

-(void)timerTick:(NSTimer*)timer
{
    [self refreshLine];
}

-(void)refreshLine {
    CGPoint startPoint = [self.mapView convertCoordinate:self.mapView.userLocation.coordinate
                                           toPointToView:self.mapView];
    CGFloat newX = startPoint.x;
    CGFloat newY = startPoint.y;
    
    if (startPoint.x > self.dashedLineView.frame.size.width) {
        newX = self.dashedLineView.frame.size.width;
        CGFloat k = newX/startPoint.x;
        newY = startPoint.y*k;
    } else if (startPoint.y > self.dashedLineView.frame.size.height) {
        newY = self.dashedLineView.frame.size.height;
        CGFloat k = newY/startPoint.y;
        newX = startPoint.x*k;
    }
    
    self.dashedLineView.userLocationPoint = CGPointMake(newX, newY);
    [self.dashedLineView setNeedsDisplay];
    
    // whats faster, drawInRect or CAShapeLayer?
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.timer invalidate];
    [self.timerForTrackQuery invalidate];
}

-(void)timerForQueryTick:(NSTimer*)timer {
    [self loadTracks];
}

-(void)loadTracks {
//    NSDate *from = [NSDate dateWithTimeIntervalSince1970:1410739200];
//    NSDate *to = [NSDate dateWithTimeIntervalSince1970:1410868800];
    NSDate *from;
    NSDate *to;
    if (!self.selectedDate) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *duration = [defaults objectForKey:kTrackingDurationKey];
        to = [NSDate date];
        from = [to dateByAddingTimeInterval:-60*duration.integerValue];
    } else {
        from = self.selectedDate;
        to = [self.selectedDate dateByAddingTimeInterval:60*60*24];
    }
    
    [self loadTrackingPointsFrom:from to:to];
}

- (IBAction)calendarTap:(id)sender {
    if(!self.datePicker)
        self.datePicker = [THDatePickerViewController datePicker];
    self.datePicker.date = [NSDate date];
    self.datePicker.delegate = self;
    [self.datePicker setAllowClearDate:NO];
    [self.datePicker setClearAsToday:YES];
    [self.datePicker setAutoCloseOnSelectDate:YES];
    [self.datePicker setAllowSelectionOfSelectedDate:YES];
    [self.datePicker setDisableHistorySelection:NO];
    [self.datePicker setDisableFutureSelection:YES];
    [self.datePicker setSelectedBackgroundColor:[UIColor colorWithRed:125/255.0 green:208/255.0 blue:0/255.0 alpha:1.0]];
    [self.datePicker setCurrentDateColor:[UIColor colorWithRed:242/255.0 green:121/255.0 blue:53/255.0 alpha:1.0]];
    
    [self.datePicker setDateHasItemsCallback:^BOOL(NSDate *date) {
        int tmp = (arc4random() % 30)+1;
        if(tmp % 5 == 0)
            return YES;
        return NO;
    }];
    //[self.datePicker slideUpInView:self.view withModalColor:[UIColor lightGrayColor]];
    self.datePicker.date = self.selectedDate;
    [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(0.33),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                                  }];
    
}

- (IBAction)tapHandle:(id)sender {
    self.detailsPlank.hidden = YES;
    self.tapGestureDetails.enabled = NO;
}

#pragma mark - Private methods

-(void)loadTrackingPointsFrom:(NSDate*)from to:(NSDate*)to {
    [[self.apiController getTrackingPointsFrom:from to:to friendId:nil] subscribeNext:^(id x) {
        self.originalPointsData = x;
        [self showAllPointsForUsers:x filterFor:self.userToFilter];
        self.filterTextField.enabled = YES;
    }] ;
//    [self.timerForTrackQuery invalidate];
//    [[[[[self.apiController getTrackingPointsFrom:from to:to friendId:nil] repeat] take:1] doNext:^(id x) {
//        NSLog(@"do next");
//    }] subscribeNext:^(id x) {
//        NSLog(@"subscrive next");
//    }];
}

-(void)fillColorsDictionaryWithUsers:(NSArray *)users {
    NSMutableDictionary *result = @{}.mutableCopy;
    for (ASFriendModel *user in users) {
        result[user.userName] = [UIColor getRandomColor];
    }
    
    self.colorsDictionary = result;
}

-(void)showAllPointsForUsers:(NSArray*)users filterFor:(ASFriendModel*)user
{
    if (!self.colorsDictionary) {
        [self fillColorsDictionaryWithUsers:users];
    }
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    if (!user) {
        for (ASFriendModel *friendModel in users) {
            [self showPointsForUser:friendModel];
        }
    } else {
        for (ASFriendModel *friendModel in users) {
            if ([friendModel.userName isEqualToString:user.userName]) {
                [self showPointsForUser:friendModel];
            }
        }
    }
}

-(void)showPointsForUser:(ASFriendModel*)friendModel
{
    UIColor *colorForUser = self.colorsDictionary[friendModel.userName];
    CLLocationCoordinate2D friendCoord = CLLocationCoordinate2DMake(friendModel.latitude.doubleValue, friendModel.longitude.doubleValue);
    ASFriendAnnotation *friendAnnotation = [[ASFriendAnnotation alloc] initWithLocation:friendCoord];
    friendAnnotation.annotationColor = colorForUser;
    friendAnnotation.userObject = friendModel;
    [self.mapView addAnnotation:friendAnnotation];
    
    for (ASDeviceModel *deviceModel in friendModel.devices) {
        if ((deviceModel.points.count == 0) && (self.isHistoryMode)) {
            CLLocationCoordinate2D deviceCoord = CLLocationCoordinate2DMake(deviceModel.latitude.doubleValue, deviceModel.longitude.doubleValue);
            ASLastPointAnnotation *deviceAnnotation = [[ASLastPointAnnotation alloc] initWithLocation:deviceCoord];
            deviceAnnotation.annotationColor = colorForUser;
            deviceAnnotation.deviceObject = deviceModel;
            [self.mapView addAnnotation:deviceAnnotation];
        }
        for (ASPointModel *pointModel in deviceModel.points) {
            ASDevicePointAnnotation *annotation;
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(pointModel.latitude.doubleValue, pointModel.longitude.doubleValue);
            if (pointModel == deviceModel.points.lastObject) {
                annotation = [[ASLastPointAnnotation alloc] initWithLocation:coord];
            } else {
                annotation = [[ASPointAnnotation alloc] initWithLocation:coord];
            }
            
            [annotation setAnnotationColor:colorForUser];
            annotation.deviceObject = deviceModel;
            annotation.pointObject = pointModel;
            annotation.owner = friendModel;
            [self.mapView addAnnotation:annotation];
            
            if (self.isFirstLaunch &&
                pointModel == deviceModel.points.lastObject) {
                self.isFirstLaunch = NO;
                MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, 800, 800);
                [self.mapView setRegion:viewRegion animated:YES];

            }
        }
    }
}

-(void)configFilter {
    UIPickerView *filterPicker = [[UIPickerView alloc] init];
    filterPicker.backgroundColor = [UIColor whiteColor];
    filterPicker.delegate = self;
    filterPicker.dataSource = self;
    self.filterTextField.inputView = filterPicker;
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, filterPicker.frame.size.width, 44)];
    accessoryView.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    
    accessoryView.items = [NSArray arrayWithObjects:space,done, nil];
    self.filterTextField.inputAccessoryView = accessoryView;
}

#pragma mark - MapView delegate

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if (self.timer) {
        [self.timer invalidate];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.016 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self.timer invalidate];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self refreshLine];
    
    if (self.isUserLocationCentered == NO) {
        self.isUserLocationCentered = YES;
        MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
        mapRegion.center = self.mapView.userLocation.coordinate;
        [self.mapView setRegion:[self.mapView regionThatFits:mapRegion] animated:YES];
//        [self.locationManager stopUpdatingLocation];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
//        MKAnnotationView *userLocationAnnotationView = (id)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ASFriendAnnotation"];
//        
//        if (!userLocationAnnotationView) {
//            userLocationAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
//                                                                      reuseIdentifier:@"ASFriendAnnotation"];
//            userLocationAnnotationView.canShowCallout = NO;
//        } else {
//            userLocationAnnotationView.annotation = annotation;
//        }
//        
//        userLocationAnnotationView.image = [UIImage getUserAnnotationImageWithColor:[UIColor blackColor]];
//        
//        return userLocationAnnotationView;
    }
    
    if ([annotation isKindOfClass:[ASPointAnnotation class]]) {
        MKAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ASPointAnnotation"];
        
        if (!pinView) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                   reuseIdentifier:@"ASPointAnnotation"];
            pinView.canShowCallout = NO;
        } else {
            pinView.annotation = annotation;
        }
        
        pinView.image = [UIImage getPointAnnotationImageWithColor:((ASPointAnnotation*)annotation).annotationColor];
        return pinView;
    } else if ([annotation isKindOfClass:[ASLastPointAnnotation class]]) {
        MKAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ASLastPointAnnotation"];
        
        if (!pinView) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                   reuseIdentifier:@"ASLastPointAnnotation"];
            
            pinView.canShowCallout = NO;
        } else {
            pinView.annotation = annotation;
        }
        
        pinView.image = [UIImage getLastPointAnnotationImageWithColor:((ASLastPointAnnotation*)annotation).annotationColor];
        
        return pinView;
    } else if ([annotation isKindOfClass:[ASFriendAnnotation class]]) {
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ASFriendAnnotation"];
        
        if (!pinView) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                   reuseIdentifier:@"ASFriendAnnotation"];
            pinView.canShowCallout = NO;
        } else {
            pinView.annotation = annotation;
        }
        
        pinView.image = [UIImage getUserAnnotationImageWithColor:((ASFriendAnnotation*)annotation).annotationColor];
        
        return pinView;
    }
    
    return nil;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[ASDevicePointAnnotation class]]) {
        ASDevicePointAnnotation *annotation = view.annotation;
        [self.detailsPlank configWithOwner:annotation.owner
                                   tracker:annotation.deviceObject
                                     point:annotation.pointObject
                                     color:annotation.annotationColor];
    } else if ([view.annotation isKindOfClass:[ASFriendAnnotation class]]) {
        ASFriendAnnotation *annotation = view.annotation;
        [self.detailsPlank configWithOwner:annotation.userObject
                                   tracker:nil
                                     point:nil
                                     color:annotation.annotationColor];
    }
    
    self.detailsPlank.hidden = NO;
    self.tapGestureDetails.enabled = YES;
}

#pragma mark - UIPicker

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.originalPointsData.count + 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == 0) {
        return NSLocalizedString(@"All", nil);
    }
    
    ASFriendModel *userModel = self.originalPointsData[row-1];
    if ([userModel.userName isEqualToString:self.apiController.userProfile.username]) {
        return NSLocalizedString(@"You", nil);
    }
    
    return userModel.userName;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row == 0) {
        self.userToFilter = nil;
    } else {
        ASFriendModel *userModel = self.originalPointsData[row-1];
        self.userToFilter = userModel;
    }
    
    [self showAllPointsForUsers:self.originalPointsData filterFor:self.userToFilter];
}

#pragma mark - THDatePickerViewController delegate

-(void)datePickerDonePressed:(THDatePickerViewController *)datePicker
{
    [datePicker dismissSemiModalView];
    self.selectedDate = datePicker.date;
    [self loadTracks];
}

-(void)datePickerCancelPressed:(THDatePickerViewController *)datePicker
{
    
}

@end