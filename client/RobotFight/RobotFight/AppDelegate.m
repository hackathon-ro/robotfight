//
//  AppDelegate.m
//  RobotFight
//
//  Created by George Jingoiu on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Defines.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Player.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

//******************************************************************************************************************************
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    userName = @"George";

    Player *player1 = [[[Player alloc] init] retain];
    Player *player2 = [[[Player alloc] init] retain];
    
    player1.name        = @"George";
    player1.hp          = 100;
    player1.coordinates = CLLocationCoordinate2DMake(48.722861, 2.373047); //paris
    player1.score       = 0;
    player1.totalGames  = 0;
    player1.wins        = 0;
    
    player2.name        = @"Deea";
    player2.hp          = 100;
    player2.coordinates = CLLocationCoordinate2DMake(38.482835, -9.096680); //lisabona
    player2.score       = 0;
    player2.totalGames  = 0;
    player2.wins        = 0;
    
    //decide enter screen
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[UINavigationController alloc] initWithRootViewController:[[[ViewController alloc] init] autorelease]];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}
//******************************************************************************************************************************
+ (NSString *) libraryDataFilePath:(NSString*) filename
{    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:filename];
}
//******************************************************************************************************************************
- (BOOL) getScreenshot
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.window.bounds.size);
    
    [self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * data = UIImagePNGRepresentation(image);
    return [data writeToFile:[AppDelegate libraryDataFilePath:mapScreenshotFilename] atomically:YES];
}
//******************************************************************************************************************************
- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}
//******************************************************************************************************************************
@end
