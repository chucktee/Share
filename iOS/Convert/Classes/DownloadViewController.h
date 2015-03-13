//
//  DownloadViewController.h
//  Convert
//
//  Created by Chuck Toussieng on 7/15/08.
//  Copyright 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateRecord.h"

@interface DownloadViewController : UIViewController {
    
	IBOutlet UINavigationItem	*navBarTitle;
	
	IBOutlet UILabel			*labelRatesInDatabaseTitle;
	IBOutlet UILabel			*labellastUpdateTitle;
	
    IBOutlet UILabel			*labelRatesInDatabase;
	IBOutlet UILabel			*labellastUpdate;
	IBOutlet UILabel			*labelActivity;
	IBOutlet UIProgressView		*processXMLBar;
	
	BOOL  firstUpdate;
	float progressValue;
}

@property (nonatomic, retain) UILabel *labelActivity;

- (void)showAlert:(NSString*)title;
- (void)setProgressBar:(NSNotification *)aNotification;
-(void)updateProgressBar:(NSNumber *)newValue;
+ (DownloadViewController *)sharedInstance;

@end