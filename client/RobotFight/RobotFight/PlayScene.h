//
//  PlayScene.h
//  RobotFight
//
//  Created by George Jingoiu on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Player.h"

@interface PlayScene : UIViewController <MKMapViewDelegate , UIGestureRecognizerDelegate , CLLocationManagerDelegate>
{
    BOOL inventoryIsVisible;
    BOOL mapLoaded;
    int currentWeapon;

    CLLocationDirection initialHeading;
    CLLocationManager *locationManager;
    
    Player *player1;
    Player *player2;
}
@property (nonatomic, retain) IBOutlet MKMapView    *mapView;
@property (nonatomic, retain) IBOutlet UIImageView  *imageView;
@property (nonatomic, retain) IBOutlet UIImageView  *diractionalArrow;
@property (nonatomic, retain) CLLocationManager     *locationManager;
@property (retain, nonatomic) IBOutlet UILabel *player1Label;
@property (retain, nonatomic) IBOutlet UILabel *player2Label;
@property (retain, nonatomic) IBOutlet UIProgressView *player1HP;
@property (retain, nonatomic) IBOutlet UIProgressView *player2HP;


- (id) initWithPlayer1:(Player *) _player1 Player2:(Player *) _player2;

@end