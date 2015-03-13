//
//  TableListViewController.h
//  Convert
//
//  Created by Chuck Toussieng on 12/26/10.
//  Copyright 2010 Chuck Toussieng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditingViewController.h"
#import "ConvertAppDelegate.h"

@interface TableListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, 
													   UINavigationBarDelegate, 
													   UISearchDisplayDelegate, UISearchBarDelegate, 
													   EditingViewControllerDelegate> {

	IBOutlet UITableView		*tableCurrencies;
	IBOutlet UINavigationBar	*navBar;
	IBOutlet UINavigationItem	*navBarTitle;
	IBOutlet UIBarButtonItem	*navBarButtonAdd;
	IBOutlet UIBarButtonItem	*navBarButtonEdit;
	
    NSMutableArray *searchResults;
	NSString *savedSearchTerm;

	ConvertAppDelegate *appDelegate;
	BOOL	isEditing;
}

@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, copy) NSString *savedSearchTerm;

- (void)handleSearchForTerm:(NSString *)searchTerm;
- (IBAction)clickedAdd;
- (IBAction)clickedEdit;

- (void)editingViewControllerDidFinish:(EditingViewController *)controller;

@end
