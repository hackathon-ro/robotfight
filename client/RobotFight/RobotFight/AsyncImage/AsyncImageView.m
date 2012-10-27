//
//  AsyncImageView.m
//  nomytho
//
//  Created by Jérémy ROGER on 01/05/11.
//  Copyright 2011 JEREMY ROGER. All rights reserved.
//


#import "AsyncImageView.h"
#import "Defines.h"
#import "AppDelegate.h"

@implementation AsyncImageView

@synthesize loaded;
@synthesize delegate;

//****************************************************************************************************
- (id) init
{
	if((self = [super init]))
		loaded = FALSE;
	
	return self;
}
//****************************************************************************************************
- (void)loadImageFromURL:(NSURL*)url SavePath:(NSString *) pathToSaveTo
{
	if(!url)
		return;
	
	[self performSelectorOnMainThread:@selector(loadImageFromURL:) withObject:url waitUntilDone:FALSE];
}
//****************************************************************************************************
- (void)loadImageFromURL:(NSURL*)url 
{	
    if(!url)
        return;
	
	NSString *imageName = [[url absoluteString] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",imageGeneratorServer] withString:@""];
	
	filepath = [[NSString stringWithFormat:@"%@",[AppDelegate libraryDataFilePath:imageName]] retain];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager createDirectoryAtPath:[filepath stringByDeletingLastPathComponent] withIntermediateDirectories:TRUE attributes:nil error:nil];
	
	if([fileManager fileExistsAtPath:filepath])
	{
		[self setImage:[UIImage imageWithContentsOfFile:filepath]];
		loaded = TRUE;
		
		if(self.delegate)
			if([self.delegate respondsToSelector:@selector(imageViewDidFinishLoading:)])
				[self.delegate imageViewDidFinishLoading:self];
		
		[filepath release];
		filepath = nil;
		return;
	}
	
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
        
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) 
    {
        data = [[NSMutableData data] retain];
    }
}
//*************************************************************************************************************************************
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData
{
    [data appendData:incrementalData];
}
//*************************************************************************************************************************************
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection 
{
    if(connection)
    {
        [connection release];
        connection = nil;
    }

	UIImage *temp = [UIImage imageWithData:data];
	if(temp)
	{
		self.image = temp;
		self.backgroundColor = [UIColor clearColor];
		[self setClipsToBounds:YES];
		[self setNeedsLayout];

		if(filepath)
		{
			BOOL success = [data writeToFile:filepath atomically:YES];
			if(!success)
			{
				NSLog(@"did not suck seed");

				NSFileManager *fm = [NSFileManager defaultManager];
				[fm removeItemAtURL:[NSURL fileURLWithPath:filepath] error:nil];
			}
			[filepath release];
			filepath = nil;
		}

		loaded = TRUE;
		if(self.delegate && [self.delegate respondsToSelector:@selector(imageViewDidFinishLoading:)] &&
		  ([self.delegate isKindOfClass:[UIView class]] || [self.delegate isKindOfClass:[UIViewController class]]))
			[self.delegate imageViewDidFinishLoading:self];
	}
    if(data)
    {
        [data release];
        data = nil;
    }
}
//*************************************************************************************************************************************
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{

}
//*************************************************************************************************************************************
- (void)dealloc 
{
	delegate = nil;

    if(connection)
    {
        [connection cancel];
        [connection release];
    }
    if(data)
        [data release];
	
	filepath	= nil;
    connection  = nil;
    data        = nil;
    
    [super      dealloc];
}
//*************************************************************************************************************************************
@end