/*
 VotersTableViewController.h
 
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

#import <UIKit/UIKit.h>
#import "ShakeView.h"

@interface VotersTableViewController : UITableViewController {
	int numberOfRows;
}

-(void) shakeHappened:(ShakeView*)view;

@end
