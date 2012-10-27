//
//  AsyncImageView.h
//  nomytho
//
//  Created by Jérémy ROGER on 01/05/11.
//  Copyright 2011 JEREMY ROGER. All rights reserved.
//


#import <UIKit/UIKit.h>

@class AsyncImageView;

@protocol AsyncImageViewDelegate <NSObject>

- (void) imageViewDidFinishLoading:(AsyncImageView *) image;

@end

@interface AsyncImageView : UIImageView <NSURLConnectionDelegate> 
{
    NSURLConnection         *connection;
    NSMutableData           *data;
	NSString				*filepath;
	BOOL					loaded;
}

@property (nonatomic, readonly) BOOL loaded;
@property (nonatomic , assign) id <AsyncImageViewDelegate> delegate;

- (void)loadImageFromURL:(NSURL*)url SavePath:(NSString *) pathToSaveTo;
- (void)loadImageFromURL:(NSURL*)url;

@end
