/*
 AddOptionViewController.m
 
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

#import "AddOptionViewController.h"
#import "Let_s_DecideAppDelegate.h"
#import "Option.h"
#import "Voter.h"
#import "PreferencePair.h"

@implementation AddOptionViewController

@synthesize optionValue;

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	optionValue = optionTextField.text;

	[textField resignFirstResponder];
	return YES;
}

- (void) pressedAddOptionButton: (id) sender {
	NSString *newOptionName = optionTextField.text;
	
	NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
	NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
	
	NSArray *parts = [newOptionName componentsSeparatedByCharactersInSet:whitespaces];
	NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
	newOptionName = [filteredArray componentsJoinedByString:@" "];
	
	if ([newOptionName isEqualToString:@""]) {
		UIAlertView *alert =
		[[UIAlertView alloc] initWithTitle:@"Blank Option"
								   message:@"Please enter an option."
								  delegate:nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Option" 
											  inManagedObjectContext:ad.managedObjectContext];
    [fetchRequest setEntity:entity];
	
    NSError *error;
    NSArray *items = [ad.managedObjectContext
					  executeFetchRequest:fetchRequest error:&error];
	
    [fetchRequest release];
	
	for (Option *o in items) {
		if ([newOptionName isEqualToString:o.value]) {
			UIAlertView *alert =
			[[UIAlertView alloc] initWithTitle:@"Duplicate Option"
									   message:@"Please enter a unique option, not already in the list of options."
									  delegate:nil
							 cancelButtonTitle:@"OK"
							 otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
	}
	
	Option *newOption = (Option *)[NSEntityDescription
									  insertNewObjectForEntityForName:@"Option"
									  inManagedObjectContext:ad.managedObjectContext];
	[newOption setValue:newOptionName];
	[ad saveContext];
	
	// Go through all of the preference pairs for each voter and add the new option.
	fetchRequest = [[NSFetchRequest alloc] init];
	entity = [NSEntityDescription entityForName:@"Voter" 
						 inManagedObjectContext:ad.managedObjectContext];
	[fetchRequest setEntity:entity];

	NSArray *voters = [ad.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	for (Voter *v in voters) {
		
		fetchRequest = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"PreferencePair" 
												  inManagedObjectContext:ad.managedObjectContext];
		[fetchRequest setEntity:entity];
		
		int newRank = [items count]; // we want one higher index; 1 pair = count 1 = rank 0
		
		PreferencePair *newPreferencePair = 
			(PreferencePair *) [NSEntityDescription
								insertNewObjectForEntityForName:@"PreferencePair"
								inManagedObjectContext:ad.managedObjectContext];
		[newPreferencePair setVoter:v];
		[newPreferencePair setOption:newOption];
		[newPreferencePair setRank:[NSNumber numberWithInt:newRank]];
		[ad saveContext];
	}
	
	
	[ad.otunc popViewControllerAnimated:YES];
}

// FIXME: Why is this code here, instead of in loadView?
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"New Option";
	self.navigationItem.leftBarButtonItem.title	= @"Cancel";
	
	optionTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, 280, 30)];
	optionTextField.delegate = self;
	optionTextField.text = @"";
	optionTextField.borderStyle = UITextBorderStyleRoundedRect;
	[self.view addSubview:optionTextField];
	
	UIButton *addOptionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	addOptionButton.frame = CGRectMake(20, 70, 280, 30);
	[addOptionButton addTarget:self 
						 action:@selector(pressedAddOptionButton:)
			   forControlEvents:UIControlEventTouchDown];
	[addOptionButton setTitle:@"Add Option" forState:UIControlStateNormal];
	addOptionButton.showsTouchWhenHighlighted = YES;
	[self.view addSubview:addOptionButton];
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
