#import "SocialNetwork.h"
#import "Social/Social.h"

@interface SocialNetwork ()
@end

@implementation SocialNetwork

// ----------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
// ----------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
}
// ----------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
// ----------------------------------------------------------------------------
- (IBAction)Twit:(id)sender {
	
	if([SLComposeViewController isAvailableForServiceType: SLServiceTypeTwitter]) {
		
		SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		
		SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
			if (result == SLComposeViewControllerResultCancelled)
			{
				NSLog(@"Cancelled");
			}
			
			else
			{
				NSLog(@"Done");
			}
			
			[controller dismissViewControllerAnimated:YES completion:Nil];
		};
		
		controller.completionHandler = myBlock;
		[controller setInitialText:@"Testing the coolest game :)"];
		//[controller addImage:[UIImage imageNamed:@"fb.png"]];
		[self presentViewController:controller animated:YES completion:Nil];
		
	}
	else
	{
		NSLog(@"UnAvailable");
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Twitter service is unavailable" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
		
		[alertView show];
	}

}
// ----------------------------------------------------------------------------
- (IBAction)PostToFacebook:(id)sender {
	
		if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
			
			SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
			
			SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
				if (result == SLComposeViewControllerResultCancelled)
				{
					NSLog(@"Cancelled");
					
				}
				else
				{
					NSLog(@"Done");
				}
				
				[controller dismissViewControllerAnimated:YES completion:Nil];
			};
			
			controller.completionHandler = myBlock;
			[controller setInitialText:@"Testing the coolest game :)"];
			//[controller addImage:[UIImage imageNamed:@"fb.png"]];
			
			[self presentViewController:controller animated:YES completion:Nil];
			
		}
		else
		{
			NSLog(@"UnAvailable");
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Twitter service is unavailable" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			
			[alertView show];
		}
}
// ----------------------------------------------------------------------------
- (void)dealloc {
	[super dealloc];
}
@end
