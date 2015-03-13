//
//  ConvertAppDelegate.m
//  Convert
//
//  Created by Chuck Toussieng on 7/15/08.
//  Copyright 2008. All rights reserved.
//
#import "ConvertAppDelegate.h"
#import "CurrencyStruct.h"
#import "CalcView.h"
#import "DownloadViewController.h"
#import "CTDatabase.h"

NSString *kFromCurrencyKey   = @"fromCurrency";
NSString *kToCurrencyKey     = @"toCurrency";
NSString *kMasterCurrencyKey = @"masterCurrency";
NSString *kLastDownloadKey   = @"lastDownload";
NSString *kAutoUpdateKey     = @"autoUpdate";
NSString *kCalcLocationKey   = @"calclocation";
NSString *kIgnoreDeletedKey  = @"ignoreDeleted";


@implementation ConvertAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize rates;
@synthesize XMLlist;
@synthesize fromCurrency, toCurrency, masterCurrency, workingCurrency;
@synthesize lastUpdate;
@synthesize intFromPosition, intToPosition, intMasterPosition;
@synthesize intFromRecord, intToRecord, intMasterRecord;
@synthesize database;
@synthesize results;
@synthesize localSeperator,localCurrency;

//--Initializing here NOT in awake or App Finished Loading
//--Otherwise info needed by NIBs isn't available until too late
- (id)init {
	
    if(self = [super init]) {
		
		[self getUserSettingsDefaults];
		
		//Setup Shop
		[self createEditableCopyOfDatabaseIfNeeded];
		
		//Setup local info
		NSNumberFormatter *fmtrCurrencyFromStr = nil;
		
		fmtrCurrencyFromStr = [[NSNumberFormatter alloc] init];
		[fmtrCurrencyFromStr setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[fmtrCurrencyFromStr setLocale:[NSLocale currentLocale]];
		[fmtrCurrencyFromStr setNumberStyle:NSNumberFormatterCurrencyStyle];
		[fmtrCurrencyFromStr setGeneratesDecimalNumbers:YES];
		
		self.localSeperator = [fmtrCurrencyFromStr decimalSeparator]; //prints a comma
		self.localCurrency  = [fmtrCurrencyFromStr currencyCode]; //prints EUR
				
		//Auto update rates?
		timeToUpdate = NO;
		NSDate *today = [NSDate date];
		NSDate *lastDownload = [NSDate dateWithTimeIntervalSince1970:[[NSUserDefaults standardUserDefaults] floatForKey:@"kLastDownloadKey"]];
		NSTimeInterval timeElapsed = [today timeIntervalSinceDate:lastDownload];
		
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"kAutoUpdateKey"]) {
			if( timeElapsed >= 43200 ) {
				//More than 12 hours since last download- so...
				timeToUpdate = YES;
			}
		}
		
		//if([[NSUserDefaults standardUserDefaults] boolForKey:@"kCalcLocationKey"]) {
			//Calculate location
		//}
		
		[fmtrCurrencyFromStr release];
		
    }
	
	NSLog(@"Leaving Init");
	
    return self;
}

//--------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(UIApplication *)application {
			
	// Add the tab bar controller's current view as a subview of the window
	NSLog(@"Start applicationDidFinishLaunching");
	
	[window addSubview:tabBarController.view];	

	buttonConvert.title = NSLocalizedString(@"Convert",@"Convert");
	buttonEdit.title = NSLocalizedString(@"Edit",@"Edit");
	buttonDownload.title = NSLocalizedString(@"Download",@"Download");
	buttonSettings.title = NSLocalizedString(@"Settings",@"Settings");
	
	if(timeToUpdate == YES)
		tabBarController.selectedIndex = 2;
	NSLog(@"END applicationDidFinishLaunching");
}

//------------------------------------------------------------------------------
// Save all changes to the database, then close it.
- (void)applicationWillTerminate:(UIApplication *)application {
    
	// Save changes.
    [self saveBackDatabase];
	[self saveUserSettings];
	
	NSLog(@"Saved changes back to database- exiting");
}

//------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // The app was successfully restored.  If your saved game state that is no longer
    // needed, you can delete that data now.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
	// Save changes.
    [self saveBackDatabase];
	[self saveUserSettings];
	
	NSLog(@"Entering Background. Saved changes back to database.");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // save all data objects
    [self saveBackDatabase];
}

- (void)dealloc {
	[tabBarController release];
	[window release];
	[rates release];
	[XMLlist release];
	[fromCurrency release];
	[toCurrency release];
	[masterCurrency release];
	[lastUpdate release];
	[localCurrency release];
	[localSeperator release];
	
	[super dealloc];
}



//--------------------------------------------------------------------------
-(void)getUserSettingsDefaults
{
	//Setup the Defaults incase never been run or we just need to
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:@"YES", @"kAutoUpdateKey", 
																			@"NO", @"kCalcLocationKey", 
																			@"0", @"kFromCurrencyKey", 
																			@"1", @"kToCurrencyKey", 
																			@"0", @"kMasterCurrencyKey",
																			@"0", @"kFromCurrencyRecordKey", 
																			@"0", @"kToCurrencyRecordKey", 
																			@"0", @"kMasterCurrencyRecordKey",
																			@"1217987918", @"kLastDownloadKey", 
																			nil];
	[defaults registerDefaults:appDefaults];
	
	//Now, let's get 'em
	intFromPosition = [[NSUserDefaults standardUserDefaults] integerForKey:@"kFromCurrencyKey"];
	intToPosition = [[NSUserDefaults standardUserDefaults] integerForKey:@"kToCurrencyKey"];
	intMasterPosition = [[NSUserDefaults standardUserDefaults] integerForKey:@"kMasterCurrencyKey"];
	
	intFromRecord = [self convertRatesPositionToRecordNumber:intFromPosition];
	intToRecord = [self convertRatesPositionToRecordNumber:intToPosition];
	intMasterRecord = [self convertRatesPositionToRecordNumber:intMasterPosition];
	
	//Later get language
	NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
	NSString* preferredLang = [languages objectAtIndex:0];
	NSLog(@"Language: %@",preferredLang);

}

//--------------------------------------------------------------------------
-(void) saveUserSettings {

	NSLog(@"START saveserSettings");
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",intFromPosition] forKey:@"kFromCurrencyKey"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",intToPosition] forKey:@"kToCurrencyKey"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",intMasterPosition] forKey:@"kMasterCurrencyKey"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",intFromRecord] forKey:@"kFromCurrencyRecordKey"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",intToRecord] forKey:@"kToCurrencyRecordKey"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",intMasterRecord] forKey:@"kMasterCurrencyRecordKey"];
	NSLog(@"END saveserSettings");
}




//--------------------------------------------------------------------------
//-Database Stuff

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
    	
	//Open the database
	self.database = [[CTDatabase alloc] initWithFileName:@"ratesdb.sql"];
	
	//Are we creating the tables on an initial run?
	if(![[self.database tableNames] containsObject:@"rates"])
	{
		//Copy the default old database from the bundle into the Documents Dir- then continue
		NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ratesdb.sql"];
		NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"ratesdb.sql"];
		NSLog(@"Source Path: %@\n Documents Path: %@ \n Folder Path: %@", sourcePath, documentsDirectory, folderPath);
		NSError *error = nil;
		[[NSFileManager defaultManager] removeItemAtPath:folderPath error:&error];
		[[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:folderPath error:&error];
		NSLog(@"The database was not present - so a copy was sent to the Documents folder");
		
		if (error == nil) {
			//Now, use the new copy
			[self.database release];
			self.database = [[CTDatabase alloc] initWithFileName:@"ratesdb.sql"];
		} else {
			NSLog(@"Error copying Database");
			return;
		}
	} 
	
	// Continue- Check if this is an up to date structure
	@try {
		[database executeSql: @"alter table rates add recordType text"];
		[database commit];
		NSString *sql = @"UPDATE rates SET recordType = 'F'";  //Fixed, non-editable record
		[database executeSql:sql];
		NSLog(@"Database alteration completed- added recordType field, continuing");
	}
	@catch (NSException* ex) {
		NSLog(@"Database alteration skipped: %@, continuing",ex);
	}

	//Add sorting Order
	@try {
		[database executeSql: @"alter table rates add sortingOrder numeric DEFAULT 1"];
		[database commit];
		NSLog(@"Database alteration completed- added sortingOrder field, continuing");
	}
	@catch (NSException* ex) {
		NSLog(@"Database alteration skipped: %@, continuing",ex);
	}
	
	NSLog(@"The database is ready, continue");
	[self readOutDatabase];
	
}

//----------------------------------------------------------------------------------------------------
// Dumps the working array in memory back into the database
- (void) saveBackDatabase {
	
	NSString *sql = nil;
	NSDate *today = [NSDate date];
	RateRecord *tempRate;
	
	for (int x=0; x<[self.rates count]; x++) {
		
		tempRate = [rates objectAtIndex:x];
		
		sql = [NSString stringWithFormat:@"UPDATE rates SET lastUpdate=%d, symbolCodes=\"%@\", currencyCode=\"%@\", currencyDesc=\"%@\", rateValue=%@, sortingOrder=%i WHERE pk=%@", 
			   today, 
			   tempRate.symbolCodes,
			   tempRate.currencyCode,
			   tempRate.currencyDesc,
			   tempRate.rateValue,
			   x,
			   tempRate.recordKey];
		
		@try {
			[database beginTransaction];
			[database executeSql:sql];
			[database commit];
		}
		@catch (NSException* ex) {
			NSString *aMessage;
			aMessage = NSLocalizedString(@"There was an error saving to the Database",@"There was an error saving to the Database");
			UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",@"Alert")
																message:aMessage 
															   delegate:self 
													  cancelButtonTitle:NSLocalizedString(@"OK",@"OK") 
													  otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			
			NSLog(@"Database alteration skipped: %@, continuing",ex);
		}
	}

}

//----------------------------------------------------------------------------------------------------
// Dumps the database into the working array
- (void) readOutDatabase {
	
	NSMutableArray *ratesArray = [[NSMutableArray alloc] init];
	self.rates = ratesArray;
	[ratesArray release];
	
	NSString *sql = @"SELECT * FROM rates ORDER BY sortingOrder";
	self.results = [self.database executeSql:sql];
	
	NSDictionary *rowData;
	
	for(int x=0;x<[self.results count];x++) {
		rowData = [self.results objectAtIndex:x];
		
		RateRecord *tempRate = [[RateRecord alloc] init];
		tempRate.lastUpdate = [rowData objectForKey:@"lastUpdate"];
		tempRate.symbolCodes = [rowData objectForKey:@"symbolCodes"];
		tempRate.currencyCode = [rowData objectForKey:@"currencyCode"];
		tempRate.currencyDesc = [rowData objectForKey:@"currencyDesc"];
		tempRate.recordType = [rowData objectForKey:@"recordType"];
		tempRate.rateValue = [rowData objectForKey:@"rateValue"];
		tempRate.recordKey = [rowData objectForKey:@"pk"];
		
		[self.rates addObject:tempRate];
		[tempRate release];
	}
	
	fromCurrency   = [self objectInRatesAtIndex:intFromPosition];
	toCurrency     = [self objectInRatesAtIndex:intToPosition];
	masterCurrency = [self objectInRatesAtIndex:intMasterPosition];
	
	//Save to prefs
	[self saveUserSettings];

}

//----------------------------------------------------------------------------------------------------
// Delets a record from the database, then re-populates the working array
- (void) deleteFromDatabaseThisRecord:(NSNumber *)recordKey {
	
	NSString *sql = [NSString stringWithFormat:@"DELETE FROM rates WHERE pk=%@", recordKey];
	self.results = [self.database executeSql:sql];
	
	[self readOutDatabase];
}


//----------------------------------------------------------------------------------------------------
// Inserts workingCurrency from an ADD into the database
// This is a custom record type
- (void) insertNewWorkingCurrency {
	
	NSString *sql = nil;
	NSDate *today = [NSDate date];
		
	sql = [NSString stringWithFormat:@"INSERT INTO rates (lastUpdate, symbolCodes, currencyCode, currencyDesc, rateValue, recordType, sortingOrder) VALUES (%d, \"%@\", \"%@\", \"%@\", %@, 'C', %i)", 
											today, 
											workingCurrency.symbolCodes,
											workingCurrency.currencyCode,
											workingCurrency.currencyDesc,
											workingCurrency.rateValue,
											[rates count]];
	
	@try {
		[database beginTransaction];
		[database executeSql:sql];
		[database commit];
		
		[self readOutDatabase];
	}
	@catch (NSException* ex) {
		NSString *aMessage;
		aMessage = NSLocalizedString(@"There was an error saving your Currency",@"There was an error saving your Currency");
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",@"Alert")
															message:aMessage 
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"OK",@"OK") 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
		NSLog(@"Database alteration skipped: %@, continuing",ex);
	}
	
}

//------------------------------------------------------------------------------------------
// See if a user's custom currency can use this user's code
// A yes indicates it's OK to use this code. 
- (BOOL) checkUserCode:(NSString *)userCode {
	
	BOOL retVal = YES;
	
	for(int x=0;x<[rates count];x++) {
		if( [userCode isEqual:[[rates objectAtIndex:x] currencyCode]]  &&  [[[rates objectAtIndex:x] recordType] isEqualToString:@"F"] ) {
			return NO;  //It's a fixed record type, not Custom
		}	
	}
	
	return retVal;
}

//End Database Stuff
//------------------------------------


//------------------------------------------------------------------------
- (NSUInteger)countOfRates {
	return [rates count];
}

//------------------------------------------------------------------------
//-- Lookup in the rates array by Code
- (NSUInteger)foundInRates:(NSString *)theString {
    
	unsigned x = -1;
	for(x=0;x<[rates count];x++) {
		//NSLog(@"Compare in:%@ length: %i to:%@ length: %i",theString,[theString length],[[rates objectAtIndex:x] currencyCode],[[[rates objectAtIndex:x] currencyCode] length]);
		if( [theString isEqual:[[rates objectAtIndex:x] currencyCode] ] ) {
			return x;
		}	
	}
	return -1;
}

//------------------------------------------------------------------------
// Returns position in the rates array for a specific record number
- (NSUInteger)convertRecordNumberToRatesPosition:(NSUInteger)recordNumber {
    
	unsigned x = 0;
	for(x=0;x<[rates count];x++) {
		NSLog(@"%i", [[[rates objectAtIndex:x] recordKey] intValue]);
		if( [[[rates objectAtIndex:x] recordKey] intValue] == recordNumber ) {
			return x;
		}	
	}
	return 0;
}



-(void) dumpRates {

	for(int x=0;x<[rates count];x++) 
		NSLog(@"%@ %i",[[rates objectAtIndex:x] currencyDesc],[[rates objectAtIndex:x] recordKey]);
}

//------------------------------------------------------------------------
// Returns the record number for the record at a position in the rates array 
- (NSUInteger)convertRatesPositionToRecordNumber:(NSUInteger)ratesPosition {
    RateRecord *tempRate = [self objectInRatesAtIndex:ratesPosition];
	return [tempRate.recordKey intValue];
}


//------------------------------------------------------------------------
//--Called from settings window when changing Currencies
- (void)setFromPos:(NSInteger)newPos {
	intFromPosition = newPos;
	intFromRecord = [self convertRatesPositionToRecordNumber:newPos];
	fromCurrency = [self objectInRatesAtIndex:newPos];
}
//------------------------------------------------------------------------
//--Called from settings window when changing Currencies
- (void)setToPos:(NSInteger)newPos {
	intToPosition = newPos;
	intToRecord = [self convertRatesPositionToRecordNumber:newPos];
	toCurrency = [self objectInRatesAtIndex:newPos];
}
//------------------------------------------------------------------------
//--Called from settings window when changing Currencies
- (void)setMasterPos:(NSInteger)newPos {
	intMasterPosition = newPos;
	intMasterRecord = [self convertRatesPositionToRecordNumber:newPos];
	masterCurrency = [self objectInRatesAtIndex:newPos];
}

//------------------------------------------------------------------------
//--Called after any re-order of the Table BEFORE saving back into the database
- (void)resetToFromMasterPositions {
	
	RateRecord *tempRate;
	
	for (int x=0; x<[rates count]; x++) {
		tempRate = [rates objectAtIndex:x];
		
		if ([tempRate.recordKey intValue] == intFromRecord) {
			intFromPosition = x;
		}
		if ([tempRate.recordKey intValue] == intToRecord) {
			intToPosition = x;
		}
		if ([tempRate.recordKey intValue] == intMasterRecord) {
			intMasterPosition = x;
		}
	}
	
}


//------------------------------------------------------------------------
- (id)objectInRatesAtIndex:(NSUInteger)theIndex {
	return [rates objectAtIndex:theIndex];
}

//For editing and the like
- (void)setWorkingCurrencyToThisRecord:(RateRecord *)rateRecord {
	workingCurrency = rateRecord;
}

//Make a blank record to add to the array, then into the database
- (void)clearWorkingCurrency {
	
	RateRecord *tempRate = [[RateRecord alloc] init];
	workingCurrency = tempRate;
}


// Remove a specific rate from the array of rates and also from the database.
- (void)removeRate:(RateRecord *)rate {
    // Delete from the database first. The rate knows how to do this (see Rate.m)
    //[rate deleteFromDatabase];
    [rates removeObject:rate];
}

// Insert a new rate into the database and add it to the array of rates.
- (void)addRate:(RateRecord *)rate {
    // Create a --new-- record in the database and get its automatically generated primary key.
	NSDate *today = [NSDate date];
	rate.lastUpdate = today;
	//Also a check for symbol codes- if none, save with a space
	if( rate.symbolCodes.length == 0 )
		rate.symbolCodes = @"32";
	//[rate insertIntoDatabase:database];
    [rates addObject:rate];
}


//-- Setting up the Currency formatters  NEW NEW NEW
//-- Adding as Strings, convert to unichar at print
- (NSString*) makeSymbolsForCurrency:(NSUInteger)atPos {
	
	NSString *string = [[rates objectAtIndex:atPos] symbolCodes];
	NSString *workingString;
	NSString *commaString = @",";
	NSRange  aRange;
	NSRange  workingRange;
	BOOL     findingCommas = TRUE;
	NSString *retString = @"";
	NSInteger x;
	unichar currencySymbol;
	
	NSMutableArray *aArray = [[NSMutableArray alloc] init];
	
	//If it's a single value, just grab it and don't loop
	while(findingCommas) {
		aRange = [string rangeOfString:commaString];
		if( aRange.length <= 0 ) {
			//Save It
			[aArray addObject:string];
			findingCommas = FALSE;
		}
		else {
			//save the first value
			workingRange.length = aRange.location;
			workingRange.location = 0;
			workingString = [string substringWithRange:(NSRange)workingRange];
			//Save It
			[aArray addObject:workingString];
			//Cut it off, reusing workingString
			aRange.location = aRange.location + 1;
			aRange.length = [string length] - aRange.location;
			workingString = [string substringWithRange:(NSRange)aRange];
			string = workingString;
		}
	}
	
	//OK- all that's done, so let's build the string to return
	workingString = nil;
	if( [aArray count] != 0 ) {
		//Build It
		for(x=0;x<[aArray count];x++) {
			workingString = [aArray objectAtIndex:x];
			currencySymbol = [workingString intValue];
			retString = [retString stringByAppendingString:[NSString stringWithFormat:@"%C",currencySymbol]];
		}
	}
	//Add trailing Space
	retString = [retString stringByAppendingString:@" "];
	[aArray release];
	return retString;
}

//-- Setting up the Currency formatters  NEW NEW NEW
//-- Adding as Strings, convert to unichar at print
- (NSString*) makeSymbolsForCurrencyWithThisString:(NSString *)symbolString {
	
	NSString *workingString;
	NSString *commaString = @",";
	NSRange  aRange;
	NSRange  workingRange;
	BOOL     findingCommas = TRUE;
	NSString *retString = @"";
	NSInteger x;
	unichar currencySymbol;
	
	NSMutableArray *aArray = [[NSMutableArray alloc] init];
	
	//If it's a single value, just grab it and don't loop
	while(findingCommas) {
		aRange = [symbolString rangeOfString:commaString];
		if( aRange.length <= 0 ) {
			//Save It
			[aArray addObject:symbolString];
			findingCommas = FALSE;
		}
		else {
			//save the first value
			workingRange.length = aRange.location;
			workingRange.location = 0;
			workingString = [symbolString substringWithRange:(NSRange)workingRange];
			//Save It
			[aArray addObject:workingString];
			//Cut it off, reusing workingString
			aRange.location = aRange.location + 1;
			aRange.length = [symbolString length] - aRange.location;
			workingString = [symbolString substringWithRange:(NSRange)aRange];
			symbolString = workingString;
		}
	}
	
	//OK- all that's done, so let's build the string to return
	workingString = nil;
	if( [aArray count] != 0 ) {
		//Build It
		for(x=0;x<[aArray count];x++) {
			workingString = [aArray objectAtIndex:x];
			currencySymbol = [workingString intValue];
			retString = [retString stringByAppendingString:[NSString stringWithFormat:@"%C",currencySymbol]];
		}
	}
	//Add trailing Space
	retString = [retString stringByAppendingString:@" "];
	[aArray release];
	return retString;
}



//---------------------------------
// To Calculate the Table Cell list info line
//---------------------------------
- (NSString *)calculateTableCellLine:(NSInteger)atPos flip:(BOOL)flip {
	
	float answer;
	NSString *retVal = nil;
	
	if (flip == YES) {
		answer = ( [[[rates objectAtIndex:intMasterPosition] rateValue]  floatValue] / 2 * ( 2 / [[[rates objectAtIndex:atPos] rateValue] floatValue]) );
	} else {
		answer = ( [[[rates objectAtIndex:atPos] rateValue] floatValue] / 2 * ( 2 / [[[rates objectAtIndex:intMasterPosition] rateValue]  floatValue] ) );
	}
	
	retVal = [NSString stringWithFormat:@"%0.4f", answer];
	return [self setToLocalCurrencyFormat:retVal asRate:YES];
}

- (NSString *)calculateTableCellLineWithSpecificRecord:(RateRecord *)useRate flip:(BOOL)flip {
	
	float answer;
	NSString *retVal = nil;
	
	if (flip == YES) {
		answer = ( [[[rates objectAtIndex:intMasterPosition] rateValue]  floatValue] / 2 * ( 2 / [useRate.rateValue floatValue] ) );
	} else {
		answer = ( [useRate.rateValue floatValue] / 2 * ( 2 / [[[rates objectAtIndex:intMasterPosition] rateValue]  floatValue] ) );
	}
	
	retVal = [NSString stringWithFormat:@"%0.4f", answer];
	return [self setToLocalCurrencyFormat:retVal asRate:YES];
}


- (BOOL)isMasterCurrency:(NSInteger)atPos {
	
	BOOL retVal = NO;
	
	if (atPos == intMasterPosition) {
		retVal = YES;
	}

	return retVal;
}

- (BOOL)isMasterCurrencyRecord:(NSInteger)recordNumber {
	
	BOOL retVal = NO;
	
	if (recordNumber == intMasterRecord) {
		retVal = YES;
	}
	
	return retVal;
}
//--End


//---------------------------------------------------------------------------------------------
//----XML Updates
//----Start
- (void)initGetCurrencyData {
	
	lastUpdateSuccessful = NO;
	
	//Empty the array
	self.XMLlist = [NSMutableArray array];
	NSError *parseError = nil;
	
	NSString *XML_URL = @"http://www.chuckt.com/iPhone/convert/convert.xml";
	
	streamingParser = [[XMLCurrencyReader alloc] initWithDelegate:self];
	[streamingParser parseXMLFileAtURL:[NSURL URLWithString:XML_URL] parseError:&parseError];

}

//--Call from the Thread above
- (void)XMLParsingComplete {
    
	if( [self.XMLlist count] >= 1 ) {
		[DownloadViewController sharedInstance].labelActivity.text = NSLocalizedString(@"Parsing Data",@"Parsing Data");
		[self processXMLlist];
	} else {
		[DownloadViewController sharedInstance].labelActivity.text = NSLocalizedString(@"Error with Download","Error with Download");
		[DownloadViewController sharedInstance].labelActivity.hidden = false;
	}

}

//------------------------------------------------------------------------------------
- (void)updateRateFromXML:(CurrencyStruct *)newCurrency {	
	
	[self.XMLlist addObject:newCurrency];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ARateWasDownloaded" object:nil];
	
}

- (void)getList:(id *)objsPtr range:(NSRange)range {
	[XMLlist getObjects:objsPtr range:range];
}

//------------------------------------------------------------------------------------
- (void)processXMLlist {

	//Solve the large init / release problem I found in Console
	//with a local pool
	NSAutoreleasePool *XMLpool = [[NSAutoreleasePool alloc] init];
	
	NSInteger x;
	NSInteger pos;
	NSNumber *updatedRate;
	NSString *code;
	NSDate *today = [NSDate date];

	[DownloadViewController sharedInstance].labelActivity.text = NSLocalizedString(@"Saving Data",@"Saving Data");
	
	NSLog(@"Processing %i from XML List into a rates list of %i",[XMLlist count],[rates count]);
	
	for(x=0; x< ([XMLlist count]);x++) {
	
		code = [NSString stringWithFormat:@"%@", [[XMLlist objectAtIndex:x] currencyCode]];
		pos = [self foundInRates:code];
		
		if( (pos >= 0) && (pos <= [rates count]) ) {
			
			//Why this comes back as a string, I don't know, but let's convert again to an NSNumber
			updatedRate = [NSNumber numberWithFloat:[[[XMLlist objectAtIndex:x] rateValue] floatValue]];
			[[rates objectAtIndex:pos] setValue:updatedRate forKey:@"rateValue"];
			[[rates objectAtIndex:pos] setValue:today forKey:@"lastUpdate"];
			
			//NSLog(@"%@",[NSString stringWithFormat:@"Updating %@ to: %@",code, [[XMLlist objectAtIndex:x] rateValue]]);
		} else {
			NSLog(@"FAILED TO UPDATE: code is %@ pos is %i against rates count of%i",code,pos,[rates count]);
		}
	}
	
	lastUpdateSuccessful = YES;
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[today timeIntervalSince1970]] forKey:@"kLastDownloadKey"];
	
	[DownloadViewController sharedInstance].labelActivity.text = NSLocalizedString(@"Download Complete",@"Download Complete");	
	
	//Resave the database
	[self saveBackDatabase];
	
	//Rehydrate the database? do we need to?  YES!! YES!! That was it-
	[self readOutDatabase];
		
	[XMLpool release];

}

//-----END XML
//----------------------------------------------------------------------------------------------------



//------------------------------------------------------------------
// Convert US decimal for Display to local format
// NOTE: asRate of YES means we show with 4 decimals and leading zeros
// otherwise, calculate for money conversion
-(NSString *)setToLocalCurrencyFormat:(NSString *)stringValue asRate:(BOOL)asRate {
	
	NSString *retVal = nil;
	
	NSDecimalNumber *convertAmount = [NSDecimalNumber decimalNumberWithString:stringValue];
	
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setLocale:[NSLocale currentLocale]];
	[currencyFormatter setNumberStyle:NSNumberFormatterBehavior10_4];
	[currencyFormatter setGeneratesDecimalNumbers:YES];
	[currencyFormatter setLenient:YES];
	
	if (asRate == YES) {
		[currencyFormatter setPositiveFormat:@"#,###.0000"];
	} else {
		[currencyFormatter setPositiveFormat:@"#,###.00"];
	}

	retVal = [currencyFormatter stringFromNumber:convertAmount];
	
	[currencyFormatter release];
	
	return retVal;
}



@end

