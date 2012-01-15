/*
 ResultsTabViewController.m
 
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

#import "ResultsTabViewController.h"
#import "Option.h"
#import "Voter.h"
#import "PreferencePair.h"
#import "Let_s_DecideAppDelegate.h"
#import "ResultsTableViewController.h"

@implementation ResultsTabViewController

@synthesize winningOption;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
	
	ResultsTableViewController *rtv = [[[ResultsTableViewController alloc] init] autorelease];
	ad.runc = [[UINavigationController alloc] initWithRootViewController:rtv];
	
	[self.view addSubview:ad.runc.view];
}

- (void)viewWillAppear:(BOOL)animated {
	Let_s_DecideAppDelegate *ad = (Let_s_DecideAppDelegate * )[[UIApplication sharedApplication] delegate];
	[ad.runc viewWillAppear:animated];
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