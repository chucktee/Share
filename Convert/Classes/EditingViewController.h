#import <UIKit/UIKit.h>
#import "ConvertAppDelegate.h"

@protocol EditingViewControllerDelegate;


@interface EditingViewController : UIViewController <UITextFieldDelegate> {

	id <EditingViewControllerDelegate> delegate;
	
	IBOutlet UIView				*sliderView;
	IBOutlet UINavigationItem	*navTitle;
	IBOutlet UIBarButtonItem	*buttonSave;
	IBOutlet UIBarButtonItem	*buttonCancel;
	
	IBOutlet UILabel			*labelCurrencyDescription;
	IBOutlet UITextField		*textCurrencyDescription;
	IBOutlet UILabel			*labelCurrencyRate;
	IBOutlet UITextField		*textCurrencyRate;
	IBOutlet UILabel			*labelCurrencyCode;
	IBOutlet UITextField		*textCurrencyCode;
	IBOutlet UILabel			*labelCurrencySymbol;
	IBOutlet UITextField		*textCurrencySymbol;
	IBOutlet UILabel			*labelCurrencySymbolRepresentation;
	IBOutlet UIImageView		*imageFlag;

	ConvertAppDelegate			*appDelegate;
	
	int	typeOfEdit;
}


@property (nonatomic, assign) int typeOfEdit;
@property (nonatomic, assign) id <EditingViewControllerDelegate> delegate;


- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (void) moveUpView:(BOOL)movingUp howMuch:(float)howMuch;

@end



@protocol EditingViewControllerDelegate
-(void)editingViewControllerDidFinish:(EditingViewController *)controller;
@end
