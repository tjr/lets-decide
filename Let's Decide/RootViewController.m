/*
 RootViewController.m
 
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

#import "RootViewController.h"

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	aboutTab = [[AboutTabViewController alloc] init];
	optionsTab = [[OptionsTabViewController alloc] init];
	votersTab = [[VotersTabViewController alloc] init];
	resultsTab = [[ResultsTabViewController alloc] init];
	
	aboutTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"About" image:[UIImage imageNamed:@"113-navigation.png"] tag:0];
	optionsTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Options" image:[UIImage imageNamed:@"98-palette.png"] tag:0];
	votersTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Voters" image:[UIImage imageNamed:@"112-group.png"] tag:0];
	resultsTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Results" image:[UIImage imageNamed:@"138-scales.png"] tag:0];
	
	NSArray *tabsArray = [NSArray arrayWithObjects:aboutTab, optionsTab, votersTab, resultsTab, nil];
	
	[self setViewControllers:tabsArray animated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end
