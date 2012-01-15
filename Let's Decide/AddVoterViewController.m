/*
 AddVoterViewController.m
 
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

#import "AddVoterViewController.h"
#import "Voter.h"
#import "Let_s_DecideAppDelegate.h"
#import "EnterPreferencesViewController.h"
#import "Option.h"
#import "PreferencePair.h"


@implementation AddVoterViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	[textField resignFirstResponder];
	return YES;
}

- (void) pressedAddVoterButton: (id) sender {
	
	NSString *newVoterName = voterTextField.text;
	
	NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
	NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
	
	NSArray *parts = [newVoterName componentsSeparatedByCharactersInSet:whitespaces];
	NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
	newVoterName = [filteredArray componentsJoinedByString:@" "];
	
	
	if ([newVoterName isEqualToString:@""]) {
		UIAlertView *alert =
			[[UIAlertView alloc] initWithTitle:@"Blank Name"
									   message:@"Please enter a name."
									  delegate:nil
							 cancelButtonTitle:@"OK"
							 otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
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
	
	for (Voter *v in items) {
		if ([newVoterName isEqualToString:v.name]) {
			UIAlertView *alert =
			[[UIAlertView alloc] initWithTitle:@"Duplicate Name"
									   message:@"Please enter a unique name, not already in the list of voters."
									  delegate:nil
							 cancelButtonTitle:@"OK"
							 otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
	}
	
	Voter *newVoter = (Voter *)[NSEntityDescription
								   insertNewObjectForEntityForName:@"Voter"
								   inManagedObjectContext:ad.managedObjectContext];
	[newVoter setName:newVoterName];
	
	// Get all of the current options, and build an initial set of preference pairs for
	// the new voter.
	fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"Option" 
											  inManagedObjectContext:ad.managedObjectContext];
    [fetchRequest setEntity:entity];
	
	myDesc = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES];
	aDescriptors = [[NSArray alloc] initWithObjects:myDesc, nil];
	[fetchRequest setSortDescriptors:aDescriptors];

    items = [ad.managedObjectContext
				executeFetchRequest:fetchRequest error:&error];
	
    [fetchRequest release];
	
	int counter = 0;
	PreferencePair *newPreferencePair;
	for (Option *o in items) {
		newPreferencePair =
			(PreferencePair *) [NSEntityDescription
								insertNewObjectForEntityForName:@"PreferencePair"
								inManagedObjectContext:ad.managedObjectContext];
		[newPreferencePair setOption:o];
		[newPreferencePair setVoter:newVoter];
		[newPreferencePair setRank:[NSNumber numberWithInt:counter]];
		[ad saveContext];
		counter++;
	}
	
	EnterPreferencesViewController *epvc = [[EnterPreferencesViewController alloc] init];
	epvc.voter = newVoter;
	[ad.vtunc pushViewController:epvc animated:YES];
	[epvc release];
}

// FIXME: Why is this code here, instead of in loadView?
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"New Voter";
	self.navigationItem.leftBarButtonItem.title	= @"Cancel";
	
	voterTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, 280, 30)];
	voterTextField.delegate = self;
	voterTextField.text = @"";
	voterTextField.borderStyle = UITextBorderStyleRoundedRect;
	[self.view addSubview:voterTextField];
	
	UIButton *addVoterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	addVoterButton.frame = CGRectMake(20, 70, 280, 30);
	[addVoterButton addTarget:self 
						action:@selector(pressedAddVoterButton:)
			  forControlEvents:UIControlEventTouchDown];
	[addVoterButton setTitle:@"Add Voter" forState:UIControlStateNormal];
	addVoterButton.showsTouchWhenHighlighted = YES;
	[self.view addSubview:addVoterButton];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end
