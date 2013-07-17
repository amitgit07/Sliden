//
//  NAPAppDelegate.h
//  Silden
//
//  Created by Amit Priyadarshi on 28/04/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "STabBarController.h"


@interface SAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIActivityIndicatorView* _activity;
    UIImageView* _imgView;
    UIWindow* _screenLock;
}

@property (strong, nonatomic) UINavigationController* landingNavigationCntrl;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL launchedOtherApplication;
@property (strong, nonatomic) STabBarController *tabBarController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)showActivity:(BOOL)show;
- (void)setNavigationBarBackground:(BOOL)withAppName;
@end

