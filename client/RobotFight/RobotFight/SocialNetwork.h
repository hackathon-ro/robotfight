

#import <UIKit/UIKit.h>

@interface SocialNetwork : UIViewController
{
	NSTimer *timer;
}
- (IBAction)Twit:(id)sender;
- (IBAction)PostToFacebook:(id)sender;
- (IBAction)ShowPopOver:(id)sender;

@property (retain, nonatomic) IBOutlet UILabel *hpUser;
@property (retain, nonatomic) IBOutlet UILabel *turnLabel;

@end



