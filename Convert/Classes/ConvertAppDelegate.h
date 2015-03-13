//
//  ConvertAppDelegate.h
//  Convert
//
//  Created by Chuck Toussieng on 7/15/08.
//  Copyright 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "RateRecord.h"
#import "CurrencyStruct.h"
#import "DownloadViewController.h"
#import "XMLCurrencyReader.h"

@class RateRecord;
@class DownloadViewController;
@class CTDatabase;

@interface ConvertAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, XMLCurrencyReaderDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	IBOutlet UITabBarItem *buttonConvert;
	IBOutlet UITabBarItem *buttonEdit;
	IBOutlet UITabBarItem *buttonDownload;
	IBOutlet UITabBarItem *buttonSettings;
	
	CTDatabase *database;
	
	//Where we store the rates from the database, and a temp list for XML updates
	NSMutableArray *rates;
	NSMutableArray *XMLlist;
    NSArray *results;
	
	//For local formats
	NSString *localSeperator;
	NSString *localCurrency;
	
	BOOL autoUpdate;
	BOOL timeToUpdate;
	NSNumber *lastUpdate;
	BOOL lastUpdateSuccessful;
	
	//The index into the convert from and convert to currencies
	NSInteger intFromPosition;
	NSInteger intToPosition;
	NSInteger intMasterPosition;
	NSInteger intFromRecord;
	NSInteger intToRecord;
	NSInteger intMasterRecord;
	
	RateRecord *fromCurrency;
	RateRecord *toCurrency;
	RateRecord *masterCurrency;
	RateRecord *workingCurrency;
	
	XMLCurrencyReader *streamingParser;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) NSMutableArray *rates;
@property (nonatomic, retain) NSMutableArray *XMLlist;
@property (nonatomic, retain) NSArray *results;
@property (nonatomic, retain) RateRecord *fromCurrency;
@property (nonatomic, retain) RateRecord *toCurrency;
@property (nonatomic, retain) RateRecord *masterCurrency;
@property (nonatomic, retain) RateRecord *workingCurrency;
@property (nonatomic, retain) NSNumber *lastUpdate;
@property (nonatomic, readwrite) NSInteger intFromPosition;
@property (nonatomic, readwrite) NSInteger intToPosition;
@property (nonatomic, readwrite) NSInteger intMasterPosition;
@property (nonatomic, readwrite) NSInteger intFromRecord;
@property (nonatomic, readwrite) NSInteger intToRecord;
@property (nonatomic, readwrite) NSInteger intMasterRecord;
@property (nonatomic, retain)	CTDatabase *database;
@property (nonatomic, retain) NSString *localSeperator;
@property (nonatomic, retain) NSString *localCurrency;

-(void)getUserSettingsDefaults;
-(void)saveUserSettings;

- (NSUInteger)countOfRates;
- (NSUInteger)foundInRates:(NSString *)theString;
- (NSUInteger)convertRecordNumberToRatesPosition:(NSUInteger)recordNumber;
- (NSUInteger)convertRatesPositionToRecordNumber:(NSUInteger)ratesPosition;

- (id)objectInRatesAtIndex:(NSUInteger)theIndex;

- (void)setFromPos:(NSInteger)newPos;
- (void)setToPos:(NSInteger)newPos;
- (void)setMasterPos:(NSInteger)newPos;
- (void)resetToFromMasterPositions;

- (NSString*) makeSymbolsForCurrency:(NSUInteger)atPos;
- (NSString*) makeSymbolsForCurrencyWithThisString:(NSString *)symbolString;
- (NSString *)calculateTableCellLine:(NSInteger)atPos flip:(BOOL)flip;
- (NSString *)calculateTableCellLineWithSpecificRecord:(RateRecord *)useRate flip:(BOOL)flip;
- (BOOL)isMasterCurrency:(NSInteger)atPos;
- (BOOL)isMasterCurrencyRecord:(NSInteger)atPos;
- (NSString *)setToLocalCurrencyFormat:(NSString *)stringValue asRate:(BOOL)asRate;

- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)saveBackDatabase;
- (void)readOutDatabase;
- (void)insertNewWorkingCurrency;
- (BOOL)checkUserCode:(NSString *)userCode;
- (void)deleteFromDatabaseThisRecord:(NSNumber *)recordKey;

- (void)initGetCurrencyData;
- (void)setWorkingCurrencyToThisRecord:(RateRecord *)rateRecord;
- (void)clearWorkingCurrency;

// Removes a rate from the array of rates, and also deletes it from the database. There is no undo.
- (IBAction)removeRate:(RateRecord *)rates;
// Creates a new rate object with default data. 
- (void)addRate:(RateRecord *)rates;

//XML Stuff
- (void)updateRateFromXML:(CurrencyStruct *)newCurrency;
- (void)processXMLlist;

@end
