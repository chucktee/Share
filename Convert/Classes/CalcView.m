//
//  CalcView.m
//  Convert
//
//  Created by Chuck Toussieng on 7/15/08.
//  Copyright Chuck Toussieng 2008. All rights reserved.
//

#import "ConvertAppDelegate.h"
#import "CalcView.h"
#import "RateRecord.h"


@implementation CalcView

//-----------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	NSLog(@"INIT CalcView");
	
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
	}
	return self;
	
}

//-----------------------------------------------------fires only on initial load
- (void)viewDidLoad {
	
	NSLog(@"viewDidLoad CalcView");
	navTitle.title = NSLocalizedString(@"Chuck's Currency Converter",@"Chuck's Currency Converter");
	textFromAmount.placeholder = NSLocalizedString(@"enter amount on keypad",@"enter amount on keypad");
	appDelegate = (ConvertAppDelegate *)[[UIApplication sharedApplication] delegate];
}

//-----------------------------------------------------fires everytime
- (void)viewWillAppear:(BOOL)animated {
	
	//Setup Shop
	[textFromAmount setFont:[UIFont systemFontOfSize:20]];
	[textConvertedAnswer setFont:[UIFont systemFontOfSize:20]];
	[lblLongFromDesc setFont:[UIFont systemFontOfSize:14]];
	[lblLongToDesc setFont:[UIFont systemFontOfSize:14]];
	
	inTheDecimal = NO;
	decimalPos   = 0;
	
	[self prepToAndFromLabels];
}

//----------------------------
- (void)prepToAndFromLabels {
	
	//Set From Currency
	lblMaster.text = appDelegate.fromCurrency.currencyCode;
	lblLongFromDesc.text = appDelegate.fromCurrency.currencyDesc;

	//Set To Currency
	lblConvertTo.text = appDelegate.toCurrency.currencyCode;
	lblLongToDesc.text = appDelegate.toCurrency.currencyDesc;
	
	//Set Flags
	imageFromFlag.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",appDelegate.fromCurrency.currencyCode]];
	imageToFlag.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",appDelegate.toCurrency.currencyCode]];
	
	textFromAmount.text = @"";
	textHiddenFromAmount.text = @"";
	textConvertedAnswer.text = @"";	
}


/************************************
 Calculator button Actions
 ***********************************/
- (IBAction)clicked7 {
	NSString *newAmount = @"7";
	[self addAChar:newAmount];
}
- (IBAction)clicked8 {
	NSString *newAmount = @"8";
	[self addAChar:newAmount];
}
- (IBAction)clicked9 {
	NSString *newAmount = @"9";
	[self addAChar:newAmount];
}
- (IBAction)clicked4 {
	NSString *newAmount = @"4";
	[self addAChar:newAmount];
}
- (IBAction)clicked5 {
	NSString *newAmount = @"5";
	[self addAChar:newAmount];
}
- (IBAction)clicked6 {
	NSString *newAmount = @"6";
	[self addAChar:newAmount];
}
- (IBAction)clicked1 {
	NSString *newAmount = @"1";
	[self addAChar:newAmount];
}
- (IBAction)clicked2 {
	NSString *newAmount = @"2";
	[self addAChar:newAmount];
}
- (IBAction)clicked3 {
	NSString *newAmount = @"3";
	[self addAChar:newAmount];
}
- (IBAction)clicked0 {
	NSString *newAmount = @"0";
	[self addAChar:newAmount];
}

//Traps too many digits after decimal point
//STAY IN DECIMAL- convert for display only
- (IBAction)clickedDecimal {
	NSString *newAmount = nil;
	
	if (inTheDecimal == NO) {
		inTheDecimal = YES;
		newAmount    =  @".00";
		textHiddenFromAmount.text = [textHiddenFromAmount.text stringByAppendingString:newAmount];
	}
}

- (IBAction)clickedChangeMaster {
	[self showFromInformation];
}
- (IBAction)clickedChangeCnvTo {
	[self showToInformation];
}

- (IBAction)clickedClear {
	textFromAmount.text = @"";
	textHiddenFromAmount.text = @"";
	textConvertedAnswer.text = @"";
	inTheDecimal = NO;
	decimalPos = 0;
}

//Little special flip flop
- (IBAction)clickedFlipFlop {
	
	NSInteger intHolder;
	
	//Trap empty from amount
	if ([textHiddenFromAmount.text length] == 0) {
		textHiddenFromAmount.text = @"1";
	}
	
	intHolder = [appDelegate intFromPosition];
	[appDelegate setFromPos:[appDelegate intToPosition]];
	[appDelegate setToPos:intHolder];
	
	lblMaster.text = appDelegate.fromCurrency.currencyCode;
	lblLongFromDesc.text = appDelegate.fromCurrency.currencyDesc;
	
	//Set To Currency
	lblConvertTo.text = appDelegate.toCurrency.currencyCode;
	lblLongToDesc.text = appDelegate.toCurrency.currencyDesc;
	
	//Set Flags
	imageFromFlag.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",appDelegate.fromCurrency.currencyCode]];
	imageToFlag.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",appDelegate.toCurrency.currencyCode]];
	
	//Going to clear
	textFromAmount.text = @"";
	[self checkIfSymbolIsShowing];

	//Fill it back in
	textFromAmount.text = [NSString stringWithFormat:@"%@ %@",[appDelegate makeSymbolsForCurrency:[appDelegate intFromPosition]], [appDelegate setToLocalCurrencyFormat:textHiddenFromAmount.text asRate:NO]];

	//Continue
	[self calculateAnswer];
}

/************************************
 End Calculator button Actions
 ***********************************/

//Encapsulates all button press duplicate actions

-(void) checkIfSymbolIsShowing { 

	if([[textFromAmount text] length] == 0) 
		textFromAmount.text = [appDelegate makeSymbolsForCurrency:[appDelegate intFromPosition]];
}
							   
//---------START of display updates for From Field
- (void)addAChar:(NSString *)aString {
	
	NSString *addOn = nil;
	
	if (inTheDecimal == YES && decimalPos > 1)
		return;
		
	if (inTheDecimal == YES && decimalPos <= 1) {
		decimalPos++;
		
		if (decimalPos==1) {
			//Chop 2 (zeros)
			textHiddenFromAmount.text = [textHiddenFromAmount.text substringWithRange:NSMakeRange(0,[textHiddenFromAmount.text length]-2)];
			//Add 2
			addOn = [NSString stringWithFormat:@"%@0",aString];
		} else {
			//Chop 1 (zero)
			textHiddenFromAmount.text = [textHiddenFromAmount.text substringWithRange:NSMakeRange(0,[textHiddenFromAmount.text length]-1)];
			//Add 1, below
			addOn = aString;
		}
		textHiddenFromAmount.text = [textHiddenFromAmount.text stringByAppendingString:addOn];
	} else {
		textHiddenFromAmount.text = [textHiddenFromAmount.text stringByAppendingString:aString];
	}

	// Continue on..
	textFromAmount.text = [NSString stringWithFormat:@"%@ %@",[appDelegate makeSymbolsForCurrency:[appDelegate intFromPosition]], 
						   [appDelegate setToLocalCurrencyFormat:textHiddenFromAmount.text asRate:NO]];

	[self calculateAnswer];

}

//---------END of display updates for From Field




//---------------------------------
// The heart of the beast
//---------------------------------
- (void)calculateAnswer {
	
	float answer = 0;

	//Clear
	textConvertedAnswer.text = @"";
	
	//Everything is as related to US Dollars, so here is the formula casting out the 1s and cross multiplying
	answer = ( [textHiddenFromAmount.text floatValue] / [appDelegate.fromCurrency.rateValue floatValue] ) * [appDelegate.toCurrency.rateValue floatValue];
	
	//Show the final answer
	//Symbol first
	textConvertedAnswer.text = [appDelegate makeSymbolsForCurrency:[appDelegate intToPosition]];
	
	//Need a string-
	NSString *answerString = [NSString stringWithFormat:@"%0.2f",answer];
	
	textConvertedAnswer.text = [textConvertedAnswer.text stringByAppendingString:[appDelegate setToLocalCurrencyFormat:answerString asRate:NO]];

}
//---------------------------------
// End The heart of the beast
//---------------------------------


//--Start Popup Information
- (void) showFromInformation {

	float answer;
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[NSUserDefaults standardUserDefaults] floatForKey:@"kLastDownloadKey"]] ];
	
	answer = (( 2 / [appDelegate.fromCurrency.rateValue floatValue] ) * [appDelegate.toCurrency.rateValue floatValue] / 2 );
	
	NSString *answerString = [NSString stringWithFormat:@"%0.2f",answer];
	

	NSString *format  = NSLocalizedString(@"ConvertingFromInformation", nil);
	NSString *message = [NSString stringWithFormat:format, 
						 appDelegate.fromCurrency.currencyDesc, 
						 [appDelegate setToLocalCurrencyFormat:answerString asRate:NO], 
						 appDelegate.toCurrency.currencyDesc, 
						 formattedDateString]; 
	
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"From Currency",@"From Currency") 
														message:message 
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"OK",@"OK")
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

//--Popup
- (void) showToInformation {
	
	float answer;
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[NSUserDefaults standardUserDefaults] floatForKey:@"kLastDownloadKey"]] ];
	
	answer = (( 2 / [appDelegate.toCurrency.rateValue floatValue] ) * [appDelegate.fromCurrency.rateValue floatValue] / 2 );
	
	NSString *answerString = [NSString stringWithFormat:@"%0.2f",answer];
	
	NSString *format  = NSLocalizedString(@"ConvertingToInformation", nil);
	NSString *message = [NSString stringWithFormat:format, 
						 appDelegate.toCurrency.currencyDesc, 
						 [appDelegate setToLocalCurrencyFormat:answerString asRate:NO], 
						 appDelegate.fromCurrency.currencyDesc, 
						 formattedDateString]; 
	
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"To Currency",@"To Currency") 
														message:message 
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"OK",@"OK") 
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

-(void)dealloc {
	[super dealloc];
}

@end
