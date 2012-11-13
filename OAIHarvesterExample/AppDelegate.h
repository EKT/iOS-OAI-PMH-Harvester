//
//  AppDelegate.h
//  OAIHarvesterExample
//
//  Created by Kostas Stamatis on 11/1/12.
//  Copyright (c) 2012 Kostas Stamatis. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@class IdentifyViewController;
@class AppDelegate;

extern AppDelegate* oaiApp;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) IdentifyViewController *viewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void) saveContextWithError:(NSError **)error;
- (NSURL *)applicationDocumentsDirectory;

@end
