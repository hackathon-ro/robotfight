//
//  ViewController.m
//  RobotFight
//
//  Created by George Jingoiu on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Defines.h"
#import <QuartzCore/QuartzCore.h>
#import "Weapon.h"

#define kTagInventoryView 1000


@implementation ViewController

@synthesize mapView;
@synthesize imageView;

//******************************************************************************************************************************
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    currentWeapon = 1;
    
    CLLocationCoordinate2D coord1;
    CLLocationCoordinate2D coord2;
    
    coord1 = CLLocationCoordinate2DMake(48.137500, 11.577590);
    coord2 = CLLocationCoordinate2DMake(39.923219, -5.273438);
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((coord1.latitude + coord2.latitude) / 2.0, (coord1.longitude + coord2.longitude) / 2.0 );
    NSLog(@"center = %@" , NSStringFromCGPoint(CGPointMake(center.latitude, center.longitude)));
    MKCoordinateSpan span = MKCoordinateSpanMake(abs(coord1.latitude - coord2.latitude), abs(coord1.longitude - coord2.longitude));
    
//    span.longitudeDelta += 0.09;
//    span.latitudeDelta  += 0.09;

    [mapView setRegion:MKCoordinateRegionMake(center, span)];
}
//******************************************************************************************************************************
- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if([appDelegate getScreenshot])
    {
        [self performSelector:@selector(screenshotSucceeded) withObject:nil afterDelay:0];
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
    if(mapLoaded)
        return;
    
    mapLoaded = TRUE;
    [imageView setUserInteractionEnabled:TRUE];
    [imageView  setImage:[UIImage imageWithContentsOfFile:[AppDelegate libraryDataFilePath:mapScreenshotFilename]]];
    [imageView  setHidden:FALSE];
    [mapView    removeFromSuperview];

    [self loadItems];
}
//******************************************************************************************************************************
- (void) screenshotFailed
{
    
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
    [self performSelector:@selector(onWeaponSelect:) withObject:defaultWeapon afterDelay:0];
    
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
}
//******************************************************************************************************************************
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:gestureRecognizer.view];

//    UISwipeGestureRecognizer *swipeGesture = (UISwipeGestureRecognizer *) gestureRecognizer;
//    if(inventoryIsVisible)
//        [swipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
//    else
//        [swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];

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
- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setImageView:nil];
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
    [mapView    release];
    [imageView  release];
    [super      dealloc];
}
//******************************************************************************************************************************
@end