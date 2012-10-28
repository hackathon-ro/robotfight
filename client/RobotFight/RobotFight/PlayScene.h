//
//  PlayScene.h
//  RobotFight
//
//  Created by George Jingoiu on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreMotion/CoreMotion.h>
#import "Player.h"

@interface PlayScene : UIViewController <MKMapViewDelegate , UIGestureRecognizerDelegate , CLLocationManagerDelegate>
{
    BOOL inventoryIsVisible;
    BOOL mapLoaded;
    int currentWeapon;

    CLLocationDirection initialHeading;
    CLLocationDirection throwingHeading;
    CLLocationManager *locationManager;
    
    CMMotionManager *motionManager;

    Player *player1;
    Player *player2;
    
    NSTimer *accelerometerTimer;
    
    CMAcceleration oldAcceleration;
    CGPoint playerLocationInView;
    
    BOOL hasStartedMovement;
    double throwingPower;
    double previousPower;
    
    BOOL isTurn;
}
@property (nonatomic, retain) IBOutlet MKMapView    *mapView;
@property (nonatomic, retain) IBOutlet UIImageView  *imageView;
@property (nonatomic, retain) IBOutlet UIImageView  *diractionalArrow;
@property (nonatomic, retain) CLLocationManager     *locationManager;
@property (nonatomic, retain) IBOutlet UILabel      *player1Label;
@property (nonatomic, retain) IBOutlet UILabel      *player2Label;
@property (nonatomic, retain) IBOutlet UIProgressView *player1HP;
@property (nonatomic, retain) IBOutlet UIProgressView *player2HP;


- (id) initWithPlayer1:(Player *) _player1 Player2:(Player *) _player2 isTurn:(BOOL) _isTurn;
- (void) setIsTurn:(BOOL) newValue;
@end