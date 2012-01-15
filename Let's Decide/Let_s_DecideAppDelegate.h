/*
 Let_s_DecideAppDelegate.h
 
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
#import "RootViewController.h"

@interface Let_s_DecideAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

// Root view controller.
@property (nonatomic, retain) IBOutlet RootViewController *viewController;

// Custom navigation controllers.
@property (nonatomic, retain) UINavigationController *otunc;
@property (nonatomic, retain) UINavigationController *vtunc;
@property (nonatomic, retain) UINavigationController *runc;

// Core Data Properties.
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Core Data methods.
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
