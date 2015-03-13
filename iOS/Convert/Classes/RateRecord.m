//
//  RateRecord.m
//  Convert
//
//  Created by Chuck Toussieng on 12/20/10.
//  Copyright 2010 Chuck Toussieng. All rights reserved.
//

#import "RateRecord.h"


@implementation RateRecord

@synthesize lastUpdate;
@synthesize symbolCodes;
@synthesize currencyCode;
@synthesize currencyDesc;
@synthesize recordType;
@synthesize rateValue;
@synthesize recordKey;

- (void) dealloc
{
	[lastUpdate release];
	[symbolCodes release];
	[currencyCode release];
	[currencyDesc release];
	[recordType release];
	[rateValue release];
	[recordKey release];
	[super dealloc];
}

@end
