//
//  ASPinMainView.h
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/18/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface ASPinMainView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageViewPhoto;
- (void) handleByImage: (UIImage*) image;
- (void) handleByImageName: (NSString*) name;
+ (ASPinMainView*) getMarkerView;
@end
