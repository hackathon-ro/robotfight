//
//  ViewController.h
//  RobotFight
//
//  Created by Vlad Hudea-Nojogan on 10/27/12.
//  Copyright (c) 2012 RobotFight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <UITextFieldDelegate , NSURLConnectionDataDelegate , CLLocationManagerDelegate>
{
	NSMutableData *serverInfo;
}
@property (retain, nonatomic) IBOutlet UITextField *textField;
@property (retain, nonatomic) IBOutlet UIButton *buttonGetStarted;

- (IBAction)GetStarted:(id)sender;
- (void) SendInformation;


@end