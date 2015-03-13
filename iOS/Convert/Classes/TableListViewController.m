//
//  TableListViewController.m
//  Convert
//
//  Created by Chuck Toussieng on 12/26/10.
//  Copyright 2010 Chuck Toussieng. All rights reserved.
//

#import "TableListViewController.h"
#import "ConvertAppDelegate.h"
#import "ListCellViewController.h"
#import "EditingViewController.h"

@implementation TableListViewController

@synthesize searchResults;
@synthesize savedSearchTerm;

#pragma mark -
#pragma mark Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	NSLog(@"INIT TableViewController");
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
	}
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
	NSLog(@"DID LOAD tableviewcontroller");
	
	// Custom initialization
	navBarTitle.title = NSLocalizedString(@"Currencies","Currencies");
	navBarButtonAdd.title = NSLocalizedString(@"Add","Add");
	
	appDelegate = (ConvertAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// Restore search term
	if ([self savedSearchTerm])
	{
		[[[self searchDisplayController] searchBar] setText:[self savedSearchTerm]];
	}
	
	[super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated {
	navBarButtonEdit.title = NSLocalizedString(@"Edit","Edit");
	isEditing = NO;
	[tableCurrencies reloadData];
}

-(void) viewDidDisappear:(BOOL)animated {
	isEditing = NO;
	navBarButtonEdit.title = NSLocalizedString(@"Edit","Edit");
	[tableCurrencies setEditing:NO];
}

- (void)viewDidUnload {
	
	[super viewDidUnload];
	
	// Save the state of the search UI so that it can be restored if the view is re-created.
	[self setSavedSearchTerm:[[[self searchDisplayController] searchBar] text]];
	[self setSearchResults:nil];
}

 
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// Add a user custom currency
- (IBAction)clickedAdd {
	
	[appDelegate clearWorkingCurrency];
	
	EditingViewController *tempcontroller = [[EditingViewController alloc] initWithNibName:@"EditRateView" bundle:nil];
	
	tempcontroller.typeOfEdit = 3;	//Add a custom rate
	
	tempcontroller.delegate = self;
	tempcontroller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:tempcontroller animated:YES];
	
	[tempcontroller release];

}

// Put the table into Edit Mode
- (IBAction)clickedEdit {
	
	if (isEditing == YES) {
		isEditing = NO;
		navBarButtonEdit.title = NSLocalizedString(@"Edit","Edit");
		[tableCurrencies setEditing:NO animated:YES];
	} else {
		navBarButtonEdit.title = NSLocalizedString(@"Done","Done");
		isEditing = YES;
		[tableCurrencies setEditing:YES animated:YES];
	}
}


#pragma mark -
#pragma mark Table view data source
//---------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kTableViewRowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	NSInteger rows;
	
	if (tableView == [[self searchDisplayController] searchResultsTableView])
		rows = [[self searchResults] count];
	else
		rows = [appDelegate countOfRates];
	
	// Return the number of rows in the section.
	return rows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ListCellIdentifier = @"ListCellIdentifier";
	
	ListCellViewController *cell = (ListCellViewController *)[tableView dequeueReusableCellWithIdentifier: ListCellIdentifier];
	
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListCellView" owner:self options:nil];
		for (id oneObject in nib)
			if ([oneObject isKindOfClass:[ListCellViewController class]])
				cell = (ListCellViewController *)oneObject;
	}
	
	if (tableView == [[self searchDisplayController] searchResultsTableView]) {
		
		// Set the cell's text, etc.
		NSNumber *rekKey = [[[self searchResults] objectAtIndex:indexPath.row] recordKey];
		
		if ([appDelegate isMasterCurrencyRecord:[rekKey intValue]]) {
			cell.backgroundImage.image = [UIImage imageNamed:@"cell_defaultBackground.png"];
			cell.currencyCalcedRateInfo.font = [UIFont systemFontOfSize:17.0];
			cell.currencyCalcedRateInfo.text = @"Master Currency";
			cell.currencyCalcedRateInverse.text = NSLocalizedString(@"Can be changed in Settings",@"Can be changed in Settings");
		} else {
			cell.backgroundImage.image = [UIImage imageNamed:@"cell_listBackground.png"];
			cell.currencyCalcedRateInfo.font = [UIFont systemFontOfSize:24.0];
			
			cell.currencyCalcedRateInfo.text = [NSString stringWithFormat:@"\u200E %@%@",
												[appDelegate makeSymbolsForCurrencyWithThisString:[[[self searchResults] objectAtIndex:indexPath.row] symbolCodes]], 
												[appDelegate calculateTableCellLineWithSpecificRecord:[[self searchResults] objectAtIndex:indexPath.row] flip:NO] ];
			
			cell.currencyCalcedRateInverse.text = [NSString stringWithFormat:@"\u200E %@1 = %@%@",
												   [appDelegate makeSymbolsForCurrency:appDelegate.intMasterPosition],
												   [appDelegate makeSymbolsForCurrencyWithThisString:[[[self searchResults] objectAtIndex:indexPath.row] symbolCodes]],
												   [appDelegate calculateTableCellLineWithSpecificRecord:[[self searchResults] objectAtIndex:indexPath.row] flip:YES]];
			
		}
		
		cell.currencyCodeLabel.text = [[[self searchResults] objectAtIndex:indexPath.row] currencyCode];
		cell.currencyDescLabel.text = [[[self searchResults] objectAtIndex:indexPath.row] currencyDesc];
		
		if ([[[[self searchResults] objectAtIndex:indexPath.row] recordType] isEqualToString:@"F"]) {
			cell.flagImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[[[self searchResults] objectAtIndex:indexPath.row] currencyCode]]];
		} else {
			cell.flagImage.image = [UIImage imageNamed:@"custom.png"];
		}
		
		cell.hiddenRecordNumber.text = [NSString stringWithFormat:@"%@", [[[self searchResults] objectAtIndex:indexPath.row] recordKey] ];
		
		//Editing controls
		cell.showsReorderControl = NO;
	
	} else {
	
		// Set the cell's text, etc.
		if ([appDelegate isMasterCurrency:indexPath.row]) {
			cell.backgroundImage.image = [UIImage imageNamed:@"cell_defaultBackground.png"];
			cell.currencyCalcedRateInfo.font = [UIFont systemFontOfSize:17.0];
			cell.currencyCalcedRateInfo.text = @"Master Currency";
			cell.currencyCalcedRateInverse.text = NSLocalizedString(@"Can be changed in Settings",@"Can be changed in Settings");
		} else {
			cell.backgroundImage.image = [UIImage imageNamed:@"cell_listBackground.png"];
			cell.currencyCalcedRateInfo.font = [UIFont systemFontOfSize:24.0];
			
			cell.currencyCalcedRateInfo.text = [NSString stringWithFormat:@"\u200E %@%@",
												[appDelegate makeSymbolsForCurrency:indexPath.row], 
												[appDelegate calculateTableCellLine:indexPath.row flip:NO] ];
			
			cell.currencyCalcedRateInverse.text = [NSString stringWithFormat:@"\u200E %@1 = %@%@",
												   [appDelegate makeSymbolsForCurrency:appDelegate.intMasterPosition],
												   [appDelegate makeSymbolsForCurrency:indexPath.row],
												   [appDelegate calculateTableCellLine:indexPath.row flip:YES]];
			
		}
		
		cell.currencyCodeLabel.text = [[appDelegate objectInRatesAtIndex:indexPath.row] currencyCode];
		cell.currencyDescLabel.text = [[appDelegate objectInRatesAtIndex:indexPath.row] currencyDesc];
		
		if ([[[appDelegate objectInRatesAtIndex:indexPath.row] recordType] isEqualToString:@"F"]) {
			cell.flagImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[[appDelegate objectInRatesAtIndex:indexPath.row] currencyCode]]];
		} else {
			cell.flagImage.image = [UIImage imageNamed:@"custom.png"];
		}
		
		cell.hiddenRecordNumber.text = [NSString stringWithFormat:@"%@", [[appDelegate objectInRatesAtIndex:indexPath.row] recordKey] ];
		
		//Editing controls
		cell.showsReorderControl = YES;
	
	}
		
	return cell;
	
}

//---------------------------
// Selected a cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSUInteger row = [indexPath row];
	EditingViewController *tempcontroller = [[EditingViewController alloc] initWithNibName:@"EditRateView" bundle:nil];
	NSString *recordTypeField;
	
	if (tableView == [[self searchDisplayController] searchResultsTableView]) {
		[appDelegate setWorkingCurrencyToThisRecord:[[self searchResults] objectAtIndex:indexPath.row]];
		recordTypeField = [[[self searchResults] objectAtIndex:indexPath.row] recordType];
	} else {
		[appDelegate setWorkingCurrencyToThisRecord:[[appDelegate rates] objectAtIndex:row]];
		recordTypeField = [[appDelegate objectInRatesAtIndex:indexPath.row] recordType];
	}

	if ([recordTypeField isEqualToString:@"F"]) {
		tempcontroller.typeOfEdit = 1;  //Editing internal rate
	} else {
		tempcontroller.typeOfEdit = 2;	//Editing a custom rate
	}

	tempcontroller.delegate = self;
	tempcontroller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:tempcontroller animated:YES];
	
	[tempcontroller release];
}

//---------------------------
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (tableView == [[self searchDisplayController] searchResultsTableView])
		return NO;
	else 
		return YES;
}

//---------------------------
// Set editing buttons
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[appDelegate objectInRatesAtIndex:indexPath.row] recordType] isEqualToString:@"F"]) {
		return UITableViewCellEditingStyleNone;
	} 
	
	return UITableViewCellEditingStyleDelete;
	
}

//---------------------------
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
		RateRecord *ratePointer = [[[RateRecord alloc] init] autorelease];
		ratePointer = [appDelegate objectInRatesAtIndex:indexPath.row];
		
		if ( [ratePointer.recordKey intValue] == appDelegate.intFromRecord ||
			 [ratePointer.recordKey intValue] == appDelegate.intToRecord ||
			 [ratePointer.recordKey intValue] == appDelegate.intMasterRecord) {
			
			NSString *whichOne;
			if ([ratePointer.recordKey intValue] == appDelegate.intFromRecord)
				whichOne = NSLocalizedString(@"FROM",@"FROM");
			if ([ratePointer.recordKey intValue] == appDelegate.intToRecord)
				whichOne = NSLocalizedString(@"TO",@"TO");
			if ([ratePointer.recordKey intValue] == appDelegate.intMasterRecord)
				whichOne = NSLocalizedString(@"MASTER",@"MASTER");

			NSString *format  = NSLocalizedString(@"Cannot Delete a currency when set as To, From or Master", nil);
			NSString *message = [NSString stringWithFormat:format, whichOne]; 
			
			UIAlertView* alertView = [[UIAlertView alloc] 
									  initWithTitle:NSLocalizedString(@"Alert",@"Alert") 
									  message:message
									  delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			
			return;
			
		} else {
			// Delete the row from the data source
			RateRecord *ratePointer = [[[RateRecord alloc] init] autorelease];
			ratePointer = [appDelegate objectInRatesAtIndex:indexPath.row];
			[appDelegate deleteFromDatabaseThisRecord:ratePointer.recordKey];
			
			[tableCurrencies deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			
			//Reset moved pointers
			[appDelegate resetToFromMasterPositions];
			
			//Persist
			[appDelegate saveBackDatabase];
			[appDelegate readOutDatabase];
			
			[tableCurrencies reloadData];
		}

    }   
	
}

//---------------------------
// Can Move a cell ?
- (BOOL) tableView: (UITableView *) tableView canMoveRowAtIndexPath: (NSIndexPath *) indexPath {
	return YES;
}

//---------------------------
// Moved a cell
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
	RateRecord *rateToMove = [[[appDelegate rates] objectAtIndex:sourceIndexPath.row] retain];	
	//Make the move
	[[appDelegate rates] removeObjectAtIndex:sourceIndexPath.row];
    [[appDelegate rates] insertObject:rateToMove atIndex:destinationIndexPath.row];
    [rateToMove release];
	
	//Reset moved pointers
	[appDelegate resetToFromMasterPositions];
	
	//Persist
	[appDelegate saveBackDatabase];
	[appDelegate readOutDatabase];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}


- (void)dealloc {
	
	[searchResults release], searchResults = nil;
	[savedSearchTerm release], savedSearchTerm = nil;
    [super dealloc];
}

#pragma mark Editing Controller Delegate stuff
//--------------------------------------------------------------------
- (void)editingViewControllerDidFinish:(EditingViewController *)controller {
	
	[self dismissModalViewControllerAnimated:YES];
	
	//Check if we are coming back from an edit during a search
	[[self searchResults] removeAllObjects];
	[self handleSearchForTerm:[self savedSearchTerm]];
	if ([[self searchResults] count] > 0) {
		[[[self searchDisplayController] searchResultsTableView] reloadData];
	}

}


#pragma mark searchbar functions

- (void)handleSearchForTerm:(NSString *)searchTerm {
	[self setSavedSearchTerm:searchTerm];
	
	if ([self searchResults] == nil)
	{
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[self setSearchResults:array];
		[array release], array = nil;
	}
	
	[[self searchResults] removeAllObjects];
	
	if ([[self savedSearchTerm] length] != 0)
	{
		for (RateRecord *grabbaRate in [appDelegate rates])
		{
			if ([grabbaRate.currencyDesc rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
			{
				[[self searchResults] addObject:grabbaRate];
			}
		}
	}
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	
	navBarButtonAdd.enabled = NO;
	navBarButtonEdit.enabled = NO;
	
	[self handleSearchForTerm:searchString];
	return YES;
}


- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	
	navBarButtonAdd.enabled = YES;
	navBarButtonEdit.enabled = YES;
	[self setSavedSearchTerm:nil];
	[tableCurrencies reloadData];
}




@end

