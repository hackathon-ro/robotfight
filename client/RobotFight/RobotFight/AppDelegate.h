//
//  AppDelegate.h
//  RobotFight
//
//  Created by George Jingoiu on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *viewController;

+ (NSString *) libraryDataFilePath:(NSString*) filename;
- (BOOL) getScreenshot;

@end
