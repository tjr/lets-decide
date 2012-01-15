/*
 OptionsTableViewController.m
 
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

#import "OptionsTableViewController.h"
#import "OptionsTabViewController.h"
#import "AddOptionViewController.h"
#import "Let_s_DecideAppDelegate.h"
#import "Option.h"
#import "PreferencePair.h"
#import "ShakeView.h"

@implementation OptionsTableViewController

- (void) pressedNew: (id) sender {
	Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
	
	AddOptionViewController *aovc = [[AddOptionViewController alloc] init];
	[ad.otunc pushViewController:aovc animated:YES];
	[aovc release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Options";
	
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

/* Table View Methods. */

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
	
	Option *o = [items objectAtIndex:indexPath.row];
	
	cell.textLabel.text = o.value;
    
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
		
		// Get the option value at the selected table entry.
		Option *o = [items objectAtIndex:indexPath.row];
		
		// Delete the preference pairs containing the deleted option,
		// and reorder the subsequent preference pairs to compensate for the
		// deleted option.
		fetchRequest = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"PreferencePair" 
							 inManagedObjectContext:ad.managedObjectContext];
		[fetchRequest setEntity:entity];
		
		NSSortDescriptor *sortByVoter = [[NSSortDescriptor alloc] initWithKey:@"voter.name" ascending:YES];
		NSSortDescriptor *sortByRank = [[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES];
		aDescriptors = [[NSArray alloc] initWithObjects:sortByVoter, sortByRank, nil];
		[fetchRequest setSortDescriptors:aDescriptors];
		
		NSArray *pairs = [ad.managedObjectContext
						  executeFetchRequest:fetchRequest error:&error];
		[fetchRequest release];
		
		BOOL modifyRank = NO;
		for (PreferencePair *p in pairs) {
			if ([p.rank intValue] == 0) {
				modifyRank = NO;
			}
			if ([p.option.value isEqualToString:o.value]) {
				[ad.managedObjectContext deleteObject:p];
				modifyRank = YES;
			}
			else if (modifyRank == YES) {
				p.rank = [NSNumber numberWithInt:[p.rank intValue] - 1];
			}
		}
		
		// Delete the option itself.
		[ad.managedObjectContext deleteObject:o];
		
		[ad saveContext];
		
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void) shakeHappened:(ShakeView*)view {
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
		
		// Delete all options.
		for (Option *o in items) {
			[ad.managedObjectContext deleteObject:o];
		}
		
		// Get the preference pairs
		fetchRequest = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"PreferencePair" 
							 inManagedObjectContext:ad.managedObjectContext];
		[fetchRequest setEntity:entity];
		
		NSSortDescriptor *sortByVoter = [[NSSortDescriptor alloc] initWithKey:@"voter.name" ascending:YES];
		NSSortDescriptor *sortByRank = [[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES];
		aDescriptors = [[NSArray alloc] initWithObjects:sortByVoter, sortByRank, nil];
		[fetchRequest setSortDescriptors:aDescriptors];
		
		NSArray *pairs = [ad.managedObjectContext
						  executeFetchRequest:fetchRequest error:&error];
		[fetchRequest release];
		
		for (PreferencePair *p in pairs) {
			[ad.managedObjectContext deleteObject:p];
		}
		
		[ad saveContext];
		
		[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
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

