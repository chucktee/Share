//
//  ListCellViewController.h
//  Convert
//
//  Created by Chuck Toussieng on 12/19/10.
//  Copyright 2010 Chuck Toussieng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTableViewRowHeight 65


@interface ListCellViewController : UITableViewCell {

	UIImageView *backgroundImage;
	UIImageView *flagImage;
	UILabel		*currencyDescLabel;
	UILabel		*currencyCodeLabel;
	UILabel		*currencyCalcedRateInfo;
	UILabel		*currencyCalcedRateInverse;
	UILabel		*hiddenRecordNumber;
	
}

@property (nonatomic, retain) IBOutlet UILabel *currencyDescLabel;
@property (nonatomic, retain) IBOutlet UILabel *currencyCodeLabel;
@property (nonatomic, retain) IBOutlet UILabel *currencyCalcedRateInfo;
@property (nonatomic, retain) IBOutlet UILabel *currencyCalcedRateInverse;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, retain) IBOutlet UIImageView *flagImage;
@property (nonatomic, retain) IBOutlet UILabel *hiddenRecordNumber;

@end
