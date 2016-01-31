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

@interface ASMapViewController () <MKMapViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource, THDatePickerDelegate>

@property (weak, nonatomic) IBOutlet UIView           *filterPlank;
@property (weak, nonatomic) IBOutlet UITextField      *filterTextField;
@property (weak, nonatomic) IBOutlet ASMapDetailsView *detailsPlank;
@property (weak, nonatomic) IBOutlet ASDashedLine     *dashedLineView;

@property (nonatomic        ) NSArray                    *originalPointsData;
@property (nonatomic        ) CLLocationManager          *locationManager;
@property (nonatomic        ) NSTimer                    *timer;
@property (nonatomic        ) CAShapeLayer               *shapeLayer;
@property (nonatomic        ) NSDate                     *selectedDate;

@property (nonatomic        ) AGApiController            *apiController;
@property (nonatomic        ) THDatePickerViewController *datePicker;

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
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    //    [self.locationManager startUpdatingLocation];
    
    self.mapView.mapType = MKMapTypeStandard;

    self.mapView.showsUserLocation = YES;
    
    self.filterTextField.enabled = NO;
    
    NSDate *from = [NSDate dateWithTimeIntervalSince1970:1410739200];
    NSDate *to = [NSDate dateWithTimeIntervalSince1970:1410868800];
    [[self.apiController getTrackingPointsFrom:from to:to friendId:nil] subscribeNext:^(id x) {
        [self showAllPointsForUsers:x];
        self.originalPointsData = x;
        self.filterTextField.enabled = YES;
    }];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.016 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
}

#pragma mark - IBActions and Handlers

- (IBAction)photoActionTap:(id)sender {
}

- (IBAction)mapTypeValueChanged:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.mapView.mapType = MKMapTypeSatellite;
    } else if (sender.selectedSegmentIndex == 1) {
        self.mapView.mapType = MKMapTypeStandard;
    } else {
        self.mapView.mapType = MKMapTypeHybrid;
    }
}

-(void)doneTapped:(id)sender
{
    [self.filterTextField resignFirstResponder];
}

-(void)removeTracksTap
{
    
}

-(void)timerTick:(NSTimer*)timer
{
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

#pragma mark - Private methods

-(void)showAllPointsForUsers:(NSArray*)users
{
    for (ASFriendModel *friendModel in users) {
        [self showPointsForUser:friendModel];
    }
}

-(void)showPointsForUser:(ASFriendModel*)friendModel
{
    UIColor *colorForUser = [UIColor getRandomColor];
    CLLocationCoordinate2D friendCoord = CLLocationCoordinate2DMake(friendModel.latitude.doubleValue, friendModel.longitude.doubleValue);
    ASFriendAnnotation *friendAnnotation = [[ASFriendAnnotation alloc] initWithLocation:friendCoord];
    friendAnnotation.annotationColor = colorForUser;
    friendAnnotation.userObject = friendModel;
    [self.mapView addAnnotation:friendAnnotation];
    
    for (ASDeviceModel *deviceModel in friendModel.devices) {
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
            if (pointModel == deviceModel.points.lastObject) {
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
    //    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    //    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
        MKAnnotationView *userLocationAnnotationView = (id)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ASFriendAnnotation"];
        
        if (!userLocationAnnotationView) {
            userLocationAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                      reuseIdentifier:@"ASFriendAnnotation"];
            userLocationAnnotationView.canShowCallout = NO;
        } else {
            userLocationAnnotationView.annotation = annotation;
        }
        
        userLocationAnnotationView.image = [UIImage getUserAnnotationImageWithColor:[UIColor blackColor]];
        
        return userLocationAnnotationView;
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
        [self showAllPointsForUsers:self.originalPointsData];
        return;
    }
    
    ASFriendModel *userModel = self.originalPointsData[row-1];
    if ([userModel.userName isEqualToString:self.apiController.userProfile.username]) {
        self.filterTextField.text = NSLocalizedString(@"You", nil);
    } else {
        self.filterTextField.text = userModel.userName;
    }
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self showAllPointsForUsers:@[userModel]];
}

#pragma mark - THDatePickerViewController delegate

-(void)datePickerDonePressed:(THDatePickerViewController *)datePicker
{
    [datePicker dismissSemiModalView];
    self.selectedDate = datePicker.date;
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSDate *from = datePicker.date;
    NSDate *to = [datePicker.date dateByAddingTimeInterval:60*60*24];
    [[self.apiController getTrackingPointsFrom:from to:to friendId:nil] subscribeNext:^(id x) {
        [self showAllPointsForUsers:x];
        self.originalPointsData = x;
        self.filterTextField.enabled = YES;
    }];
}

-(void)datePickerCancelPressed:(THDatePickerViewController *)datePicker
{
    
}

@end