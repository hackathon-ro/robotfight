#import "SocialNetwork.h"
#import "Social/Social.h"
#import "PlayScene.h"
#import "Defines.h"

@interface SocialNetwork ()
@end

@implementation SocialNetwork

@synthesize hpUser, turnLabel;
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
	[hpUser setText: @"100"];
	timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getUpdates) userInfo:nil repeats:YES] retain];
}
// ----------------------------------------------------------------------------
- (void) getUpdates
{	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSString *userToken = [userDefaults objectForKey:@"token"];
	NSError  *error     = nil;
	
	NSDictionary *information   = [NSDictionary dictionaryWithObjectsAndKeys: userToken, @"token", nil];
	NSData       *jsonData      = [NSJSONSerialization dataWithJSONObject: information options:NSJSONWritingPrettyPrinted error:&error];
	
	
	NSString *text = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

	NSLog(@"JSON to server: %@", text);
	
	NSMutableURLRequest *theRequest=[ NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get-updates" , JSONServer]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0.5 ];
	
	[theRequest setHTTPMethod: @"POST"];
	[theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[theRequest setValue:[NSString stringWithFormat:@"%d" , [jsonData length]] forHTTPHeaderField:@"Content-Length"];

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

// ----------------------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"Connection did receive data");
    NSError *error;
	
	
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error];
	
	if([json count] == 0)
	{
		NSLog(@"Data Set is empty");
	}
	
	else
	{
		NSLog(@"Got here");
		NSString *action = [json objectForKey:@"success"];
		NSLog(@"Action: %@", action);
		
		
		NSArray *updates = [json objectForKey:@"updates"];
		
		for(int i = 0; i < [updates count]; i++)
		{
			NSDictionary *dictionary = [updates objectAtIndex: i];
						
			NSString *act = [dictionary objectForKey:@"action"];
			NSLog(@"ACTION %@", act);
			if([act isEqualToString: [NSString stringWithFormat:@"%@", @"found-match"]])
			{
				
				NSDictionary *information = [dictionary objectForKey:@"data"];
				NSLog(@"Data: %@", information);
				
				NSString *latitude  = [information objectForKey:@"lat"];
				NSString *longitude = [information objectForKey:@"long"];
				NSString *username  = [information objectForKey:@"username"];
				NSString *your_turn =  [information objectForKey:@"your-turn"];
				
				NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
				NSString *currentUsername = [userDefaults objectForKey:@"username"];
                NSString *wins      = [userDefaults objectForKey:@"wins"];
                NSString *losses    = [userDefaults objectForKey:@"losses"];
//                NSString *token     = [userDefaults objectForKey:@"token"];
                NSString *location  = [userDefaults objectForKey:@"coordinates"];
                CGPoint locationCoordinates = CGPointFromString(location);
                
				if(your_turn.intValue == TRUE)
				{
				
					[turnLabel setText: [NSString stringWithFormat: @"Get ready, %@! It's your turn!", currentUsername]];
				}
				else
				{
					[turnLabel setText: [NSString stringWithFormat: @"It's %@'s turn", username]];
				}
				
				NSLog(@"%@ %@ %@ %@", latitude, longitude, username, your_turn);
				
				Player *player1 = [[[Player alloc] init] retain];
				Player *player2 = [[[Player alloc] init] retain];

				player1.name        = username;
				player1.hp          = 100;
				player1.coordinates = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
				player1.score       = 0;
				player1.totalGames  = wins.integerValue + losses.integerValue;
				player1.wins        = wins.integerValue;
                player1.ID          = 5;

				player2.name        = currentUsername;
				player2.hp          = 100;
				player2.coordinates = CLLocationCoordinate2DMake(locationCoordinates.x, locationCoordinates.y);
				player2.score       = 0;
				player2.totalGames  = 0;
				player2.wins        = 0;
				player2.ID          = 2;
				
				NSLog(@"player1 = %@" , player1);
				NSLog(@"player2 = %@" , player2);
				
				[timer invalidate];
				timer = nil;
				PlayScene *playScene = [[PlayScene alloc] initWithPlayer1: player1 Player2:player2 isTurn:your_turn.boolValue];
				[self.navigationController pushViewController: playScene animated: YES];
			}
			else if([act isEqualToString:@"hit"])
			{
				NSLog(@"Hit");
				
				NSDictionary *information = [dictionary objectForKey:@"data"];
				NSLog(@"Data: %@", information);
				
				NSString *latitude = [information objectForKey:@"lat"];
				NSString *longitude = [information objectForKey:@"long"];
				NSString *hp = [information objectForKey:@"hp"];
				
				int hpIntegerValue = [hp integerValue];
				int remainingLife = 100 - hpIntegerValue;
				NSString *hpString = [NSString stringWithFormat:@"%i", remainingLife];
				
				NSLog(@"%@ %@ %@", latitude, longitude, hp);
				[hpUser setText: hpString];
			}
		}
	}
	
}
// ----------------------------------------------------------------------------
- (IBAction)ShowPopOver:(id)sender {
	
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
- (IBAction)PostToFacebook:(id)sender
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        
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
	[hpUser release];
	[turnLabel release];
	[super dealloc];
}
@end
