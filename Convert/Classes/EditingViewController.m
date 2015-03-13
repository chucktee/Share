#import "ConvertAppDelegate.h"
#import "EditingViewController.h"

@implementation EditingViewController

@synthesize delegate, typeOfEdit;


//-----------------------------------------------------------------------
- (void)viewDidLoad {

	[super viewDidLoad];
	
	textCurrencyDescription.delegate = self;
	textCurrencyRate.delegate = self;
	textCurrencyCode.delegate = self;
	textCurrencySymbol.delegate = self;

	appDelegate = (ConvertAppDelegate *)[[UIApplication sharedApplication] delegate];
}


//-----------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
	
	// Labels
	navTitle.title = NSLocalizedString(@"Edit Rate",@"Edit Rate");
	buttonSave.title = NSLocalizedString(@"Save",@"Save");
	buttonCancel.title = NSLocalizedString(@"Cancel",@"Cancel");
	labelCurrencyDescription.text = NSLocalizedString(@"Currency Description",@"Currency Description"); 
	labelCurrencyRate.text = NSLocalizedString(@"Currency Rate to U.S. Dollar",@"Currency Rate to U.S. Dollar"); 
	labelCurrencyCode.text = NSLocalizedString(@"3 Letter Currency Code",@"3 Letter Currency Code"); 
	labelCurrencySymbol.text = NSLocalizedString(@"Currency Symbol (ASCII)",@"Currency Symbol (ASCII)"); 
	
	switch (typeOfEdit) {
		case 1:  // Edit internal rate
			// Fields
			textCurrencyDescription.text = appDelegate.workingCurrency.currencyDesc;
			textCurrencyRate.text = [appDelegate setToLocalCurrencyFormat:[NSString stringWithFormat:@"%0.4f",[appDelegate.workingCurrency.rateValue floatValue]] asRate:YES];
			textCurrencyCode.text = appDelegate.workingCurrency.currencyCode;
			textCurrencySymbol.text = appDelegate.workingCurrency.symbolCodes;
			labelCurrencySymbolRepresentation.text = [NSString stringWithFormat:@"%@",[appDelegate makeSymbolsForCurrencyWithThisString:appDelegate.workingCurrency.symbolCodes]];
			
			imageFlag.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",appDelegate.workingCurrency.currencyCode]];
			textCurrencyDescription.enabled = NO;
			textCurrencyDescription.textColor = [UIColor grayColor];
			textCurrencyCode.enabled = NO;
			textCurrencyCode.textColor = [UIColor grayColor];
			textCurrencySymbol.enabled = NO;
			textCurrencySymbol.textColor = [UIColor grayColor];
			break;
		case 2:  // Edit user custom rate
			navTitle.title = NSLocalizedString(@"Edit User Currency",@"Edit User Currency");
			
			// Fields
			textCurrencyDescription.text = appDelegate.workingCurrency.currencyDesc;
			textCurrencyRate.text = [appDelegate setToLocalCurrencyFormat:[NSString stringWithFormat:@"%0.4f",[appDelegate.workingCurrency.rateValue floatValue]] asRate:YES];
			textCurrencyCode.text = appDelegate.workingCurrency.currencyCode;
			textCurrencySymbol.text = appDelegate.workingCurrency.symbolCodes;
			labelCurrencySymbolRepresentation.text = [NSString stringWithFormat:@"%@",[appDelegate makeSymbolsForCurrencyWithThisString:appDelegate.workingCurrency.symbolCodes]];
			imageFlag.image = [UIImage imageNamed:@"custom.png"];
			break;
		case 3:  // Adding New Rate
			navTitle.title = NSLocalizedString(@"Add Currency",@"Add Currency");
			textCurrencyDescription.text = @"";
			textCurrencyRate.text = @"";
			textCurrencyCode.text = @"";
			textCurrencySymbol.text = @"";
			labelCurrencySymbolRepresentation.text = @"";
			imageFlag.image = [UIImage imageNamed:@"custom.png"];
			break;	
		default:
			break;
	}
	
}

//-----------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {

		
}



//-----------------------------------------------------------------------
- (IBAction)cancel:(id)sender {

    [self.delegate editingViewControllerDidFinish:self];
}


//-----------------------------------------------------------------------
- (IBAction)save:(id)sender {
	
	NSNumber *aNumber = nil;
	
	//WAIT!! Let's check if we need to quick change the value to save into the database
	//into our native storage decimal
	
	//Quick, if the local seperator is a comma, replace it with a decimal for storage
	if ( [appDelegate.localSeperator isEqualToString:@","] ) {
		
		NSMutableString *workingString = [[NSMutableString alloc] initWithString:textCurrencyRate.text];
		
		//First from the left remove the decimals
		[workingString replaceOccurrencesOfString:@"." withString:@"" options:0 range:NSMakeRange(0, [workingString length])];
		
		// Now replace the decimal holder
		[workingString replaceOccurrencesOfString:@"," withString:@"." options:0 range:NSMakeRange(0, [workingString length])];
		//Now, use this value and continue
		aNumber = [NSNumber numberWithFloat:[workingString floatValue]];
		
		[workingString release];
		
	} else {
		aNumber = [NSNumber numberWithFloat:[textCurrencyRate.text floatValue]];
	}
	
    // save edits but do we have a zero?
	if([aNumber floatValue] == 0.0f || [textCurrencyRate.text length] == 0) {
		NSString *aMessage;
		aMessage = NSLocalizedString(@"You cannot save a currency with a conversion rate of zero.",@"You cannot save a currency with a conversion rate of zero.");
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",@"Alert")
															message:aMessage 
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"OK",@"OK") 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	
		return;
	}
	
	if(typeOfEdit == 2 || typeOfEdit == 3) {
		if ([textCurrencyCode.text length] != 0) {
			if ([appDelegate checkUserCode:textCurrencyCode.text] == NO) {
				
				NSString *format  = NSLocalizedString(@"ChangeCurrencyCode", nil);
				NSString *message = [NSString stringWithFormat:format, textCurrencyCode.text]; 
				UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",@"Alert")
																	message:message 
																   delegate:self 
														  cancelButtonTitle:NSLocalizedString(@"OK",@"OK") 
														  otherButtonTitles:nil];
				[alertView show];
				[alertView release];
				return;
			}
		}
	}
	
	//Good to go

	appDelegate.workingCurrency.rateValue = aNumber;
	
	switch (typeOfEdit) {
		case 1:  // Edit internal rate
			// Fields handeled above for the only option
			[appDelegate saveBackDatabase];
			break;
		case 2:  // Edit user custom rate
			// Fields
			if ([textCurrencyDescription.text length] == 0) {
				textCurrencyDescription.text = @"";
			}
			if ([textCurrencyCode.text length] == 0) {
				textCurrencyCode.text = @"";
			}
			if ([textCurrencySymbol.text length] == 0) {
				textCurrencySymbol.text = @"";
			}
			appDelegate.workingCurrency.currencyDesc = textCurrencyDescription.text;
			appDelegate.workingCurrency.currencyCode = textCurrencyCode.text;
			appDelegate.workingCurrency.symbolCodes = textCurrencySymbol.text;
				
			[appDelegate saveBackDatabase];
			break;
		case 3:  // Adding New Rate
			// Fields
			appDelegate.workingCurrency.currencyDesc = textCurrencyDescription.text;
			appDelegate.workingCurrency.currencyCode = textCurrencyCode.text;
			appDelegate.workingCurrency.symbolCodes = textCurrencySymbol.text;
			
			[appDelegate insertNewWorkingCurrency];
			break;	
		default:
			break;
	}
	
	[self.delegate editingViewControllerDidFinish:self];

}


//-----------------------------------------------------------------------
- (void)dealloc {

	[super dealloc];
}


#pragma mark text field delegates
//---------------------------------------------------------------------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)inTextField
{
	
	if( inTextField == textCurrencyRate)
		inTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	else
		inTextField.keyboardType = UIKeyboardTypeDefault;
	
	if( inTextField == textCurrencyCode) {
		[self moveUpView:YES howMuch:40];
	}
	
	if( inTextField == textCurrencySymbol) {
		[self moveUpView:YES howMuch:100];
	}

	return YES;
}


//---------------------------------------------------------------------------------
- (BOOL) textFieldShouldReturn: (UITextField *)inTextField
{	
	if( inTextField == textCurrencyCode)
		[self moveUpView:NO howMuch:40];
	
	if( inTextField == textCurrencySymbol)
		[self moveUpView:NO howMuch:100];
	
	if( inTextField == textCurrencySymbol )
	   labelCurrencySymbolRepresentation.text = [NSString stringWithFormat:@"%@",[appDelegate makeSymbolsForCurrencyWithThisString:textCurrencySymbol.text]];
	
	[inTextField resignFirstResponder];
	return YES;
}


//---------------------------------------------------------------------------------
- (void) moveUpView:(BOOL)movingUp howMuch:(float)howMuch {

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	
	if (movingUp) {
		sliderView.frame = CGRectMake(sliderView.frame.origin.x, sliderView.frame.origin.y - howMuch, sliderView.frame.size.width, sliderView.frame.size.height); 
	} else {
		sliderView.frame = CGRectMake(sliderView.frame.origin.x, 44, sliderView.frame.size.width, sliderView.frame.size.height);
	}

	[UIView commitAnimations];
}

@end

