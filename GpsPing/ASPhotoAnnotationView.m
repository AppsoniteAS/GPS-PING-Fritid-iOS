//
//  ASPhotoAnnotationView.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/18/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASPhotoAnnotationView.h"

#import "ASPinMainView.h"

@implementation ASPhotoAnnotationView


- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor redColor]];
        self.marker = [ASPinMainView getMarkerView];
        CGRect frame = CGRectMake(0, 0, self.marker.bounds.size.width, self.marker.bounds.size.height);
        [self setFrame:frame];
        [self setCenterOffset:CGPointMake(-CGRectGetHeight(frame) / 2, -CGRectGetHeight(frame) / 2)];
        [self addSubview:self.marker];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
