//
//  Created by Eugeny Lee on 06.07.16.
//

#import "CompassController.h"
#import <CoreLocation/CoreLocation.h>

#define DegreesToRadians(degrees)(degrees * M_PI / 180.0)

@interface CompassController () <CLLocationManagerDelegate>

@property (strong, nonatomic) UIImageView *arrowImageView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation CompassController

#pragma mark - Instancetype

+ (instancetype)compassWithArrowImageView:(UIImageView*)arrowImageView {
    CompassController *compassController = CompassController.new;
    compassController.arrowImageView = arrowImageView;
    return compassController;
}

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) [self initialize];
    return self;
}

- (void)initialize {
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = CLLocationManager.new;
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    float direction = newHeading.magneticHeading;
    direction = direction > 180 ? 360 - direction: 0 - direction;
    
    if (self.arrowImageView) {
        [UIView animateWithDuration:1.0f animations:^{
            self.arrowImageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(direction));
        }];
    }
}

@end
