//
//  XMLCurrencyReader.h
//  Currency
//
//  Created by Chuck Toussieng on 7/3/08.
//  Copyright 2008. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XMLCurrencyReaderDelegate <NSObject>
@required
@end


@interface XMLCurrencyReader : NSObject <NSXMLParserDelegate> {

@private        
    CurrencyStruct *_currentCurrencyObject;
    NSMutableString *_contentOfCurrentCurrencyProperty;
	
	NSURL*		URL;
	NSThread	*myThread;
	id			delegate;
}

@property (nonatomic, retain) CurrencyStruct *currentCurrencyObject;
@property (nonatomic, retain) NSMutableString *contentOfCurrentCurrencyProperty;
@property (readwrite, retain) id delegate;
@property (readwrite, retain) NSURL *URL;

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error;
- (XMLCurrencyReader *) initWithDelegate: (id) d;

@end

@interface XMLCurrencyReader (XMLCurrencyReaderDelegate) 
	-(void) XMLParsingComplete;
@end
