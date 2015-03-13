#import "SettingsViewController.h"
#import "ConvertAppDelegate.h"
#import "RateRecord.h"

@implementation SettingsViewController

@synthesize fromPicker;
@synthesize toPicker, masterPicker;


#pragma mark ---- View methods ----
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

	}
	return self;
}

- (void)viewDidLoad {
	
	//Show button states
	switchAutoDownload.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAutoUpdateKey"];
	
	appDelegate = (ConvertAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[selectPickerButtons setTitle:NSLocalizedString(@"Convert From",@"Convert From") forSegmentAtIndex:0];
	[selectPickerButtons setTitle:NSLocalizedString(@"Convert To",@"Convert To") forSegmentAtIndex:1];
	[selectPickerButtons setTitle:NSLocalizedString(@"Master",@"Master") forSegmentAtIndex:2];
}

//-------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
	
	navBarTitle.title = NSLocalizedString(@"Settings",@"Settings");
	
	labelCheckToDownload.text = NSLocalizedString(@"Check for new rates","Check for new rates");
	
	// start by showing the from picker
	selectPickerButtons.selectedSegmentIndex = 0.0;
	settingFromCurrency = YES;
	
	transformArrow = CGAffineTransformMakeTranslation (0.0, 0.0);
	imageArrow.transform = transformArrow;
	
	transformFrom = CGAffineTransformMakeTranslation (0.0, 0.0);
	fromPicker.transform = transformFrom;	
	
	transformTo = CGAffineTransformMakeTranslation (480.0, 0.0);
	toPicker.transform = transformTo;

	transformMaster = CGAffineTransformMakeTranslation (480.0, 0.0);
	masterPicker.transform = transformMaster;	
	
	[fromPicker reloadComponent:0];
	[fromPicker selectRow:appDelegate.intFromPosition inComponent:0 animated:YES];
	fromPickerRow = appDelegate.intFromPosition;
	
	[toPicker reloadComponent:0];
	[toPicker selectRow:appDelegate.intToPosition inComponent:0 animated:YES];
	toPickerRow = appDelegate.intToPosition;
	
	[masterPicker reloadComponent:0];
	[masterPicker selectRow:appDelegate.intMasterPosition inComponent:0 animated:YES];
	masterPickerRow = appDelegate.intMasterPosition;
}


//-------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
	
	[appDelegate setFromPos:fromPickerRow];
	
	[appDelegate setToPos:toPickerRow];	
	
	[appDelegate setMasterPos:masterPickerRow];
	
	[appDelegate saveUserSettings];
	
}

//-------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait); // Portrait mode only
}


//-------------------------------------------------
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


#pragma mark ---- UIPickerViewDataSource delegate methods ----

// returns the number of columns to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

// returns the number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return appDelegate.countOfRates;
}

#pragma mark ---- UIPickerViewDelegate delegate methods ----

// returns the title of each row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	NSString *pickerText;
	
	// Set the cell's text, etc.
	pickerText = [NSString stringWithFormat:@"%@ %@",[appDelegate makeSymbolsForCurrency:row], [[appDelegate objectInRatesAtIndex:row] currencyDesc] ];
	
	return pickerText;
}

//----------------------------------------------------------
// gets called when the user settles on a row
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	//Which picker was it?
	switch (selectPickerButtons.selectedSegmentIndex)
	{
		case 0:  //From
			fromPickerRow = row;
			break;
		case 1: //To
			toPickerRow = row;
			break;
		case 2: //Master
			masterPickerRow = row;
		break;
	}

}

#pragma mark ---- Other control callbacks ----

- (IBAction)switchedAutoDownload {
	
	if ( switchAutoDownload.on ) {
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"kAutoUpdateKey"];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"kAutoUpdateKey"];
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
		
}

- (IBAction)switchedIgnoreDeleted {
	
}

//-----------------------------------------------------------------------
- (IBAction)changePickers {
	
	settingFromCurrency = NO;
	settingToCurrency = NO;
	settingMasterCurrency = NO;
	
	switch (selectPickerButtons.selectedSegmentIndex)
	{
			
		case 0:  //From
			settingFromCurrency = YES;
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			
			transformArrow = CGAffineTransformMakeTranslation (0.0, 0.0);
			imageArrow.transform = transformArrow;
			
			transformTo = CGAffineTransformMakeTranslation (480.0, 0.0);
			toPicker.transform = transformTo;
			transformMaster = CGAffineTransformMakeTranslation (480.0, 0.0);
			masterPicker.transform = transformMaster;
			
			transformFrom = CGAffineTransformMakeTranslation (0.0, 0.0);
			fromPicker.transform = transformFrom;
			[UIView commitAnimations];
			break;
			
		case 1:  //To
			settingToCurrency = YES;
			[toPicker reloadComponent:0];
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			transformArrow = CGAffineTransformMakeTranslation (104.0, 0.0);
			imageArrow.transform = transformArrow;
			
			transformFrom = CGAffineTransformMakeTranslation (-480.0, 0.0);
			fromPicker.transform = transformFrom;
			transformMaster = CGAffineTransformMakeTranslation (480.0, 0.0);
			masterPicker.transform = transformMaster;
			
			transformTo = CGAffineTransformMakeTranslation (0.0, 0.0);
			toPicker.transform = transformTo;
			[UIView commitAnimations];
			break;
			
		case 2:  //Master
			settingMasterCurrency = YES;
			[masterPicker reloadComponent:0];
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			transformArrow = CGAffineTransformMakeTranslation (211.0, 0.0);
			imageArrow.transform = transformArrow;
			
			transformTo = CGAffineTransformMakeTranslation (-480.0, 0.0);
			toPicker.transform = transformTo;
			transformFrom = CGAffineTransformMakeTranslation (-480.0, 0.0);
			fromPicker.transform = transformFrom;
			
			transformMaster = CGAffineTransformMakeTranslation (0.0, 0.0);
			masterPicker.transform = transformMaster;
			[UIView commitAnimations];
			break;	
	}
}


- (void)dealloc {
	[fromPicker release];
	[toPicker release];
	[super dealloc];
}


@end
