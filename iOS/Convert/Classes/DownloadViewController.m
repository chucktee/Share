//
//  DownloadViewController.m
//  Convert
//
//  Created by Chuck Toussieng on 7/15/08.
//  Copyright Chuck Toussieng 2008. All rights reserved.
//

#import "ConvertAppDelegate.h"
#import "DownloadViewController.h"
#import "RateRecord.h"


// This is a singleton class, see below
static DownloadViewController *sharedDLDelegate = nil;

@implementation DownloadViewController

@synthesize labelActivity;

//------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	NSLog(@"INIT DownloadViewController");
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
	}
	return self;
	
}

// Called when the view is loading for the first time only
// If you want to do something every time the view appears, use viewWillAppear or viewDidAppear
- (void)viewDidLoad {
	NSLog(@"viewDidLoad DownloadViewController");
}

- (void)viewWillAppear:(BOOL)animated {
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setProgressBar:) name:@"ARateWasDownloaded" object:nil];
	
	//Setup Shop
	navBarTitle.title = NSLocalizedString(@"Download Rates",@"Download Rates");
	labelRatesInDatabaseTitle.text = NSLocalizedString(@"Rates in Database",@"Rates in Database");
	labellastUpdateTitle.text = NSLocalizedString(@"Last Update",@"Last Update");
	
	firstUpdate = YES;
	ConvertAppDelegate *appDelegate = (ConvertAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		
	NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[NSUserDefaults standardUserDefaults] floatForKey:@"kLastDownloadKey"]] ];
	
	//Hide Stuff
	labelActivity.hidden = true;
    processXMLBar.hidden = true;
	
	//Update the screen
	labelRatesInDatabase.text = [NSString stringWithFormat:@"%i", [appDelegate countOfRates]];
	labellastUpdate.text = [NSString stringWithFormat:@"%@",formattedDateString];
	
	[self showAlert:formattedDateString];	
	
	processXMLBar.progress = 0.75;
}

//--------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ARateWasDownloaded" object:nil];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) showAlert:(NSString*)szDate {
	
	NSString *format  = NSLocalizedString(@"AskToDownload", nil);
	NSString *message = [NSString stringWithFormat:format, szDate]; 
	
    UIAlertView* alertView = [[UIAlertView alloc] 
							  initWithTitle:NSLocalizedString(@"Rates",@"Rates") 
							  message:message
							  delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") otherButtonTitles:NSLocalizedString(@"Update",@"Update"),nil];
    [alertView show];
    [alertView release];
}


//------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	ConvertAppDelegate *appDelegate = (ConvertAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(buttonIndex == 1) {
		labelActivity.hidden = NO;
		processXMLBar.hidden = NO;
		progressValue = 0.0f;
		processXMLBar.progress = progressValue;
		
		labelActivity.text = NSLocalizedString(@"Downloading",@"Downloading");
		[appDelegate initGetCurrencyData];
	} else {
		appDelegate.tabBarController.selectedIndex = 0;
	}

}


//------------------------------------------------------------------------------------
- (void)dealloc {
	[labelActivity release];
	[super dealloc];
}

//--------------------------------------------------------------------
-(void) setProgressBar:(NSNotification *)aNotification {
	
	progressValue++;

	[self performSelectorOnMainThread:@selector(updateProgressBar:) 
						withObject:[NSNumber numberWithFloat:progressValue / 76]
						waitUntilDone:NO];
}
//--------------------------------------------------------------------
-(void)updateProgressBar:(NSNumber *)newValue {
	
	processXMLBar.progress = [newValue floatValue];

}

//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
#pragma mark ---- singleton object methods ----

+ (DownloadViewController *)sharedInstance {
    @synchronized(self) {
        if (sharedDLDelegate == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedDLDelegate;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedDLDelegate == nil) {
            sharedDLDelegate = [super allocWithZone:zone];
            return sharedDLDelegate;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}


@end
