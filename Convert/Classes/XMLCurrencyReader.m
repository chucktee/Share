//
//  XMLCurrencyReader.m
//  Currency
//
//  Created by Chuck Toussieng on 7/3/08.
//  Copyright 2008 Chuck Toussieng. All rights reserved.
//

#import "ConvertAppDelegate.h"
#import "XMLCurrencyReader.h"
#import "DownloadViewController.h"

static NSUInteger parsedCurrenciesCounter;

@implementation XMLCurrencyReader

@synthesize currentCurrencyObject = _currentCurrencyObject;
@synthesize contentOfCurrentCurrencyProperty = _contentOfCurrentCurrencyProperty;
@synthesize delegate, URL;

// Limit the number of parsed Currencys to 80
#define MAX_CURRENCIES 80


//-----------------------------------------------------------------------------------
- (XMLCurrencyReader *) initWithDelegate: (id) d {
	self = [super init];
	[self setDelegate: d];
	return self;
}

//-----------------------------------------------------------------------------------
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    parsedCurrenciesCounter = 0;
}


//-----------------------------------------------------------------------------------
- (void)parseXMLFileAtURL:(NSURL *)url parseError:(NSError **)error
{	
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self setURL:url];
	
    myThread = [[NSThread alloc] initWithTarget:self selector:@selector(run:) object: nil];
	[myThread start];
    [pool release];
	
}

//-----------------------------------------------------------------------------------
- (void)run:(id)param  
{						
	
	NSAutoreleasePool *localPool;
	
	@try {
		
		localPool = [[NSAutoreleasePool alloc] init];
		
		if ([NSThread isMainThread]) {
			NSLog(@"XML Reader is executing in the main thread");
		} else {
			NSLog(@"XML Reader is executing in a background thread");
		}
		
		NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
		// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
		[parser setDelegate:self];
		// Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
		[parser setShouldProcessNamespaces:NO];
		[parser setShouldReportNamespacePrefixes:NO];
		[parser setShouldResolveExternalEntities:NO];
		
		[parser parse];
		
		[parser release];
		
		[delegate XMLParsingComplete];
		
	}
	@catch (NSException * exception) {
		// handle the error -- do not rethrow it
		NSLog(@"error %@", [exception reason]);
	}
	@finally {
		[localPool release];
	}
	
}

//-----------------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{

	if (qName) {
        elementName = qName;
    }
	
    // If the number of parsed Currencies is greater than MAX_ELEMENTS, abort the parse.
    // Otherwise the application runs very slowly on the device.
    if (parsedCurrenciesCounter >= MAX_CURRENCIES) {
        [parser abortParsing];
    }
    
    if ([elementName isEqualToString:@"entry"]) {
        parsedCurrenciesCounter++;
        // An entry in the XML feed represents an currency, so create an instance of it.
        self.currentCurrencyObject = [[CurrencyStruct alloc] init];
		
		[(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(updateRateFromXML:) withObject:self.currentCurrencyObject waitUntilDone:YES];
		
		[self.currentCurrencyObject release];
		return;
    }

    self.contentOfCurrentCurrencyProperty = [[NSMutableString alloc] init];

}


//--Here is where we fill the struct from the XML
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
	if (qName) {
        elementName = qName;
    }
    
    if ([elementName isEqualToString:@"symbolCodes"]) {
        self.currentCurrencyObject.symbolCodes = self.contentOfCurrentCurrencyProperty;
        [self.contentOfCurrentCurrencyProperty release];
    }

	if ([elementName isEqualToString:@"currencyDesc"]) {
        self.currentCurrencyObject.currencyDesc = self.contentOfCurrentCurrencyProperty;
		[self.contentOfCurrentCurrencyProperty release];
	}
	
    if ([elementName isEqualToString:@"currencyCode"]) {
        self.currentCurrencyObject.currencyCode = self.contentOfCurrentCurrencyProperty;
		[self.contentOfCurrentCurrencyProperty release];
	}
    
    if ([elementName isEqualToString:@"rateValue"]) {
        self.currentCurrencyObject.rateValue = self.contentOfCurrentCurrencyProperty;
		[self.contentOfCurrentCurrencyProperty release];
	}
}

//Sent by a parser object to provide its delegate with a string representing all *or part* of the characters of the current element.
//Because string may be only part of the total character content for the current element, you should append it to the current accumulation of characters until the element changes.
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //Clean the control chars out if any
	NSMutableString *stringToNukeNewlinesFrom;
	
	stringToNukeNewlinesFrom = [[NSMutableString alloc] initWithString:string];
	[stringToNukeNewlinesFrom replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, [stringToNukeNewlinesFrom length])];
	[stringToNukeNewlinesFrom replaceOccurrencesOfString:@"\t" withString:@"" options:0 range:NSMakeRange(0, [stringToNukeNewlinesFrom length])];
	
	[self.contentOfCurrentCurrencyProperty appendString:stringToNukeNewlinesFrom];
	
	[stringToNukeNewlinesFrom release];
}

-(void) dealloc {
	[_currentCurrencyObject release];
	[_contentOfCurrentCurrencyProperty release];
	[super dealloc];
}


@end
