/*
 AboutTabViewController.m
 
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

#import "AboutTabViewController.h"

@implementation AboutTabViewController

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	webview = [[UIWebView alloc] init];
	self.view = webview;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	 webview.delegate = self;
	 
	 NSString *path;
	 NSBundle *thisBundle = [NSBundle mainBundle];
	 
	 webview.backgroundColor = [UIColor colorWithRed:148.0/256.0 green:148.0/256.0 blue:148.0/256.0 alpha:0.0];
	 webview.opaque = YES;
	 path = [thisBundle pathForResource:@"instructions" ofType:@"html"];
	 
	 NSURL * instructionsURL = [[NSURL alloc] initFileURLWithPath:path];
	 [webview loadRequest:[NSURLRequest requestWithURL:instructionsURL]];
	 
	 [super viewDidLoad];	 
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	
	if(navigationType == UIWebViewNavigationTypeLinkClicked) {
		// [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com"]];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://en.wikipedia.org/wiki/Borda_count"]];

		return NO;
	}
	
	return YES;
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
