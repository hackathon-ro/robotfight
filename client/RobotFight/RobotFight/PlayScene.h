//
//  ViewController.h
//  RobotFight
//
//  Created by George Jingoiu on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <MKMapViewDelegate , UIGestureRecognizerDelegate>
{
    BOOL inventoryIsVisible;
    BOOL mapLoaded;
    int currentWeapon;
}
@property (retain, nonatomic) IBOutlet MKMapView    *mapView;
@property (retain, nonatomic) IBOutlet UIImageView  *imageView;

@end
