//
//  CurrencyStruct.h
//  Currency
//
//  Created by Chuck Toussieng on 7/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrencyStruct : NSObject {
	
@private   
	NSString *_symbolCodes;
	NSString *_currencyDesc;
    NSString *_currencyCode;    
    NSString *_rateValue;			 
}

@property (nonatomic, retain) NSString *symbolCodes;
@property (nonatomic, retain) NSString *currencyDesc;
@property (nonatomic, retain) NSString *currencyCode;
@property (nonatomic, retain) NSString *rateValue;

@end
