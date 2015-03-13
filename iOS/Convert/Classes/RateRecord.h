//
//  RateRecord.h
//  Convert
//
//  Created by Chuck Toussieng on 12/20/10.
//  Copyright 2010 Chuck Toussieng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTDatabaseModel.h"

@interface RateRecord : CTDatabaseModel {

	NSDate *lastUpdate;
	NSString *symbolCodes;
    NSString *currencyCode;
	NSString *currencyDesc;
	NSString *recordType;
	NSNumber *rateValue;
	NSNumber *recordKey;
	
}

@property (nonatomic, retain) NSDate *lastUpdate;
@property (nonatomic, retain) NSString *symbolCodes;
@property (nonatomic, retain) NSString *currencyCode;
@property (nonatomic, retain) NSString *currencyDesc;
@property (nonatomic, retain) NSString *recordType;
@property (nonatomic, retain) NSNumber *rateValue;
@property (nonatomic, retain) NSNumber *recordKey;

@end
