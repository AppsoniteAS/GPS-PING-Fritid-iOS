//
//  ASMapViewController.h
//  GpsPing
//
//  Created by Pavel Ivanov on 27/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ASTrackerModel.h"
@interface ASMapViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (assign, nonatomic) BOOL isHistoryMode;
+(instancetype)initialize;
@property (strong, nonatomic) ASTrackerModel* selectedTracker;
@end
