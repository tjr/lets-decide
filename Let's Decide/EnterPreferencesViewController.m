/*
 EnterPreferencesViewController.m
 
 Copyright (C) 2011-2012 Trevis J. Rothwell
 
 This file is part of Let's Decide.
 
 Let's Decide is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Let's Decide is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Let's Decide.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "EnterPreferencesViewController.h"
#import "OptionsTabViewController.h"
#import "Let_s_DecideAppDelegate.h"
#import "Option.h"
#import "Voter.h"
#import "PreferencePair.h"

@implementation EnterPreferencesViewController

@synthesize voter;

- (void) pressedDone: (id) sender {
	Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
	[ad.vtunc popToViewController:[[ad.vtunc viewControllers] objectAtIndex:0] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Order Preferences";
	
	self.tableView.editing = YES;
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
																   style:UIBarButtonItemStyleBordered
																  target:self
																  action:@selector(pressedDone:)];
	
	self.navigationItem.rightBarButtonItem = doneButton;
	self.navigationItem.hidesBackButton = YES;
	
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 28)] autorelease];
	label.backgroundColor = [UIColor darkGrayColor];
	label.font = [UIFont boldSystemFontOfSize:15];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.8];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.text = voter.name;
	self.tableView.tableHeaderView = label;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
	if (numberOfRows == 0) {
		UIAlertView *alert =
		[[UIAlertView alloc] initWithTitle:@"No Options"
								   message:@"Enter some options first, then come back here to sort your preferences."
								  delegate:nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

/* Table View methods. */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	
	Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Option" 
											  inManagedObjectContext:ad.managedObjectContext];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor *myDesc = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES];
	NSArray *aDescriptors = [[NSArray alloc] initWithObjects:myDesc, nil];
	[fetchRequest setSortDescriptors:aDescriptors];
	
    NSError *error;
    NSArray *items = [ad.managedObjectContext
					  executeFetchRequest:fetchRequest error:&error];
	
    [fetchRequest release]; 
	
	numberOfRows = [items count];
	
	return [items count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	
	Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
	
	// We should have a preference pair for every option, for every voter.  So we
	// use the preference pair data to build the table.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"PreferencePair" 
						inManagedObjectContext:ad.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSError *error;
	NSArray *pairs = [ad.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
		for (PreferencePair *p in pairs) {
			if ([p.voter.name isEqualToString:voter.name] && [p.rank intValue] == indexPath.row) {
				cell.textLabel.text = p.option.value;
				return cell;
			}
			else {
				// Haven't found it yet, keep trying...
			}
		}
	
	// If we got this far, then we didn't have a preference pair for the cell.  Return default value.
	cell.textLabel.text = @"";
	
    return cell;
}



 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	 Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
	 
	 NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	 NSEntityDescription *entity = [NSEntityDescription entityForName:@"PreferencePair" 
						  inManagedObjectContext:ad.managedObjectContext];
	 [fetchRequest setEntity:entity];
	 NSSortDescriptor *myDesc = [[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES];
	 NSArray *aDescriptors = [[NSArray alloc] initWithObjects:myDesc, nil];
	 [fetchRequest setSortDescriptors:aDescriptors];
	 NSError *error;
	 NSArray *pairs = [ad.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	 int fromIndex = fromIndexPath.row;
	 int toIndex = toIndexPath.row;
	 
	 for (PreferencePair *p in pairs) {
		 if (![p.voter.name isEqualToString:voter.name])
			 continue;

		 if (fromIndex < toIndex) {
			 if ([p.rank intValue] == fromIndex) {
				 [p setRank:[[NSNumber alloc] initWithInt:toIndex]];
			 }
			 else if ([p.rank intValue] > fromIndex && [p.rank intValue] <= toIndex) {
				 [p setRank:[[NSNumber alloc] initWithInt:([p.rank intValue] - 1)]];
			 }
		 }
		else {
			if ([p.rank intValue] == fromIndex) {
				[p setRank:[[NSNumber alloc] initWithInt:toIndex]];
			}
			else if ([p.rank intValue] < fromIndex && [p.rank intValue] >= toIndex) {
				[p setRank:[[NSNumber alloc] initWithInt:([p.rank intValue] + 1)]];
			}
		}
	 }
	 
	 [ad saveContext];
 }


 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
     // Return NO if you do not want the item to be re-orderable.
     return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView
		   editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {

	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
}

/* Memory management methods. */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end

