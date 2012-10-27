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


@implementation ViewController

@synthesize mapView;
@synthesize imageView;

//******************************************************************************************************************************
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
    CGSize itemSize = CGSizeMake(42, 42);
    CGSize gridSize = CGSizeMake( 3,  2);
    
    UIView *inventoryView = [[[UIView alloc] initWithFrame:CGRectMake(-200, (self.view.frame.size.height - gridSize.height * itemSize.height)/2, 
                                                                      gridSize.width * itemSize.width, gridSize.height * itemSize.height)] autorelease];
    inventoryView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    inventoryView.layer.borderColor = [UIColor whiteColor].CGColor;
    inventoryView.layer.borderWidth = 2;
    
    //add arrow to inventory view
    
    [imageView addSubview:inventoryView];
    
    //add items
    
    [UIView transitionWithView:self.view duration: options:UIViewAnimationCurveEaseOut animations:^
     {
         CGRect frame 
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
- (void)dealloc {
    [mapView release];
    [imageView release];
    [super dealloc];
}
@end
