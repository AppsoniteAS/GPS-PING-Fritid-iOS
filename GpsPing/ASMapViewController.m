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

@interface ASMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *filterPlank;
@property (weak, nonatomic) IBOutlet UITextField *filterTextField;
@property (weak, nonatomic) IBOutlet ASMapDetailsView *detailsPlank;


@property (nonatomic, strong) AGApiController   *apiController;

@end
@implementation ASMapViewController

objection_requires(@keypath(ASMapViewController.new, apiController))

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];

    self.mapView.mapType = MKMapTypeStandard;
    NSDate *from = [NSDate dateWithTimeIntervalSince1970:1410739200];
    NSDate *to = [NSDate dateWithTimeIntervalSince1970:1410868800];
    [[self.apiController getTrackingPointsFrom:from to:to friendId:nil] subscribeNext:^(id x) {
        [self showAllPointsForUsers:x];
    }];
}

-(void)showAllPointsForUsers:(NSArray*)users
{
    for (ASFriendModel *friendModel in users) {
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
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[ASPointAnnotation class]]) {
        MKAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ASPointAnnotation"];
        
        if (!pinView) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:@"ASPointAnnotation"];
            pinView.canShowCallout = NO;
            pinView.image = [UIImage getPointAnnotationImageWithColor:((ASPointAnnotation*)annotation).annotationColor];
        } else {
            pinView.annotation = annotation;
        }
        
        return pinView;
    } else if ([annotation isKindOfClass:[ASLastPointAnnotation class]]) {
        MKAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ASLastPointAnnotation"];
        
        if (!pinView) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:@"ASLastPointAnnotation"];

            pinView.canShowCallout = NO;
            pinView.image = [UIImage getLastPointAnnotationImageWithColor:((ASLastPointAnnotation*)annotation).annotationColor];
        } else {
            pinView.annotation = annotation;
        }
        
        return pinView;
    } else if ([annotation isKindOfClass:[ASFriendAnnotation class]]) {
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ASFriendAnnotation"];
        
        if (!pinView) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:@"ASFriendAnnotation"];
            pinView.canShowCallout = NO;
            pinView.image = [UIImage getUserAnnotationImageWithColor:((ASFriendAnnotation*)annotation).annotationColor];
        } else {
            pinView.annotation = annotation;
        }
        
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

@end