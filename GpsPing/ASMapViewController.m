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
#import "ASPointOfInterestAnnotation.h"
#import "ASPointAnnotation.h"
#import "ASFriendAnnotation.h"
#import "ASLastPointAnnotation.h"
#import "UIImage+ASAnnotations.h"
#import "UIColor+ASColor.h"
#import "ASMapDetailsView.h"
#import "ASDashedLine.h"
#import <THDatePickerViewController.h>
#import "ASDisplayOptionsViewController.h"
#import <CocoaLumberjack.h>
#import <Underscore.h>
#import "NSDate+DateTools.h"
#import "CompassController.h"
#import "WMSTileOverlay.h"
#import "ASLocationTrackingService.h"
#import "ASTrackerDetailsView.h"
#import "ASPOIDetailsView.h"
#import "ASPinMainView.h"
#import "ASDeviceModel.h"
#import "ASPhotoAnnotationView.h"
#import "ASTrackerConfigurationViewController.h"
#import "ASSmsManager.h"
#import "ASCashedTileOverlay.h"


#define QUERY_RATE_IN_SECONDS 30
static const DDLogLevel ddLogLevel = DDLogLevelDebug;

static NSString *const kASUserDefaultsKeyRemoveTrackersDate = @"kASUserDefaultsKeyRemoveTrackersDate";

@interface ASMapViewController () <MKMapViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource, THDatePickerDelegate, UITabBarControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startLocateUserButton;

@property (weak, nonatomic) IBOutlet UIView           *filterPlank;
@property (weak, nonatomic) IBOutlet UITextField      *filterTextField;
@property (weak, nonatomic) IBOutlet ASTrackerDetailsView *trackerView;
//@property (weak, nonatomic) IBOutlet ASMapDetailsView *detailsPlank;
@property (weak, nonatomic) IBOutlet UIView *bottomPlank;
@property (weak, nonatomic) IBOutlet ASPOIDetailsView *poiView;
@property (weak, nonatomic) IBOutlet ASDashedLine     *dashedLineView;
@property (strong, nonatomic)  UITapGestureRecognizer *tapGestureDetails;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceMetricLabel;
@property (weak, nonatomic) IBOutlet UIImageView *compassImageView;
@property (strong, nonatomic) ASTrackerModel* popedTracker;

@property (nonatomic        ) NSArray                    *originalPointsData;
@property (nonatomic        ) NSArray                    *colorSetForUsers;
@property (nonatomic        ) NSArray                    *arrayPOIs;
@property (nonatomic        ) CLLocationManager          *locationManager;
@property (nonatomic        ) NSTimer                    *timer;
@property (nonatomic        ) NSTimer                    *timerForTrackQuery;
@property (nonatomic        ) CAShapeLayer               *shapeLayer;
@property (nonatomic        ) NSDate                     *selectedDate;

@property (nonatomic        ) AGApiController            *apiController;
@property (nonatomic, strong) ASLocationTrackingService  *locationTrackingService;

@property (nonatomic        ) THDatePickerViewController *datePicker;

@property (nonatomic        ) ASFriendModel              *userToFilter;

@property (nonatomic        ) NSDictionary *colorsDictionary;
@property (nonatomic        ) NSDictionary *colorsNameDictionary;

@property (nonatomic, assign) BOOL isFirstLaunch;
@property (nonatomic, assign) BOOL isUserLocationCentered;
@property (nonatomic        ) ASPointOfInterestAnnotation *selectedAnnotation;
@property (nonatomic, assign) BOOL modifyingMap;
@property (strong, nonatomic) CompassController *compassController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (strong, nonatomic) NSArray<ASTrackerModel*>* trackers;
@end

@implementation ASMapViewController

objection_requires(@keypath(ASMapViewController.new, apiController), @keypath(ASMapViewController.new, locationTrackingService))

+(instancetype)initialize
{
    return [[UIStoryboard mapStoryboard] instantiateViewControllerWithIdentifier:@"ASMapViewController"];
}



#pragma mark - view controller methods

- (void) handleGestureRecognizers{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]      initWithTarget:self action:@selector(handleLongPress:)];
    self.tapGestureDetails = [[UITapGestureRecognizer alloc]      initWithTarget:self action:@selector(tapHandle:)];
    longPress.minimumPressDuration = 0.5;
    longPress.numberOfTapsRequired = 0;
    self.mapView.userInteractionEnabled = YES;
    [self.mapView addGestureRecognizer:longPress];
    self.tapGestureDetails.numberOfTapsRequired = 1;
    self.tapGestureDetails.numberOfTouchesRequired = 1;
    [self.mapView addGestureRecognizer:self.tapGestureDetails];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    self.modifyingMap = NO;

    [self handleGestureRecognizers];
    [self configFilter];
    
    UIBarButtonItem *rightBBI;

    if (self.isHistoryMode) {
        rightBBI = [[UIBarButtonItem alloc] initWithTitle:@""
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(calendarTap:)];
        rightBBI.image = [UIImage imageNamed:@"calendarIcon"];
    } else {
        rightBBI = nil;
    }
    
    self.navigationItem.rightBarButtonItem = rightBBI;
    self.mapView.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
   // [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    
    [self changeMapType:2];

    self.mapView.showsUserLocation = YES;
    self.filterTextField.enabled = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.016
                                                  target:self
                                                selector:@selector(timerTick:)
                                                userInfo:nil
                                                 repeats:YES];
   
    self.compassController = [CompassController compassWithArrowImageView:self.compassImageView];
    [RACObserve(self, locationTrackingService.isServiceRunning) subscribeNext:^(NSNumber *isRunning) {
        if (isRunning.boolValue) {
            [self.startLocateUserButton setImage:[[UIImage imageNamed:@"friend_list_icon_visible"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                        forState:UIControlStateNormal];
        } else {
            [self.startLocateUserButton setImage:[[UIImage imageNamed:@"friend_list_icon_invisible"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                        forState:UIControlStateNormal];
        }
    }];
    UITabBarController* t =  ((UITabBarController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController] );
    t.delegate = self;
    [self refresh];
    
    self.trackers = [ASTrackerModel getTrackersFromUserDefaults];
    [self handleExistedTracker];
}

- (ASTrackerModel*) getTrackerByImei: (NSString*) imei{
    for (ASTrackerModel* tracker in self.trackers) {
        if ([tracker.imeiNumber isEqual:imei]){
            return tracker;
        }
    }
    return nil;
}

- (void) refresh{
    DDLogInfo(@"will be refreshed");
        self.isFirstLaunch = YES;
    self.colorsDictionary = nil;
    if (!self.isHistoryMode) {
        self.timerForTrackQuery = [NSTimer scheduledTimerWithTimeInterval:QUERY_RATE_IN_SECONDS
                                                                   target:self
                                                                 selector:@selector(timerForQueryTick:)
                                                                 userInfo:nil
                                                                  repeats:YES];
        [self.timerForTrackQuery fire];
    } else {
        [self loadTracks];
    }
    if (!(self.isHistoryMode && self.selectedTracker)){
        [self loadPointsOfInterest];
    }
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshLine];

}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self.locationManager requestWhenInUseAuthorization];
//    [self.locationManager requestAlwaysAuthorization];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.timer invalidate];
    [self.timerForTrackQuery invalidate];
}



#pragma mark - Getters & setters

-(NSArray *)colorSetForUsers {
    return @[[UIColor redColor],
           //  [UIColor blueColor],
             [UIColor orangeColor],
             [UIColor yellowColor],
             [UIColor greenColor]];
}

-(NSArray *)colorNameSetForUsers {
    return @[@"red",

             @"orange",
             @"yellow",
             @"green"];
}

#pragma mark - IBActions and Handlers

- (IBAction)startServiceTap:(id)sender {
    if (!self.locationTrackingService.isServiceRunning) {
        [self.locationTrackingService startLocationTracking];
    } else {
        [self.locationTrackingService stopLocationTracking];
    }
}

- (IBAction)calendarTap:(id)sender {
    if(!self.datePicker)
        self.datePicker = [THDatePickerViewController datePicker];
    self.datePicker.date = [NSDate date];
    self.datePicker.delegate = self;
    
    [self.datePicker setAllowClearDate:NO];
    [self.datePicker setClearAsToday:YES];
    [self.datePicker setAutoCloseOnSelectDate:YES]; // меняет галочку на -
    [self.datePicker setAllowSelectionOfSelectedDate:YES];
    [self.datePicker setDisableHistorySelection:NO];
    [self.datePicker setDisableFutureSelection:YES];
    [self.datePicker setSelectedBackgroundColor:[UIColor colorWithRed:125/255.0 green:208/255.0 blue:0/255.0 alpha:1.0]];
    [self.datePicker setCurrentDateColor:[UIColor colorWithRed:242/255.0 green:121/255.0 blue:53/255.0 alpha:1.0]];
//
    [self.datePicker setDateHasItemsCallback:^BOOL(NSDate *date) {
        int tmp = (arc4random() % 30)+1;
        if(tmp % 5 == 0)
            return YES;
        return NO;
    }];

    if (self.selectedDate) self.datePicker.date = self.selectedDate;
    [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(0.33),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                                  }];
    
}

- (void)tapHandle:(UITapGestureRecognizer *)sender {
    DDLogInfo(@"tapHandle");

    //self.tapGestureDetails.enabled = NO;
    CGPoint p = [sender locationInView:self.mapView];
    
    UIView *v = [self.mapView hitTest:p withEvent:nil];
    
    id<MKAnnotation> ann = nil;
    DDLogInfo(@"tapHandle %@", [v class]);

    if ([v isKindOfClass:[MKAnnotationView class]])
    {
        DDLogInfo(@"tapHandle MKAnnotationView");

        self.bottomPlank.hidden = NO;

        //annotation view was tapped, select it...
        ann = ((MKAnnotationView *)v).annotation;
        [self.mapView selectAnnotation:ann animated:YES];
    }
    else
    {
        DDLogInfo(@"tapHandle NON MKAnnotationView");

        self.bottomPlank.hidden = YES;
    }
}

- (IBAction)editPOI:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Point of interest", nil)
                                          message:NSLocalizedString(@"Edit name", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    ASPointOfInterestModel *pointOfInterestModel = self.selectedAnnotation.poiObject;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.text = pointOfInterestModel.name;
     }];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   pointOfInterestModel.name = alertController.textFields.firstObject.text;
                                   [self.poiView configWithPOI:pointOfInterestModel withOwner:nil color:self.selectedAnnotation.annotationColor];
                                   [[[self.apiController updatePOI:pointOfInterestModel.name id:pointOfInterestModel.identificator.integerValue latitude:pointOfInterestModel.latitude.floatValue longitude:pointOfInterestModel.longitude.floatValue] deliverOnMainThread] subscribeNext:^(id x) {
                                       [self loadPointsOfInterest];
                                   }] ;
                               }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       DDLogDebug(@"Cancel action");
                                   }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)removePOI:(id)sender {
    [self.mapView removeAnnotation:self.selectedAnnotation];
    self.bottomPlank.hidden = YES;
   // self.tapGestureDetails.enabled = NO;
    ASPointOfInterestModel *pointOfInterestModel = self.selectedAnnotation.poiObject;
    [[[self.apiController removePOIWithId:pointOfInterestModel.identificator.integerValue] deliverOnMainThread] subscribeNext:^(id x) {
        [self loadPointsOfInterest];
    }] ;
}

- (IBAction)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D coordTouchMap = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Point of interest", nil)
                                          message:NSLocalizedString(@"Enter name", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@" ", @"Enter name");
     }];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [[[self.apiController addPOI:alertController.textFields.firstObject.text  latitude:coordTouchMap.latitude longitude:coordTouchMap.longitude] deliverOnMainThread] subscribeNext:^(id x) {
                                       [self loadPointsOfInterest];
                                   }] ;
                               }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       DDLogDebug(@"Cancel action");
                                   }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

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
        ASCashedTileOverlay *overlayWorld = [[ASCashedTileOverlay alloc] initWithURLTemplate:templateWorld];
        overlayWorld.canReplaceMapContent = YES;
        [self.mapView addOverlay:overlayWorld
                           level:MKOverlayLevelAboveLabels];
        
        static NSString * const templateSweden = @"http://fritid.gpsping.no:6057/service?LAYERS=sweden&FORMAT=image/png&SRS=EPSG:3857&EXCEPTIONS=application.vnd.ogc.se_inimage&TRANSPARENT=TRUE&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&STYLES=&WIDTH=256&HEIGHT=256";
        WMSTileOverlay *overlaySweden = [[WMSTileOverlay alloc] initWithUrl:templateSweden UseMercator:YES];
        overlaySweden.canReplaceMapContent = YES;
        [self.mapView addOverlay:overlaySweden
                           level:MKOverlayLevelAboveLabels];
        
//        static NSString * const templateFinland = @"http://industri.gpsping.no:6057/service?LAYERS=finnish&FORMAT=image/png&SRS=EPSG:3857&EXCEPTIONS=application.vnd.ogc.se_inimage&TRANSPARENT=TRUE&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&STYLES=&WIDTH=256&HEIGHT=256";
//        WMSTileOverlay *overlayFinland = [[WMSTileOverlay alloc] initWithUrl:templateFinland UseMercator:YES];
//        overlayFinland.canReplaceMapContent = YES;
//        [self.mapView addOverlay:overlayFinland
//                           level:MKOverlayLevelAboveLabels];

        static NSString * const templateNorway = @"http://opencache.statkart.no/gatekeeper/gk/gk.open_gmaps?layers=topo2&zoom={z}&x={x}&y={y}&format=image/png";
        ASCashedTileOverlay *overlayNorway = [[ASCashedTileOverlay alloc] initWithURLTemplate:templateNorway];
        overlayNorway.canReplaceMapContent = YES;
        [self.mapView addOverlay:overlayNorway
                           level:MKOverlayLevelAboveLabels];
        
        static NSString * const templateDenmark = @"http://kortforsyningen.kms.dk/topo100?LAYERS=dtk_1cm&FORMAT=image/png&BGCOLOR=0xFFFFFF&TICKET=8b4e36fe4c851004fd1e69463fbabe3b&PROJECTION=EPSG:3857&TRANSPARENT=TRUE&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&STYLES=&SRS=EPSG:3857&WIDTH=256&HEIGHT=256";
        WMSTileOverlay *overlayDenmark = [[WMSTileOverlay alloc] initWithUrl:templateDenmark UseMercator:YES];
        overlayDenmark.canReplaceMapContent = YES;
        [self.mapView addOverlay:overlayDenmark
                           level:MKOverlayLevelAboveLabels];
        
    }
}

#pragma mark - Refresh map by network

-(void)doneTapped:(id)sender
{
    [self.filterTextField resignFirstResponder];
}

-(void)removeTracksTap
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:kASUserDefaultsKeyRemoveTrackersDate];
    [defaults synchronize];
    [self loadTracks];
}

-(void)timerTick:(NSTimer*)timer
{
    [self refreshLine];
    [self refreshLabel];
}



-(void)timerForQueryTick:(NSTimer*)timer {
    [self loadTracks];
}

-(void)loadTracks {
    NSDate *from;
    NSDate *to;
    
//    from = [[NSDate date] dateBySubtractingYears:10];
//    to =[NSDate date];
//    [self loadTrackingPointsFrom:from to:to];
//    return;
//    
    if (!self.selectedDate) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
        NSNumber *duration = [defaults objectForKey:kTrackingDurationKey];
        to = [NSDate date];
        from = [to dateByAddingTimeInterval:-60*duration.integerValue];
        
        NSDate *removeTracksDate  = [defaults objectForKey:kASUserDefaultsKeyRemoveTrackersDate];
        if (removeTracksDate) {
            from =  [removeTracksDate isEarlierThanOrEqualTo:from] ? from : removeTracksDate;
        }
    } else {
//        from = [self.selectedDate dateBySubtractingMinutes:60*12];
//        to = [self.selectedDate dateByAddingMinutes:60*12*2];
        from = self.selectedDate;
        to = [self.selectedDate dateByAddingTimeInterval:60*60*24];
    }
    DDLogInfo(@"will search");
    DDLogInfo(@"%@ - %@",from, to);
    [self loadTrackingPointsFrom:from to:to];
}

-(void)loadPointsOfInterest {
    @weakify(self)
    [[self.apiController getPOI] subscribeNext:^(NSArray* pois) {
        DDLogVerbose(@"POIs: %@",pois);
        @strongify(self)
        self.arrayPOIs = pois;
    }] ;
}


-(void)loadTrackingPointsFrom:(NSDate*)from to:(NSDate*)to {
    if (!self.apiController.userProfile.cookie){
        return;
    }
    if (self.isHistoryMode && self.selectedTracker){
        [[self.apiController getTrackingPointsFrom:from to:to friendId:nil for:self.selectedTracker] subscribeNext:^(id x) {
            self.originalPointsData = x;
            [self showAllPointsForUsers:x filterFor:self.userToFilter];
            self.filterTextField.enabled = YES;
        }] ;
        return;
    }
    

    [[self.apiController getTrackingPointsFrom:from to:to friendId:nil] subscribeNext:^(id x) {
        self.originalPointsData = x;
        [self showAllPointsForUsers:x filterFor:self.userToFilter];
        self.filterTextField.enabled = YES;
    }] ;
}

-(void)fillColorsDictionaryWithUsers:(NSArray *)users {
    NSMutableDictionary *result = @{}.mutableCopy;
    NSMutableDictionary *resultName = @{}.mutableCopy;
    for (ASFriendModel *user in users) {
        NSInteger indexOfColorInSet = [users indexOfObject:user] % self.colorSetForUsers.count;
        result[user.userName] = self.colorSetForUsers[indexOfColorInSet];
        resultName[user.userName] = self.colorNameSetForUsers[indexOfColorInSet];
    }
    
    self.colorsDictionary = result;
    self.colorsNameDictionary = resultName;
}

-(void)showAllPointsForUsers:(NSArray*)users filterFor:(ASFriendModel*)user
{
    if (!self.colorsDictionary || !self.colorsNameDictionary) {
        [self fillColorsDictionaryWithUsers:users];
    }
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    if (!user) {
        for (ASFriendModel *friendModel in users) {
            [self showPointsForUser:friendModel];
        }
        for (ASPointOfInterestModel* poi in self.arrayPOIs) {
            UIColor *colorForUser = self.colorsDictionary[poi.name];
            [self showPointOfInterest:poi withColor:colorForUser];
        }
    } else {
        for (ASFriendModel *friendModel in users) {
            if ([friendModel.userName isEqualToString:user.userName]) {
                 UIColor *colorForUser = self.colorsDictionary[friendModel.userName];
                [self showPointsForUser:friendModel];
                ASPointOfInterestModel* poi = Underscore.find (self.arrayPOIs, ^BOOL (ASPointOfInterestModel *poi) {
                    return (poi.userId == friendModel.userId);
                });
                [self showPointOfInterest:poi withColor:colorForUser];
            }
        }
    }
}

-(void)showPointsForUser:(ASFriendModel*)friendModel
{
    UIColor *colorForUser = self.colorsDictionary[friendModel.userName];
    NSString * colorNameForUser = self.colorsNameDictionary[friendModel.userName];
    if (friendModel.latitude.doubleValue && friendModel.longitude.doubleValue) {
        CLLocationCoordinate2D friendCoord = CLLocationCoordinate2DMake(friendModel.latitude.doubleValue, friendModel.longitude.doubleValue);
        ASFriendAnnotation *friendAnnotation = [[ASFriendAnnotation alloc] initWithLocation:friendCoord];
        friendAnnotation.annotationColor = colorForUser;
        friendAnnotation.userObject = friendModel;
        [self.mapView addAnnotation:friendAnnotation];
    }
    
    
    for (ASDeviceModel *deviceModel in friendModel.devices) {
        CLLocationCoordinate2D deviceCoord = CLLocationCoordinate2DMake(deviceModel.latitude.doubleValue, deviceModel.longitude.doubleValue);
        ASLastPointAnnotation *deviceAnnotation = [[ASLastPointAnnotation alloc] initWithLocation:deviceCoord];
        deviceAnnotation.annotationColor = colorForUser;
        deviceAnnotation.colorName = colorNameForUser;
        deviceAnnotation.pointObject = [deviceModel.points lastObject];
        deviceAnnotation.deviceObject = deviceModel;
        deviceAnnotation.owner = friendModel;
        [self.mapView addAnnotation:deviceAnnotation];
        if (deviceModel.points && deviceModel.points.count){
            for (int i = 0; i < deviceModel.points.count - 1; i++) {
                ASPointModel *pointModel = deviceModel.points[i];
                ASDevicePointAnnotation *annotation;
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(pointModel.latitude.doubleValue, pointModel.longitude.doubleValue);
                annotation = [[ASPointAnnotation alloc] initWithLocation:coord];
                
                [annotation setAnnotationColor:colorForUser];
                annotation.colorName = colorNameForUser;
                
                annotation.deviceObject = deviceModel;
                annotation.pointObject = pointModel;
                annotation.owner = friendModel;
                [self.mapView addAnnotation:annotation];
                
                if (self.isFirstLaunch &&
                    pointModel == deviceModel.points.lastObject) {
                    self.isFirstLaunch = NO;
                    if (deviceModel.latitude.integerValue == 0 && deviceModel.longitude.integerValue == 0){
                        return;
                    }
                    self.isUserLocationCentered = YES;
                    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, 800, 800);
                    [self.mapView setRegion:viewRegion animated:YES];
                    
                }
            }
        }
    }
    if(self.isFirstLaunch){
        
        for (ASDeviceModel *deviceModel in friendModel.devices) {
            if(deviceModel) {
                self.isFirstLaunch = NO;
                if (deviceModel.latitude.integerValue == 0 && deviceModel.longitude.integerValue == 0){
                    continue;
                }
                self.isUserLocationCentered = YES;
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(deviceModel.latitude.doubleValue, deviceModel.longitude.doubleValue);
                MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, 800, 800);
                [self.mapView setRegion:viewRegion animated:YES];
            }
        }
//        ASDeviceModel *deviceModel = friendModel.devices.firstObject;
//        if(deviceModel) {
//            self.isFirstLaunch = NO;
//            if (deviceModel.latitude.integerValue == 0 && deviceModel.longitude.integerValue == 0){
//                return;
//            }
//             self.isUserLocationCentered = YES;
//            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(deviceModel.latitude.doubleValue, deviceModel.longitude.doubleValue);
//            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, 800, 800);
//            [self.mapView setRegion:viewRegion animated:YES];
//        }
    }
}

-(void)showPointOfInterest:(ASPointOfInterestModel*)poi withColor:(UIColor*)color
{
    CLLocationCoordinate2D poiCoord = CLLocationCoordinate2DMake(poi.latitude.doubleValue, poi.longitude.doubleValue);
    ASPointOfInterestAnnotation *poiAnnotation = [[ASPointOfInterestAnnotation alloc] initWithLocation:poiCoord];
    poiAnnotation.poiObject = poi;
    poiAnnotation.annotationColor = color;
    [self.mapView addAnnotation:poiAnnotation];
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


- (void) showTrackerView:(bool) show{
    [self.trackerView setHidden:!show];
    [self.poiView setHidden:show];
    
    self.bottomViewHeight.constant = show ? 340.0 : 109.0;
    [self.view layoutIfNeeded];
}



#pragma mark - MapView delegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    }
    
    return nil;
}


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
    if (mapView.camera.altitude < [self getMinAltitude] && !self.modifyingMap) {
        self.modifyingMap = YES;
        mapView.camera.altitude = [self getMinAltitude];
        self.modifyingMap = NO;
    }
}

-(CLLocationDistance)getMinAltitude {
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"sv"]){
        return 2400;
    }
    
    return 0;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self refreshLine];
    DDLogDebug(@"user location %f %f",userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    if (self.isUserLocationCentered == NO) {
        self.isUserLocationCentered = YES;
        MKMapCamera* camera = [MKMapCamera
                               cameraLookingAtCenterCoordinate:self.mapView.userLocation.coordinate
                               fromEyeCoordinate:self.mapView.userLocation.coordinate
                               eyeAltitude:1400];
        [mapView setCamera:camera animated:NO];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[ASPointAnnotation class]]) {
        MKAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ASPointAnnotation"];
        ASPointAnnotation* a = (ASPointAnnotation*) annotation;

        if (!pinView) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                   reuseIdentifier:@"ASPointAnnotation"];
            pinView.canShowCallout = NO;
        } else {
            pinView.annotation = annotation;
        }
        CGFloat rotation = a.pointObject ? [a.pointObject.heading floatValue] : 0.0f;
        pinView.image =  [UIImage getPointAnnotationImageWithColorName:a.colorName andRotation:rotation];//[UIImage getPointAnnotationImageWithColor:((ASPointAnnotation*)annotation).annotationColor];
        return pinView;
    } else if ([annotation isKindOfClass:[ASLastPointAnnotation class]]) {
        ASLastPointAnnotation* a = (ASLastPointAnnotation*) annotation;
        CGFloat rotation = a.pointObject ? [a.pointObject.heading floatValue] : 0.0f;

        NSString* imageTracker = a.deviceObject.imageId;
        if (imageTracker){
            DDLogDebug(@"imageTracker %@ ", a.deviceObject.imei);
            ASPhotoAnnotationView *pinView = (ASPhotoAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ASLastPointAnnotation"];
            
            if (!pinView) {
                pinView = [[ASPhotoAnnotationView alloc] initWithAnnotation:annotation
                                                            reuseIdentifier:@"ASLastPointAnnotation"];
                pinView.canShowCallout = NO;
            } else {
                pinView.annotation = a;
            }
            [pinView.marker handleByImageName:imageTracker arrowColor:a.annotationColor rotation:rotation];
            
            return pinView;
        }
        DDLogDebug(@"imageTracker %@ ", a.deviceObject.imei);

        MKAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ASLastPointAnnotation2"];

        if (!pinView) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                   reuseIdentifier:@"ASLastPointAnnotation2"];

            pinView.canShowCallout = NO;
        } else {
            pinView.annotation = annotation;
        }

        pinView.image = [UIImage getLastPointAnnotationImageWithColorName:a.colorName andRotation:rotation];// [UIImage getLastPointAnnotationImageWithColor:((ASLastPointAnnotation*)annotation).annotationColor];
//        pinView.layer.borderColor  = [UIColor redColor].CGColor;
//        pinView.layer.borderWidth = 1;
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
    } else if ([annotation isKindOfClass:[ASPointOfInterestAnnotation class]]) {
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ASPointOfInterestAnnotation"];
        
        if (!pinView) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                   reuseIdentifier:@"ASPointOfInterestAnnotation"];
            pinView.canShowCallout = NO;
        } else {
            pinView.annotation = annotation;
        }
        ASPointOfInterestAnnotation *poiAnnotation = annotation;
        pinView.pinTintColor = poiAnnotation.annotationColor;
        
        return pinView;
    }
    
    return nil;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    DDLogInfo(@"didSelectAnnotationView");
    if ([view.annotation isKindOfClass:[MKUserLocation class]]){
        return;
    }
    
    if ([view.annotation isKindOfClass:[ASDevicePointAnnotation class]]) {
        DDLogInfo(@"didSelectAnnotationView ASDevicePointAnnotation");

        ASDevicePointAnnotation *annotation = view.annotation;
        self.popedTracker = annotation.deviceObject.imei ? [self getTrackerByImei: annotation.deviceObject.imei] : nil;
        if (self.popedTracker && self.popedTracker.trackerType && [self.popedTracker.trackerType isEqualToString:kASTrackerTypeTkS1]){
            self.trackerView.callImageView.hidden = false;
        } else{
            self.trackerView.callImageView.hidden = true;
        }
        
        [self showTrackerView:true];
        self.trackerView.btnEdit.enabled = (annotation.deviceObject.imei != nil);
        [self.trackerView configWithOwner:annotation.owner
                                   tracker:annotation.deviceObject
                                     point:annotation.pointObject
                                     color:annotation.annotationColor];
    } else if ([view.annotation isKindOfClass:[ASFriendAnnotation class]]) {
        ASFriendAnnotation *annotation = view.annotation;
        [self showTrackerView:false];

//        [self.trackerView configWithOwner:annotation.userObject
//                                   tracker:nil
//                                     point:nil
//                                     color:annotation.annotationColor];
        [self.poiView configWithPOI:nil withOwner:annotation.userObject color:annotation.annotationColor];
        self.poiView.viewPOIRightColumn.hidden = YES;


    } else if ([view.annotation isKindOfClass:[ASPointOfInterestAnnotation class]]) {
        self.selectedAnnotation = view.annotation;
        [self showTrackerView:false];

        ASPointOfInterestAnnotation *annotation = view.annotation;
        ASFriendModel* owner = Underscore.find (self.originalPointsData, ^BOOL (ASFriendModel *friend) {
            return (friend.userId == annotation.poiObject.userId);
        });
        if (owner.userId == [self.originalPointsData.firstObject userId]) {
            self.poiView.viewPOIRightColumn.hidden = NO;
        } else {
            self.poiView.viewPOIRightColumn.hidden = YES;
        }
        [self.poiView configWithPOI:annotation.poiObject withOwner:owner color:annotation.annotationColor];
    }
    
    self.bottomPlank.hidden = NO;
    //self.tapGestureDetails.enabled = YES;
    
    [self.mapView deselectAnnotation:view.annotation animated:false];
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
    self.filterTextField.text = [pickerView.delegate pickerView:pickerView titleForRow:row forComponent:component];
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
    [datePicker dismissSemiModalView];
}


#pragma mark - Popup btns

- (IBAction)pressedEdit:(UIButton *)sender {
    if (!self.popedTracker){
        return;
    }
    ASTrackerConfigurationViewController *configVC = [ASTrackerConfigurationViewController initializeWithTrackerModel:self.popedTracker];
    if (!configVC){
        return;
    }
    [self.navigationController pushViewController:configVC animated:true];
}
- (IBAction)pressedMapBtn:(UIButton *)sender {
    DDLogInfo(@"pressedMapBtn");
   // [self.bottomPlank setHidden:true];
    self.bottomPlank.hidden = YES;
   // self.tapGestureDetails.enabled = NO;
}

- (IBAction)pressedCallBtn:(id)sender {
    if (!self.popedTracker || ![self.popedTracker trackerPhoneNumber] ){
        return;
    }
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",[self.popedTracker trackerPhoneNumber]]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView* calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }
}

#pragma mark - Sms

- (void) handleExistedTracker{
    @weakify(self)
    if (!self.apiController.userProfile.cookie){
        return;
    }
    DDLogInfo(@"-->3");
    
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kASUserDefaultsKeyResetAll]){
        return;
    }
    [[self.apiController getTrackers] subscribeNext:^(NSArray* trackers) {
        if (!trackers || trackers.count == 0){
            return;
        }
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reset_all", nil)
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"reset_all_btn", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             
                                                             
                                                             __block NSArray<ASTrackerModel*>* trackerList;
                                                             [[[self.apiController getTrackers] flattenMap:^id(NSArray *trackers)  {
                                                                 NSMutableArray* result = [NSMutableArray array];
                                                                 for (ASTrackerModel* tracker in trackers) {
                                                                     if (!tracker.trackerPhoneNumber){
                                                                         continue;
                                                                     }
                                                                     [result addObject:[tracker getSmsTextsForNewServer]];//[tracker getSmsTextsForActivation]];
                                                                 }
                                                                 trackerList = trackers;
                                                                 return [RACSignal zip:result];
                                                             }] subscribeNext:^(NSArray* listOfSMSList) {
                                                                 
                                                                 
                                                                 NSMutableArray* arr = [NSMutableArray array];
                                                                 
                                                                 for (int i = 0; i < trackerList.count; i++) {
                                                                     for (NSString* text in listOfSMSList[i]) {
                                                                         [arr addObject:@{trackerList[i].trackerPhoneNumber : text}];
                                                                     }
                                                                 }
                                                                 
                                                                 
                                                                 
                                                                 @strongify(self)
                                                                 RACSignal *signal = [RACSignal empty];
                                                                 for (NSDictionary* dict in arr) {
                                                                     signal = [signal then:^{
                                                                         return [self as_sendSMS:dict.allValues[0] ToRecipient:dict.allKeys[0]];
                                                                     }];
                                                                 }
                                                                 
                                                                 [signal subscribeCompleted:^{
                                                                     DDLogDebug(@"completed");
                                                                     [[NSUserDefaults standardUserDefaults] setObject:@"updated"
                                                                                                               forKey:kASUserDefaultsKeyResetAll];
                                                                 }];
                                                                 
                                                                 
                                                                 //
                                                             }];
                                                             
                                                         }];
        
        
        [alert addAction:okAction];
        
        //[alert.view setTintColor:[UIColor colorWithRed:22 / 255.0 green:189 / 255.0 blue:78/ 255.0 alpha:1.0]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
    
    
    
    
    
}

#pragma mark - Support

-(void)refreshLabel {
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:self.mapView.userLocation.coordinate.latitude
                                                  longitude:self.mapView.userLocation.coordinate.longitude];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:self.mapView.region.center.latitude
                                                  longitude:self.mapView.region.center.longitude];
    
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    if (distance >= 1000.0) {
        self.distanceMetricLabel.text = @"km";
        self.distanceLabel.text = [NSString stringWithFormat:@"%.03f", distance/1000];
    } else {
        self.distanceMetricLabel.text = @"m";
        self.distanceLabel.text = [NSString stringWithFormat:@"%d", (int)distance];
    }
    
}

-(void)refreshLine {
    CGPoint startPoint = [self.mapView convertCoordinate:self.mapView.userLocation.coordinate
                                           toPointToView:self.mapView];
    CGFloat newX = startPoint.x;
    CGFloat newY = startPoint.y;
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.dashedLineView.hidden = ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) ? YES : NO;
    }
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
}

#pragma mark - Tab bar delegate


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    if (![viewController isKindOfClass:[UINavigationController class]]){
        return;
    }
    if (![[viewController childViewControllers][0] isKindOfClass:[ASMapViewController class]]){
        return;
    }
    ASMapViewController* t = [viewController childViewControllers][0];
    NSString* need = [[NSUserDefaults standardUserDefaults] objectForKey: @"need_refresh"];
    if (need && [need isEqualToString:@"yes"] && t.isHistoryMode == false){
        DDLogInfo(@"refreshing 1");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"need_refresh"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [t refresh];
    }
    
    NSString* need2 = [[NSUserDefaults standardUserDefaults] objectForKey: @"need_refresh_history"];
    if (need2 && [need2 isEqualToString:@"yes"] && t.isHistoryMode == true){
        DDLogInfo(@"refreshing 2");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"need_refresh_history"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [t refresh];
    }
}


@end
