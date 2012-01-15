/*
 ShakeView.m
 
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

#import "ShakeView.h"


@implementation ShakeView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
    }
    return self;
}

-(void) setShakeDelegate:(id)new_delegate {
	view_delegate = new_delegate;
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ( event.subtype == UIEventSubtypeMotionShake ) {
		if ([view_delegate respondsToSelector:@selector(shakeHappened:)]) {
			[view_delegate shakeHappened:self];
        }
        
		// Any generic non-view-controller-specific shake code can go here.
    }
	
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] ) {
        [super motionEnded:motion withEvent:event];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)dealloc {
    [super dealloc];
}

@end
