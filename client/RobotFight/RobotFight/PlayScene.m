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
#import "PopoverView.h"

#define kTagInventoryView   1000
#define kTagSetAngleView    2000
#define kDefaultHeading     -100 //virtual initial heading. Used in order to know when to update the heading first time

#define minimalMovementSpike    1
#define maximumMovementSpeed    5.5



@implementation PlayScene

@synthesize mapView;
@synthesize imageView;
@synthesize diractionalArrow;
@synthesize locationManager;

//******************************************************************************************************************************
- (id) initWithPlayer1:(Player *) _player1 Player2:(Player *) _player2 isTurn:(BOOL) _isTurn
{
    if((self = [super init]))
    {
        player1 = _player1;
        player2 = _player2;
        
        isTurn = _isTurn;
        NSLog(@"turn = %d" , _isTurn);
    }

    return self;
}
//******************************************************************************************************************************
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"player1 = %@" , player1);
    NSLog(@"player2 = %@" , player2);
    
    oldAcceleration.x = -100;
    oldAcceleration.y = -100;
    oldAcceleration.z = -100;
    
    [self.player1HP     setAlpha:0];
    [self.player2HP     setAlpha:0];
    [self.player1Label  setAlpha:0];
    [self.player2Label  setAlpha:0];
    [self.player2HP     setTransform:CGAffineTransformMakeRotation(RADIANS(180))];
}
//******************************************************************************************************************************
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    currentWeapon = 1;

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((player1.coordinates.latitude + player2.coordinates.latitude) / 2.0, (player1.coordinates.longitude + player2.coordinates.longitude) / 2.0 );
    MKCoordinateSpan span = MKCoordinateSpanMake(abs(player1.coordinates.latitude - player2.coordinates.latitude), abs(player1.coordinates.longitude - player2.coordinates.longitude));

    span.longitudeDelta += 0.06;
    span.latitudeDelta  += 0.06;

    [mapView setRegion:MKCoordinateRegionMake(center, span)];
}
//******************************************************************************************************************************
- (void) mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [self performSelector:@selector(makeScreenShot) withObject:nil afterDelay:2];
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
    if(isTurn)
    {
        [self setIsTurn:TRUE];
    }
    
    mapLoaded = TRUE;

    [imageView  setUserInteractionEnabled:TRUE];
    [imageView  setImage:[UIImage imageWithContentsOfFile:[AppDelegate libraryDataFilePath:mapScreenshotFilename]]];
    [imageView  setHidden:FALSE];
    [mapView    removeFromSuperview];

    [self loadItems];
    [self loadPlayers];
}
//******************************************************************************************************************************
- (void) sendParameters: (int) angle: (int) power: (Player*) player: (int) weaponID
{
	NSString *angleString = [NSString stringWithFormat:@"%i", angle];
	NSString *powerString = [NSString stringWithFormat:@"%i", power];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSString *userToken = [userDefaults objectForKey:@"token"];
	
	NSError *error;
	NSDictionary *information = [NSDictionary dictionaryWithObjectsAndKeys: angleString, @"angle", powerString, @"power", userToken, @"token", nil];
	
	NSData* jsonData = [NSJSONSerialization dataWithJSONObject: information options:NSJSONWritingPrettyPrinted error:&error];
	
	
	NSString *text = [[NSString alloc] initWithData:jsonData
										   encoding:NSUTF8StringEncoding];
	
	NSLog(@"JSON to server: %@", text);
	
	NSMutableURLRequest *theRequest=[ NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://10.10.2.97/get-updates"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0.5 ];
	
	[theRequest setHTTPMethod: @"POST"];
	[theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[theRequest setValue:[NSString stringWithFormat:@"%d",[jsonData length]] forHTTPHeaderField:@"Content-Length"];
	
	[theRequest setHTTPBody:jsonData];
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if(theConnection)
	{
		NSLog(@"Success");
	}
	else
	{
		NSLog(@"Error");
	}
}
// ----------------------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"Data sent to server");
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    int statusCode = [httpResponse statusCode];
	NSLog(@"Status code %d", statusCode);
}
// ----------------------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"Connection did receive data");
    NSError *error;

//    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
	// getting position from server
	
	// animating
	
	// updating score
	
}
- (void) goAnimation: (int) x: (int) y
{
	NSString     *bundlePath        = [[NSBundle mainBundle] pathForResource:@"WeaponList" ofType:@"plist"];
	NSDictionary *plistDictionary   = [[[NSDictionary alloc] initWithContentsOfFile:bundlePath] autorelease];
	
	UIImageView *weapon = [ plistDictionary objectForKey:[NSString stringWithFormat:@"weapon%dImage",0]];
	
	CGPoint center1 =  CGPointMake(x/2.0, y/2.0);
	CGPoint target = CGPointMake(x, y);
	
	
	[UIView animateWithDuration: 0.5
                          delay: 3.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         CGPoint center;
						 center = center1;
                         
                         center.y -= 40;
                         weapon.center = center;
                     }
                     completion: ^(BOOL finished){
                         [UIView animateWithDuration: 0.5
                                               delay: 1.0
                                             options: UIViewAnimationCurveEaseIn
                                          animations: ^{
                                              weapon.center = target;
                                          }
                                          completion: ^(BOOL finished){
                                              ;
                                          }];
                         
                     }];
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

    annPoint1.x *= scaleFactor;
    annPoint1.y *= scaleFactor;
    annPoint2.x *= scaleFactor;
    annPoint2.y *= scaleFactor;
    
    playerLocationInView = annPoint1;

    UIButton *player1Button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 65)] autorelease];
    [player1Button setCenter:annPoint1];
    [player1Button setTag:player1.ID];
    NSLog(@"tag1 = %d" , player1Button.tag);
    [player1Button addTarget:self action:@selector(onPlayerInfo:) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:player1Button];

    UIButton *player2Button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 65)] autorelease];
    [player2Button setCenter:annPoint2];
    [player2Button setTag:player2.ID];
    NSLog(@"tag2 = %d" , player2Button.tag);
    [player2Button addTarget:self action:@selector(onPlayerInfo:) forControlEvents:UIControlEventTouchUpInside];
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

    if(location.x > 250)
        return FALSE;

    return TRUE;
}
//******************************************************************************************************************************
- (void) showInventory:(id) sender
{
    [self setIsTurn:!isTurn];     //debug

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
    throwingHeading = heading.trueHeading;
    
    if(initialHeading == kDefaultHeading)
    {
        initialHeading = heading.trueHeading;
        [self showSetAngleView];
    }
    else
    {
        if(throwingHeading > initialHeading)
            throwingHeading -= initialHeading;
        else
            throwingHeading = -(initialHeading - throwingHeading);
        [self.diractionalArrow setTransform:CGAffineTransformMakeRotation(RADIANS(throwingHeading))];
    }
}
//******************************************************************************************************************************
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error 
{
    if ([error code] == kCLErrorDenied) 
    {
        [manager stopUpdatingHeading];// This error indicates that the user has denied the application's request to use location services.
    }
    else if ([error code] == kCLErrorHeadingFailure)
    {
        // This error indicates that the heading could not be determined, most likely because of strong magnetic interference.
    }
}
//******************************************************************************************************************************
- (void) showSetAngleView
{
    UIButton *setAngle = (UIButton *)[self.view viewWithTag:kTagSetAngleView];
    
    if(!setAngle)
    {
        setAngle = [UIButton buttonWithType:UIButtonTypeCustom];
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
    }

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

    motionManager = [[[CMMotionManager alloc] init] retain];
    [motionManager setAccelerometerUpdateInterval:1.0/60.0];
    [motionManager startAccelerometerUpdates];

    accelerometerTimer = [[NSTimer scheduledTimerWithTimeInterval:motionManager.accelerometerUpdateInterval target:self selector:@selector(checkAccelerometer) userInfo:nil repeats:TRUE] retain];

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
- (void) checkAccelerometer
{
    if(!(oldAcceleration.x + oldAcceleration.y + oldAcceleration.z == -300))
    {
        double xd = oldAcceleration.x-motionManager.accelerometerData.acceleration.x;
        double yd = oldAcceleration.y-motionManager.accelerometerData.acceleration.y;
        double zd = oldAcceleration.z-motionManager.accelerometerData.acceleration.z;
        previousPower = throwingPower;
        throwingPower = sqrt(xd*xd + yd*yd + zd*zd);

        NSLog(@"throwing power = %f" , throwingPower);

        if(throwingPower > minimalMovementSpike && !hasStartedMovement)
            hasStartedMovement = TRUE;
        
        else if(throwingPower < minimalMovementSpike && hasStartedMovement)
        {
            throwingPower = previousPower;
            [self stopThrowing];
            return;
        }

        else if (throwingPower > maximumMovementSpeed)
        {
            NSLog(@"You reached Mach 1. Engage!");
            //stop
            throwingPower = previousPower;
            [self stopThrowing];
            return;
        }
    }

    oldAcceleration = motionManager.accelerometerData.acceleration;
}
//******************************************************************************************************************************
- (void) stopThrowing
{
    [accelerometerTimer invalidate];
    [accelerometerTimer release];
     accelerometerTimer = nil;

    if(throwingPower < minimalMovementSpike)
        throwingPower = minimalMovementSpike;
    else if(throwingPower > maximumMovementSpeed)
        throwingPower = maximumMovementSpeed;

    throwingPower -= minimalMovementSpike;
    throwingPower /= ((maximumMovementSpeed - minimalMovementSpike) * 1.0);
    //use power here
    NSLog(@"throwing power = %f" , throwingPower);
    
    [self sendParameters:throwingHeading :throwingPower :player1 :currentWeapon];
    
    throwingPower = 0;
    previousPower = 0;
    hasStartedMovement = FALSE;
    oldAcceleration.x = -100;
    oldAcceleration.y = -100;
    oldAcceleration.z = -100;
}
//******************************************************************************************************************************
- (void) updateHPForPlayer:(Player *) player
{
    UIProgressView *progressView;
    if(player == player1)
        progressView = self.player1HP;
    else
        progressView = self.player2HP;
    
    [progressView setProgress:player.hp/100.0];
    [progressView setProgressTintColor:[UIColor colorWithRed:(1 - player.hp/100.0) green:player.hp/100.0 blue:0 alpha:1]];
}
//******************************************************************************************************************************
- (void) setIsTurn:(BOOL) newValue
{
    isTurn = newValue;
    
    if(isTurn)
        [self showAttackUI];
    else
        [self hideAttackUI];
}
//******************************************************************************************************************************
- (void) onPlayerInfo:(id) sender
{
    if(![sender isMemberOfClass:[UIButton class]])
        return;
    
    UIColor *textColor = [UIColor colorWithRed:27/255.0 green:99/255.0 blue:199/255.0 alpha:1];
    
    UIButton *senderButton = (UIButton *) sender;
    Player *selectedPlayer = (senderButton.tag == player1.ID) ? player1 : player2;
    
    UIView *infoView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 90)] autorelease];
    [infoView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 5, infoView.frame.size.width - 10, 20)] autorelease];
    [nameLabel setText:selectedPlayer.name];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setTextColor:textColor];
    [infoView addSubview:nameLabel];

    UILabel *scoreLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 25, infoView.frame.size.width - 10, 20)] autorelease];
    [scoreLabel setText:[NSString stringWithFormat:@"Score: %d" , selectedPlayer.score]];
    [scoreLabel setBackgroundColor:[UIColor clearColor]];
    [scoreLabel setTextColor:textColor];
    [infoView addSubview:scoreLabel];

    UILabel *playedLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 45, infoView.frame.size.width - 10, 20)] autorelease];
    [playedLabel setText:[NSString stringWithFormat:@"Played: %d" , selectedPlayer.totalGames]];
    [playedLabel setBackgroundColor:[UIColor clearColor]];
    [playedLabel setTextColor:textColor];
    [infoView addSubview:playedLabel];
    
    UILabel *winsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 65, infoView.frame.size.width - 10, 20)] autorelease];
    [winsLabel setText:[NSString stringWithFormat:@"Won: %d" , selectedPlayer.wins]];
    [winsLabel setBackgroundColor:[UIColor clearColor]];
    [winsLabel setTextColor:textColor];
    [infoView addSubview:winsLabel];
    
    [PopoverView showPopoverAtPoint:senderButton.center inView:self.view withContentView:infoView delegate:nil];
    
    //show popover from senderButton
}
//******************************************************************************************************************************
- (void) showAttackUI
{
    initialHeading = kDefaultHeading;
    
    [self.diractionalArrow setHidden:FALSE];
    [self.diractionalArrow setCenter:playerLocationInView];
    
    [UIView transitionWithView:self.view duration:1 options:UIViewAnimationCurveEaseOut animations:^
     {
         [self.diractionalArrow setAlpha:1];
     }completion:nil];
    
    if(locationManager)
        [locationManager startUpdatingHeading];
    else
    {
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
    
    
}
//******************************************************************************************************************************
- (void) hideAttackUI
{
    [UIView transitionWithView:self.view duration:1 options:UIViewAnimationCurveEaseOut animations:^
     {
         [self.diractionalArrow setAlpha:0];
     }completion:nil];

    if(locationManager)
        [locationManager stopUpdatingHeading];

    UIView *setAngleView = [self.view viewWithTag:kTagSetAngleView];
    [UIView transitionWithView:self.view duration:1 options:UIViewAnimationCurveEaseIn animations:^
     {
         CGRect setAngleFrame = setAngleView.frame;
         setAngleFrame.origin.y = self.view.frame.size.height;
         [setAngleView setFrame:setAngleFrame];
     }completion:nil];
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
    if(motionManager)
    {
        [motionManager release];
        motionManager = nil;
    }
    
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