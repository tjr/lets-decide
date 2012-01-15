/*
 ResultsTableViewController.m
 
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

#import "ResultsTableViewController.h"
#import "Option.h"
#import "Voter.h"
#import "PreferencePair.h"
#import "Let_s_DecideAppDelegate.h"

@implementation ResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Results";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self determineWinner];
	[self.tableView reloadData];
	
	if (numberOfRows == 0) {
		UIAlertView *alert =
		[[UIAlertView alloc] initWithTitle:@"No Results Yet"
								   message:@"You need to add both options and voters for results to show up."
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
	
	NSSortDescriptor *myDesc = [[NSSortDescriptor alloc] initWithKey:@"bordaCountRanking" ascending:NO];
	NSArray *aDescriptors = [[NSArray alloc] initWithObjects:myDesc, nil];
	[fetchRequest setSortDescriptors:aDescriptors];
	
    NSError *error;
    NSArray *items = [ad.managedObjectContext
					  executeFetchRequest:fetchRequest error:&error];
	
    [fetchRequest release];
	
	fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"Voter" 
						 inManagedObjectContext:ad.managedObjectContext];
    [fetchRequest setEntity:entity];
	
    NSArray *voters = [ad.managedObjectContext
					  executeFetchRequest:fetchRequest error:&error];
	
    [fetchRequest release];
	
	numberOfVoters = [voters count];
	
	if (numberOfVoters == 0) {
		numberOfRows = 0;
	}
	else {
		numberOfRows = [items count];
	}
	
	return numberOfRows;;
}

- (void) ascertainNumberOfRows {
    // Return the number of rows in the section.
    Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Option" 
											  inManagedObjectContext:ad.managedObjectContext];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor *myDesc = [[NSSortDescriptor alloc] initWithKey:@"bordaCountRanking" ascending:NO];
	NSArray *aDescriptors = [[NSArray alloc] initWithObjects:myDesc, nil];
	[fetchRequest setSortDescriptors:aDescriptors];
	
    NSError *error;
    NSArray *items = [ad.managedObjectContext
					  executeFetchRequest:fetchRequest error:&error];
	
    [fetchRequest release]; 
	
	numberOfRows = [items count];
	
	return;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Option" 
											  inManagedObjectContext:ad.managedObjectContext];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor *myDesc = [[NSSortDescriptor alloc] initWithKey:@"bordaCountRanking" ascending:NO];
	NSArray *aDescriptors = [[NSArray alloc] initWithObjects:myDesc, nil];
	[fetchRequest setSortDescriptors:aDescriptors];
	
    NSError *error;
    NSArray *items = [ad.managedObjectContext
					  executeFetchRequest:fetchRequest error:&error];
	
    [fetchRequest release]; 
	
	Option *o = [items objectAtIndex:indexPath.row];
	
	NSMutableString *textValue = [[NSMutableString alloc] initWithString:@""];
	[textValue appendString:[[NSNumber numberWithInt:(indexPath.row + 1)] stringValue]];
	[textValue appendString:@". "];
	[textValue appendString:o.value];
	[textValue appendString:@" ("];
	[textValue appendString:[o.bordaCountRanking stringValue]];
	if ([o.bordaCountRanking intValue] == 1)
		[textValue appendString:@" point)"];
	else
		[textValue appendString:@" points)"];
	
	cell.textLabel.text = textValue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
}

/* Calculate the results. */

- (void) determineWinner {
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
	
	// Clear out existing rankings.
	for (PreferencePair *p in pairs) {
		p.option.bordaCountRanking = [NSNumber numberWithInt:0];
	}
	
	[ad saveContext];
	
	[self ascertainNumberOfRows];
	
	// Build new rankings.
	for (PreferencePair *p in pairs) {
		int multiplier = numberOfRows - [p.rank intValue];
		p.option.bordaCountRanking = [NSNumber numberWithInt:([p.option.bordaCountRanking intValue] + multiplier)];
	}
	
	[ad saveContext];
}

/* Memory management. */

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