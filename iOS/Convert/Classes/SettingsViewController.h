#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ConvertAppDelegate.h"

@interface SettingsViewController : UIViewController {
    
	IBOutlet UILabel	  *labelCheckToDownload;
	IBOutlet UILabel	  *labelExportTransactions;
	IBOutlet UINavigationItem	*navBarTitle;
	
	IBOutlet UIPickerView *fromPicker;
	IBOutlet UIPickerView *toPicker;
	IBOutlet UIPickerView *masterPicker;
	
	IBOutlet UISegmentedControl *selectPickerButtons;
	IBOutlet UIImageView *imageArrow;
	
	IBOutlet UISwitch *switchAutoDownload;
	IBOutlet UISwitch *switchIgnoreDeleted;
	
	BOOL settingFromCurrency;
	BOOL settingToCurrency;
	BOOL settingMasterCurrency;
	CGAffineTransform transformTo;
	CGAffineTransform transformFrom;
	CGAffineTransform transformMaster;
	CGAffineTransform transformArrow;
	int fromPickerRow;
	int toPickerRow;
	int masterPickerRow;
	
	ConvertAppDelegate *appDelegate;
	
	
}

@property (nonatomic, retain) UIPickerView *fromPicker;
@property (nonatomic, retain) UIPickerView *toPicker;
@property (nonatomic, retain) UIPickerView *masterPicker;

- (IBAction)changePickers;
- (IBAction)switchedAutoDownload;
- (IBAction)switchedIgnoreDeleted;

@end
