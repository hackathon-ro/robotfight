//
//  ViewController.h
//  RobotFight
//
//  Created by Vlad Hudea-Nojogan on 10/27/12.
//  Copyright (c) 2012 RobotFight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate , NSURLConnectionDataDelegate>
{
	NSMutableData *serverInfo;
}
@property (retain, nonatomic) IBOutlet UITextField *textField;

- (IBAction)GetStarted:(id)sender;

@end
