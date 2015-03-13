//
//  ListCellViewController.m
//  Convert
//
//  Created by Chuck Toussieng on 12/19/10.
//  Copyright 2010 Chuck Toussieng. All rights reserved.
//

#import "ListCellViewController.h"


@implementation ListCellViewController

@synthesize currencyDescLabel, currencyCodeLabel, currencyCalcedRateInfo, currencyCalcedRateInverse;
@synthesize backgroundImage, flagImage, hiddenRecordNumber;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

}


- (void)dealloc {
	[currencyDescLabel release];
	[currencyCodeLabel release];
	[currencyCalcedRateInfo release];
	[currencyCalcedRateInverse release];
	[backgroundImage release];
	[flagImage release];
	[hiddenRecordNumber release];
    [super dealloc];
}


@end
