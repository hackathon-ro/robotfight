#import "ViewController.h"
#import "SocialNetwork.h"


@implementation ViewController
@synthesize textField;

NSString *url = @"10.10.2.97";
// ----------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	[textField setReturnKeyType: UIReturnKeyDone];
	[self.navigationController.navigationBar setHidden: YES];
	
	
	
}
// ----------------------------------------------------------------------------------------------
-(void) checkNetworkStatus:(NSNotification *)notice
{
	}



// ----------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [textField resignFirstResponder];
    return YES;
}
// ----------------------------------------------------------------------------
- (IBAction)GetStarted:(id)sender {
	
	NSString *username = textField.text;
	NSLog(@"Pressed get started");
	
	if(username == NULL || [username isEqual: @""])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not so fast!" message:@"Please enter your username" delegate: self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
	}
	else
	{
		NSLog(@"%@", username);
		NSString* regex = @"^[a-zA-Z0-9]*$";
        NSPredicate* valtest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        int ret = [valtest evaluateWithObject:username];
        
		if (!ret)
        {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Wait a second!" message:@"Invalid username. Try again!" delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alertView show];
			[textField setText: @""];
        }
		
		else
		{
			
			NSError *error = nil;
			NSDictionary *information = [NSDictionary dictionaryWithObjectsAndKeys: username, @"username", nil];
			
			NSData* jsonData = [NSJSONSerialization dataWithJSONObject: information
															   options:NSJSONWritingPrettyPrinted
																 error:&error];
			
			
			NSString *text = [[NSString alloc] initWithData:jsonData
												   encoding:NSUTF8StringEncoding];
			NSLog(@"Json to server: %@", text);
			
			NSMutableURLRequest *theRequest=[ NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://10.10.2.97/login"] cachePolicy:NSURLRequestUseProtocolCachePolicy
																 timeoutInterval:0.5 ];
			
			[theRequest setHTTPMethod: @"POST"];
			[theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
			[theRequest setValue:[NSString stringWithFormat:@"%d",[jsonData length]] forHTTPHeaderField:@"Content-Length"];
			
			[theRequest setHTTPBody:jsonData];
			if(serverInfo)
			{
				[serverInfo release];
				serverInfo = nil;
			}
			serverInfo = [[[NSMutableData alloc] init] retain];
			NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
			if(theConnection)
			{
				// connection succeeded
				
			}
			else
			{
				// connection failed
			}
			

			SocialNetwork *socialNetwork = [[SocialNetwork alloc] init];
			[self.navigationController pushViewController: socialNetwork animated: YES];
		}
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
	[serverInfo appendData:data];
}
// ----------------------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"ASf");
    NSError *error;
	
	NSLog(@"Server info %@", serverInfo);
	
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:serverInfo options:kNilOptions error:&error];
	
	NSLog(@"%@", json);
	
    NSString *username = [json objectForKey:@"username"];
	NSString *losses = [json objectForKey:@"losses"];
	NSString *wins = [json objectForKey:@"wins"];
	NSString *token = [json objectForKey:@"token"];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:username forKey:@"username"];
	[userDefaults setObject: wins forKey:@"wins"];
	[userDefaults setObject: losses forKey:@"losses"];
	[userDefaults setObject: token forKey:@"token"];
    
    
	
}
// ----------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
// ----------------------------------------------------------------------------
- (void)dealloc
{
	[textField release];
	[super dealloc];
}
@end
