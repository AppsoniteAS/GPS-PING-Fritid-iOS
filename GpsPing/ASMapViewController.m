//
//  ASMapViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 27/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASMapViewController.h"
#import "AGApiController.h"
#import "ASModel.h"
#import "ASPointAnnotation.h"
#import "ASFriendAnnotation.h"
#import "ASLastPointAnnotation.h"
#import "UIImage+ASAnnotations.h"
#import "UIColor+ASColor.h"
#import "ASMapDetailsView.h"
#import "ASDashedLine.h"

@interface ASMapViewController () <MKMapViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *filterPlank;
@property (weak, nonatomic) IBOutlet UITextField *filterTextField;
@property (weak, nonatomic) IBOutlet ASMapDetailsView *detailsPlank;
@property (nonatomic) NSArray *originalPointsData;
@property(nonatomic) CLLocationManager *locationManager;
@property(nonatomic) NSTimer *timer;
@property (nonatomic) CAShapeLayer *shapeLayer;
@property (weak, nonatomic) IBOutlet ASDashedLine *dashedLineView;
@property (nonatomic, strong) AGApiController   *apiController;

@end
@implementation ASMapViewController

objection_requires(@keypath(ASMapViewController.new, apiController))

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    [self configFilter];
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
//    [self.locationManager startUpdatingLocation];

    self.mapView.mapType = MKMapTypeStandard;
    NSDate *from = [NSDate dateWithTimeIntervalSince1970:1410739200];
    NSDate *to = [NSDate dateWithTimeIntervalSince1970:1410868800];
    self.mapView.showsUserLocation = YES;

    self.filterTextField.enabled = NO;
    [[self.apiController getTrackingPointsFrom:from to:to friendId:nil] subscribeNext:^(id x) {
        [self showAllPointsForUsers:x];
        self.originalPointsData = x;
        self.filterTextField.enabled = YES;
    }];
    
    self.shapeLayer = [[CAShapeLayer alloc] init];
    self.shapeLayer.frame = self.mapView.bounds;
    [self.mapView.layer addSublayer:self.shapeLayer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.016 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
}

-(void)timerTick:(NSTimer*)timer
{
//    NSLog(@"%@", NSStringFromCGPoint([self.mapView convertCoordinate:self.mapView.userLocation.coordinate
//                                                       toPointToView:self.view]));
//    NSLog(@"%@", NSStringFromCGPoint([self.mapView convertCoordinate:self.mapView.region.center
//                                                       toPointToView:self.view]));

// NSLog(@"%@", self.mapView.region.center)
    
//    CLLocationCoordinate2D coordinates[2];
//    coordinates[0] = self.mapView.userLocation.coordinate;
//    coordinates[1] = self.mapView.region.center;
//    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:2];
//    [self.mapView removeOverlays:self.mapView.overlays];
//    [self.mapView addOverlay:polyLine];
    
    
//    CGPoint startPoint = [self.mapView convertCoordinate:self.mapView.userLocation.coordinate
//                                           toPointToView:self.mapView];
//    CGFloat newX = startPoint.x;
//    CGFloat newY = startPoint.y;
//    
//    if (startPoint.x > self.dashedLineView.frame.size.width) {
//        newX = self.dashedLineView.frame.size.width;
//        CGFloat k = newX/startPoint.x;
//        newY = startPoint.y*k;
//    } else if (startPoint.y > self.dashedLineView.frame.size.height) {
//        newY = self.dashedLineView.frame.size.height;
//        CGFloat k = newY/startPoint.y;
//        newX = startPoint.x*k;
//    }
//    
//    self.dashedLineView.userLocationPoint = CGPointMake(newX, newY);
//    [self.dashedLineView setNeedsDisplay];
    
    
    [self updateShapeLayer];
}

-(void)updateShapeLayer
{
//    CAShapeLayer *shapelayer = self.shapeLayer;
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    //draw a line
//    CGPoint startPoint = [self.mapView convertCoordinate:self.mapView.userLocation.coordinate
//                                           toPointToView:self.view];
//    CGPoint endPoint = [self.mapView convertCoordinate:self.mapView.region.center
//                                         toPointToView:self.view];
//    //    NSLog(@"%@", NSStringFromCGPoint([self.mapView convertCoordinate:self.mapView.region.center
//    //
//    [path moveToPoint:startPoint]; //add yourStartPoint here
//    [path addLineToPoint:endPoint];// add yourEndPoint here
//    [path stroke];
//    
//    float dashPattern[] = {2,6,4,2}; //make your pattern here
//    [path setLineDash:dashPattern count:4 phase:3];
//    
//    UIColor *fill = [UIColor blueColor];
//    shapelayer.strokeStart = 0.0;
//    shapelayer.strokeColor = fill.CGColor;
//    shapelayer.lineWidth = 5.0;
//    shapelayer.lineJoin = kCALineJoinMiter;
//    shapelayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:10],[NSNumber numberWithInt:7], nil];
//    shapelayer.lineDashPhase = 3.0f;
//    shapelayer.path = path.CGPath;
    
    
    if (self.shapeLayer) {
        [self.shapeLayer removeFromSuperlayer];
    }
    
    CAShapeLayer *shapeLayer;

    if (!self.shapeLayer) {
//        [self.shapeLayer removeFromSuperlayer];
        shapeLayer = [CAShapeLayer layer];
    } else {
        shapeLayer = self.shapeLayer;
    }
    
    CGPoint startPoint = [self.mapView convertCoordinate:self.mapView.userLocation.coordinate
                                           toPointToView:self.view];
    CGPoint endPoint = [self.mapView convertCoordinate:self.mapView.region.center
                                         toPointToView:self.view];
    
    //    CGPoint startPoint = [self.mapView convertCoordinate:self.mapView.userLocation.coordinate
    //                                           toPointToView:self.mapView];
    CGFloat newX = startPoint.x;
    CGFloat newY = startPoint.y;

    if (startPoint.x > self.view.frame.size.width) {
        newX = self.view.frame.size.width;
        CGFloat k = newX/startPoint.x;
        newY = startPoint.y*k;
    } else if (startPoint.y > self.view.frame.size.height) {
        newY = self.view.frame.size.height;
        CGFloat k = newY/startPoint.y;
        newX = startPoint.x*k;
    }
    CGPoint newStartPoint = CGPointMake(newX, newY);
    
    [shapeLayer setBounds:self.view.bounds];
    [shapeLayer setPosition:self.view.center];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor blackColor] CGColor]];
    [shapeLayer setLineWidth:3.0f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
      [NSNumber numberWithInt:5],nil]];
    
    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, newStartPoint.x, newStartPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
//    if (!self.shapeLayer) {
        self.shapeLayer = shapeLayer;
        [self.view.layer addSublayer:self.shapeLayer];
//    }
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

-(void)doneTapped:(id)sender
{
    [self.filterTextField resignFirstResponder];
}

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

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
//    if (self.timer) [self.timer invalidate];
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.016 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    [self.timer invalidate];

//    CLLocationCoordinate2D coordinates[2];
//    coordinates[0] = self.mapView.userLocation.coordinate;
//    coordinates[1] = mapView.region.center;
//    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:2];
//    [mapView removeOverlays:self.mapView.overlays];
//    [mapView addOverlay:polyLine];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if (![overlay isKindOfClass:[MKPolyline class]]) {
        return nil;
    }
    MKPolyline *polyline = (MKPolyline *)overlay;
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:polyline];
//    renderer.fillColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.4];
    renderer.strokeColor         = [UIColor redColor];
    renderer.lineWidth           = 2;
    renderer.lineDashPattern = @[@20, @5];
    return renderer;
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


@end