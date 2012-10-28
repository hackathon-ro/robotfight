//
//  PlayScene.m
//  RobotFight
//
//  Created by George Jingoiu on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayScene.h"
#import "AppDelegate.h"
#import "Defines.h"
#import "AsyncImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "Weapon.h"

#define kTagInventoryView   1000
#define kTagSetAngleView    2000
#define kDefaultHeading     -100 //virtual initial heading. Used in order to know when to update the heading first time


@implementation PlayScene

@synthesize mapView;
@synthesize imageView;
@synthesize diractionalArrow;
@synthesize locationManager;

//******************************************************************************************************************************
- (id) initWithPlayer1:(Player *) _player1 Player2:(Player *) _player2
{
    if((self = [super init]))
    {
        player1 = _player1;
        player2 = _player2;
    }

    return self;
}
//******************************************************************************************************************************
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"player1 = %@" , player1);
    NSLog(@"player2 = %@" , player2);
    
    [self.player1HP     setAlpha:0];
    [self.player2HP     setAlpha:0];
    [self.player1Label  setAlpha:0];
    [self.player2Label  setAlpha:0];
}
//******************************************************************************************************************************
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    initialHeading = kDefaultHeading;
    currentWeapon = 1;

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((player1.coordinates.latitude + player2.coordinates.latitude) / 2.0, (player1.coordinates.longitude + player2.coordinates.longitude) / 2.0 );
    MKCoordinateSpan span = MKCoordinateSpanMake(abs(player1.coordinates.latitude - player2.coordinates.latitude), abs(player1.coordinates.longitude - player2.coordinates.longitude));

//    span.longitudeDelta += 0.09;
//    span.latitudeDelta  += 0.09;

    [mapView setRegion:MKCoordinateRegionMake(center, span)];
}
//******************************************************************************************************************************
- (void) mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [self performSelector:@selector(makeScreenShot) withObject:nil afterDelay:5];
}
//******************************************************************************************************************************
- (void) makeScreenShot
{
    if(mapLoaded)
        return;

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    if([appDelegate getScreenshot])
    {
        [self screenshotSucceeded];
    }
    else
    {
        NSLog(@"screenshot failed");
        [self screenshotFailed];
    }
}
//******************************************************************************************************************************
- (void) screenshotSucceeded
{
    mapLoaded = TRUE;

    [self.diractionalArrow setHidden:FALSE];

    [imageView  setUserInteractionEnabled:TRUE];
    [imageView  setImage:[UIImage imageWithContentsOfFile:[AppDelegate libraryDataFilePath:mapScreenshotFilename]]];
    [imageView  setHidden:FALSE];
    [mapView    removeFromSuperview];

    [self loadItems];
    [self loadPlayers];
    
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	
    //verificam daca avem compass
	if ([CLLocationManager headingAvailable] == NO)
    {
        self.locationManager = nil;
        UIAlertView *noCompassAlert = [[UIAlertView alloc] initWithTitle:@"No Compass!" message:@"This device does not have the ability to measure magnetic fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noCompassAlert show];
        [noCompassAlert release];
	}
    else
    {
        locationManager.headingFilter = kCLHeadingFilterNone;
        locationManager.delegate = self;
        [locationManager startUpdatingHeading];
    }
}
//******************************************************************************************************************************
- (void) screenshotFailed
{
    
}
//******************************************************************************************************************************
- (void) loadPlayers
{
    CGPoint annPoint1 = [self.mapView convertCoordinate:player1.coordinates toPointToView:self.imageView];
    CGPoint annPoint2 = [self.mapView convertCoordinate:player2.coordinates toPointToView:self.imageView];
    
    UIButton *player1Button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 65)] autorelease];
    [player1Button setCenter:annPoint1];
//    [player1Button setBackgroundColor:[UIColor redColor]];
    [imageView addSubview:player1Button];
    
    UIButton *player2Button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 65)] autorelease];
    [player2Button setCenter:annPoint2];
//    [player2Button setBackgroundColor:[UIColor blueColor]];
    [imageView addSubview:player2Button];
    
    
    AsyncImageView *imgView1 = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, player1Button.frame.size.width, player1Button.frame.size.height)] autorelease];
    [imgView1 loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@" , imageGeneratorServer , player1.name]]];
    [player1Button addSubview:imgView1];
    
    AsyncImageView *imgView2 = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, player2Button.frame.size.width, player2Button.frame.size.height)] autorelease];
    [imgView2 loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@" , imageGeneratorServer , player2.name]]];
    [player2Button addSubview:imgView2];
    
    [self.player1HP setProgress:player1.hp];
    [self.player2HP setProgress:player2.hp];
    
    [self.player1Label setText:player1.name];
    [self.player2Label setText:player2.name];
    
    [UIView transitionWithView:self.view duration:1.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.player1Label  setAlpha:1];
        [self.player2Label  setAlpha:1];
        [self.player1HP     setAlpha:1];
        [self.player2HP     setAlpha:1];
    } completion:nil];
    
//    [player1Button setCenter:CGPointMake(x1, y1)];
//    [player2Button setCenter:CGPointMake(x2, y2)];
}
//******************************************************************************************************************************
- (void) loadItems
{
    CGSize itemSize = CGSizeMake(52, 52);
    CGSize gridSize = CGSizeMake( 3,  2);
    
    UIView *inventoryView = [[[UIView alloc] initWithFrame:CGRectMake(-200, (self.view.frame.size.height - gridSize.width * itemSize.height)/2, 
                                                                      gridSize.height * itemSize.width, gridSize.width * itemSize.height)] autorelease];
    inventoryView.backgroundColor   = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    inventoryView.layer.borderColor = [UIColor whiteColor].CGColor;
    inventoryView.tag = kTagInventoryView;
    inventoryView.layer.borderWidth = 2;
    [imageView addSubview:inventoryView];
    
    //add arrow to inventory view
    UIImage *arrowImage   = [UIImage imageNamed:@"dragArrow.png"];
    UIButton *arrowButton = [[[UIButton alloc] initWithFrame:CGRectMake(inventoryView.frame.size.width - inventoryView.layer.borderWidth,
                                                                     (inventoryView.frame.size.height - arrowImage.size.height)/2, 
                                                                      arrowImage.size.width, arrowImage.size.height)] autorelease];

    [arrowButton setImage:arrowImage forState:UIControlStateNormal];
    [arrowButton setAdjustsImageWhenHighlighted:FALSE];
    [arrowButton addTarget:self action:@selector(showInventory:) forControlEvents:UIControlEventTouchUpInside];
    [inventoryView addSubview:arrowButton];
    
    //add items
    NSString     *bundlePath        = [[NSBundle mainBundle] pathForResource:@"WeaponList" ofType:@"plist"];
	NSDictionary *plistDictionary   = [[[NSDictionary alloc] initWithContentsOfFile:bundlePath] autorelease];
    
    for(int i = 1 ; ; i++)
    {
        Weapon *newWeapon = [[[Weapon alloc] init] autorelease];
        
        NSString *name = [plistDictionary objectForKey:[NSString stringWithFormat:@"weapon%dName" , i]];
        if(!name)
             break;

        newWeapon.name      = name;
        newWeapon.imgName   = [ plistDictionary objectForKey:[NSString stringWithFormat:@"weapon%dImage"     , i]];
        newWeapon.ID        = [[plistDictionary objectForKey:[NSString stringWithFormat:@"weapon%dID"        , i]] intValue];
        newWeapon.damage    = [[plistDictionary objectForKey:[NSString stringWithFormat:@"weapon%dDamage"    , i]] intValue];
        newWeapon.radius    = [[plistDictionary objectForKey:[NSString stringWithFormat:@"weapon%dRange"     , i]] intValue];

        UIButton *weaponButton = [UIButton buttonWithType:UIButtonTypeCustom];
        int line    = i / (int)gridSize.width;
        int column  = (i + 1) % (int)gridSize.height;
        [weaponButton setFrame:CGRectMake(column * itemSize.width, line * itemSize.height, itemSize.width, itemSize.height)];
        NSLog(@"frame = %@" , NSStringFromCGRect(weaponButton.frame));
        [weaponButton setBackgroundColor:[UIColor blackColor]];
        [weaponButton setImage:[UIImage imageNamed:newWeapon.imgName] forState:UIControlStateNormal];
        [weaponButton setTag:newWeapon.ID];
        [weaponButton addTarget:self action:@selector(onWeaponSelect:) forControlEvents:UIControlEventTouchUpInside];

        weaponButton.layer.borderWidth = 1;
        [inventoryView addSubview:weaponButton];
    }

    UIButton *defaultWeapon = (UIButton *)[inventoryView viewWithTag:currentWeapon];
    [self onWeaponSelect:defaultWeapon];
    [self onWeaponSelect:defaultWeapon];
    
    [UIView transitionWithView:self.view duration:2 options:UIViewAnimationCurveEaseOut animations:^
     {
         CGRect frame   = inventoryView.frame;
         frame.origin.x = - frame.size.width;
         [inventoryView setFrame:frame];
     }completion:^(BOOL finished)
     {
         //add gesture recognizer

         UISwipeGestureRecognizer *swipeGesture = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showInventory:)] autorelease];
         [swipeGesture setCancelsTouchesInView:FALSE];
         [swipeGesture setDelaysTouchesBegan:FALSE];
         [swipeGesture setDelaysTouchesEnded:FALSE];
         [swipeGesture setDelegate:self];
         [swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
         [self.view addGestureRecognizer:swipeGesture];
     }];
}
//******************************************************************************************************************************
- (void) onWeaponSelect:(id) sender
{
    if(![sender isMemberOfClass:[UIButton class]])
        return;

    UIButton *senderButton = (UIButton *) sender;
    currentWeapon = senderButton.tag;
    
    for(UIButton *weapon in senderButton.superview.subviews)
    {
        if([weapon isMemberOfClass:[UIButton class]] && weapon.tag)
        {
            NSLog(@"select weapon %d" , weapon.tag);
            if(weapon.tag == currentWeapon)
                weapon.layer.borderColor = [UIColor whiteColor].CGColor;
            else
                weapon.layer.borderColor = [UIColor darkGrayColor].CGColor;
        }
    }
    
    [self showInventory:sender];
}
//******************************************************************************************************************************
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:gestureRecognizer.view];

    if(location.x > 200)
        return FALSE;

    return TRUE;
}
//******************************************************************************************************************************
- (void) showInventory:(id) sender
{
    if(!([sender isKindOfClass:[UIButton class]] || [sender isKindOfClass:[UIGestureRecognizer class]]))
    {
        NSLog(@"error. showInventory was called by a %@" , NSStringFromClass([sender class]));
        return;
    }

    UIView *inventoryView = [imageView viewWithTag:kTagInventoryView];

    if(!inventoryView)
    {
        NSLog(@"no inventory view. Critical error");
        return;
    }

    inventoryIsVisible = !inventoryIsVisible;

    for(UISwipeGestureRecognizer *gesture in self.view.gestureRecognizers)
    {
        if([gesture isMemberOfClass:[UISwipeGestureRecognizer class]])
        {
            if(inventoryIsVisible)
                [gesture setDirection:UISwipeGestureRecognizerDirectionLeft];
            else
                [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
        }
    }

    int deltaX;
    if(inventoryIsVisible)
        deltaX = inventoryView.frame.size.width;
    else
        deltaX = - inventoryView.frame.size.width;

    CGRect frame = inventoryView.frame;
    frame.origin.x += deltaX;
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationCurveEaseOut animations:^
     {
         [inventoryView setFrame:frame];
     }completion:nil];
}
//******************************************************************************************************************************
- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading 
{
    CLLocationDirection direction = heading.trueHeading;
    
    if(initialHeading == kDefaultHeading)
    {
        initialHeading = heading.trueHeading;
        [self showSetAngleView];
    }
    else
    {
        if(direction > initialHeading)
            direction -= initialHeading;
        else
            direction = -(initialHeading - direction);
        [self.diractionalArrow setTransform:CGAffineTransformMakeRotation(RADIANS(direction))];
    }
}
//******************************************************************************************************************************
// This delegate method is invoked when the location managed encounters an error condition.
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error 
{
    if ([error code] == kCLErrorDenied) 
    {
        [manager stopUpdatingHeading];// This error indicates that the user has denied the application's request to use location services.
    } else if ([error code] == kCLErrorHeadingFailure) 
    {
        // This error indicates that the heading could not be determined, most likely because of strong magnetic interference.
    }
}
//******************************************************************************************************************************
- (void) showSetAngleView
{
    UIButton *setAngle = [UIButton buttonWithType:UIButtonTypeCustom];
    [setAngle setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 150)];
    [setAngle addTarget:self action:@selector(onDirectionSet:) forControlEvents:UIControlEventTouchUpInside];
    [setAngle setBackgroundColor:[UIColor darkGrayColor]];
    [setAngle layer].borderColor = [UIColor whiteColor].CGColor;
    [setAngle layer].borderWidth = 2;
    [setAngle layer].masksToBounds = TRUE;
    [setAngle layer].cornerRadius = 130;
    [setAngle setTitle:@"Set angle" forState:UIControlStateNormal];
    [setAngle setTag:kTagSetAngleView];
    [self.view addSubview:setAngle];

    [UIView transitionWithView:self.view duration:1 options:UIViewAnimationCurveEaseOut animations:^
     {
         CGRect frame = setAngle.frame;
         frame.origin.y = self.view.frame.size.height - setAngle.frame.size.height/2;
         [setAngle setFrame:frame];
     }completion:nil];
}
//******************************************************************************************************************************
- (void) onDirectionSet:(id) sender
{
    [locationManager stopUpdatingHeading];
    
    UIView *setAngle = [self.view viewWithTag:kTagSetAngleView];
    if(setAngle)
    {
        [UIView transitionWithView:self.view duration:1 options:UIViewAnimationCurveEaseOut animations:^
         {
             CGRect frame = setAngle.frame;
             frame.origin.y = self.view.frame.size.height;
             [setAngle setFrame:frame];
         }completion:nil];
    }
}
//******************************************************************************************************************************
- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setImageView:nil];
    [self setDiractionalArrow:nil];
    [self setPlayer1Label:nil];
    [self setPlayer2Label:nil];
    [self setPlayer1HP:nil];
    [self setPlayer2HP:nil];
    [super viewDidUnload];
}
//******************************************************************************************************************************
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//******************************************************************************************************************************
- (void)dealloc 
{
    [mapView            release];
    [imageView          release];
    [diractionalArrow   release];
    [_player1Label release];
    [_player2Label release];
    [_player1HP release];
    [_player2HP release];
    [super              dealloc];
}
//******************************************************************************************************************************
@end