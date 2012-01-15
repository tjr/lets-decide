/*
 VotersTableViewController.m
 
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

#import "VotersTableViewController.h"
#import "Voter.h"
#import "AddVoterViewController.h"
#import "Let_s_DecideAppDelegate.h"
#import "EnterPreferencesViewController.h"
#import "PreferencePair.h"
#import "ShakeView.h"

@implementation VotersTableViewController

- (void) pressedNew: (id) sender {
	Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
	
	AddVoterViewController *avvc = [[AddVoterViewController alloc] init];
	[ad.vtunc pushViewController:avvc animated:YES];
	[avvc release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Voters";
	
	UIBarButtonItem *newOptionButton = [[UIBarButtonItem alloc] initWithTitle:@"New"
																		style:UIBarButtonItemStyleBordered
																	   target:self
																	   action:@selector(pressedNew:)];
	
	self.navigationItem.rightBarButtonItem = newOptionButton;
	self.navigationItem.leftBarButtonItem = nil;
	
	ShakeView *sv = [[ShakeView alloc] init];
	[sv setShakeDelegate:self];
	[sv becomeFirstResponder];
	[self.view addSubview:sv];
	[sv release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
}

-(void) shakeHappened:(ShakeView*)view {
	Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voter" 
											  inManagedObjectContext:ad.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error;
	NSArray *items = [ad.managedObjectContext
					  executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release]; 
	
	// Delete all voters.
	for (Voter *v in items) {
		[ad.managedObjectContext deleteObject:v];
	}
	
	// Get the preference pairs
	fetchRequest = [[NSFetchRequest alloc] init];
	entity = [NSEntityDescription entityForName:@"PreferencePair" 
						 inManagedObjectContext:ad.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSArray *pairs = [ad.managedObjectContext
					  executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	for (PreferencePair *p in pairs) {
		[ad.managedObjectContext deleteObject:p];
	}
	
	[ad saveContext];
	
	[self.tableView reloadData];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voter" 
											  inManagedObjectContext:ad.managedObjectContext];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor *myDesc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
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
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voter" 
											  inManagedObjectContext:ad.managedObjectContext];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor *myDesc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *aDescriptors = [[NSArray alloc] initWithObjects:myDesc, nil];
	[fetchRequest setSortDescriptors:aDescriptors];
	
    NSError *error;
    NSArray *items = [ad.managedObjectContext
					  executeFetchRequest:fetchRequest error:&error];
	
    [fetchRequest release];
	
	Voter *v = [items objectAtIndex:indexPath.row];
	
	cell.textLabel.text = v.name;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voter" 
												  inManagedObjectContext:ad.managedObjectContext];
		[fetchRequest setEntity:entity];
		
		NSSortDescriptor *myDesc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
		NSArray *aDescriptors = [[NSArray alloc] initWithObjects:myDesc, nil];
		[fetchRequest setSortDescriptors:aDescriptors];
		
		NSError *error;
		NSArray *items = [ad.managedObjectContext
						  executeFetchRequest:fetchRequest error:&error];
		
		[fetchRequest release]; 
		
		// Get the voter value at the selected table entry.
		Voter *v = [items objectAtIndex:indexPath.row];
		
		// Go through and clear preference pairs for this voter.
		fetchRequest = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"PreferencePair" 
							 inManagedObjectContext:ad.managedObjectContext];
		[fetchRequest setEntity:entity];
	
		NSArray *pairs = [ad.managedObjectContext
						  executeFetchRequest:fetchRequest error:&error];
		
		for (PreferencePair *p in pairs) {
			if ([p.voter.name isEqualToString:v.name]) {
				[ad.managedObjectContext deleteObject:p];
			}
		}
		
		// Delete the voter itself.
		[ad.managedObjectContext deleteObject:v];
		
		[ad saveContext];
		
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voter" 
											  inManagedObjectContext:ad.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *myDesc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *aDescriptors = [[NSArray alloc] initWithObjects:myDesc, nil];
	[fetchRequest setSortDescriptors:aDescriptors];
	
	NSError *error;
	NSArray *items = [ad.managedObjectContext
					  executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release]; 
	
	// Get the option value at the selected table entry.
	Voter *v = [items objectAtIndex:indexPath.row];
	
	EnterPreferencesViewController *epvc = [[EnterPreferencesViewController alloc] init];
	epvc.voter = v;
	[ad.vtunc pushViewController:epvc animated:YES];
	[epvc release];
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
