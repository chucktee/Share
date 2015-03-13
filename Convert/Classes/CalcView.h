#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ConvertAppDelegate.h"

@interface CalcView : UIViewController {
    IBOutlet UILabel     *lblConvertTo;
    IBOutlet UILabel     *lblMaster;
    IBOutlet UITextField *textConvertedAnswer;
    IBOutlet UITextField *textFromAmount;
	IBOutlet UITextField *textHiddenFromAmount;
    IBOutlet UIButton *buttonChangeCnvTo;
    IBOutlet UIButton *buttonChangeMaster;
    IBOutlet UIButton *button7;
	IBOutlet UIButton *button8;
	IBOutlet UIButton *button9;
	IBOutlet UIButton *button4;
	IBOutlet UIButton *button5;
	IBOutlet UIButton *button6;
	IBOutlet UIButton *button1;
	IBOutlet UIButton *button2;
	IBOutlet UIButton *button3;
	IBOutlet UIButton *button0;
	IBOutlet UIButton *buttonDecimal;
	IBOutlet UIButton *buttonClear;
	IBOutlet UIButton *buttonFlipFlop;
	IBOutlet UILabel  *lblLongFromDesc;
	IBOutlet UILabel  *lblLongToDesc;
	IBOutlet UINavigationItem *navTitle;
	IBOutlet UIImageView  *imageFromFlag;
	IBOutlet UIImageView  *imageToFlag;
	BOOL inTheDecimal;
	int  decimalPos;
	ConvertAppDelegate *appDelegate;
	
}

- (IBAction)clicked7;
- (IBAction)clicked8;
- (IBAction)clicked9;
- (IBAction)clicked4;
- (IBAction)clicked5;
- (IBAction)clicked6;
- (IBAction)clicked1;
- (IBAction)clicked2;
- (IBAction)clicked3;
- (IBAction)clicked0;
- (IBAction)clickedDecimal;
- (IBAction)clickedClear;
- (IBAction)clickedChangeMaster;
- (IBAction)clickedChangeCnvTo;
- (IBAction)clickedFlipFlop;

- (void)addAChar:(NSString *)aString;
- (void)calculateAnswer;
- (void)showFromInformation;
- (void)showToInformation;
- (void)prepToAndFromLabels;
- (void)checkIfSymbolIsShowing;

@end