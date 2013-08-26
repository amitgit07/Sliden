//
//  NAPAppDelegate.m
//  Silden
//
//  Created by Amit Priyadarshi on 28/04/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SAppDelegate.h"


#import "NAPLandingVc.h"

#import "SProfileVc.h"
#import "SShowVc.h"
#import "SExplorerVc.h"
#import "SHomeVc.h"
#import "SMoreVc.h"
#import <Crashlytics/Crashlytics.h>

@implementation SAppDelegate {
    UILabel* _statusMsgLabel;
    UILabel* _progressLabel;
}
@synthesize launchedOtherApplication=_launchedOtherApplication;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)dealloc
{
    [_window release];
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [_landingNavigationCntrl release];
    [_tabBarController release];
    [super dealloc];
}
- (void)createScreenLock {
    _screenLock = [[UIWindow alloc] initWithFrame:self.window.bounds];
    [_screenLock setBackgroundColor:[UIColor colorWithPatternImage:Image(@"screenLock.png")]];
    
    _imgView = [[UIImageView alloc] init];
    [_imgView setFrame:CGRectMake(0, 0, 61, 71)];
    [_imgView setCenter:self.window.center];
    _imgView.layer.shadowColor = [[UIColor blackColor] CGColor];
    _imgView.layer.shadowOffset = CGSizeMake(4.0f, 3.0f);
    _imgView.layer.shadowRadius = 5.0f;
    _imgView.layer.shadowOpacity = 0.60f;
//    _imgView.layer.borderColor = [[UIColor whiteColor] CGColor];
//    _imgView.layer.borderWidth = 1.0;
    [_imgView setAnimationImages:[NSArray arrayWithObjects:Image(@"1.png"),
                                  Image(@"2-15d.png"),
                                  Image(@"1.png"),
                                  Image(@"1.png"),
                                  Image(@"3-30d.png"),
                                  Image(@"2-15d.png"),
                                  Image(@"2-15d.png"),
                                  Image(@"1.png"), nil]];
    [_imgView setAnimationDuration:2.0f];
    [_imgView setAnimationRepeatCount:0];
    [_imgView setBackgroundColor:[UIColor clearColor]];
    [_screenLock addSubview:_imgView];
    
    _statusMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 300, 40)];
    [_statusMsgLabel setTextColor:[UIColor whiteColor]];
    [_statusMsgLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [_statusMsgLabel setNumberOfLines:2];
    [_statusMsgLabel setTextAlignment:NSTextAlignmentCenter];
    [_statusMsgLabel setBackgroundColor:[UIColor clearColor]];
    [_screenLock addSubview:_statusMsgLabel];

    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 80, 220, 20)];
    [_progressLabel setTextColor:[UIColor whiteColor]];
    [_progressLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [_progressLabel setNumberOfLines:1];
    [_progressLabel setTextAlignment:NSTextAlignmentCenter];
    [_progressLabel setBackgroundColor:[UIColor clearColor]];
    [_screenLock addSubview:_progressLabel];

    [self.window addSubview:_screenLock];
    [_screenLock setHidden:YES];
}
- (void)configureTabBar {
    SHomeVc* tab1Vc = [[[SHomeVc alloc] initWithNibName:@"SHomeVc" bundle:nil] autorelease];
    UINavigationController* navC1 = [[[UINavigationController alloc] initWithRootViewController:tab1Vc] autorelease];
//    [navC1 setNavigationBarHidden:YES];

    SExplorerVc* tab2Vc = [[[SExplorerVc alloc] initWithNibName:@"SExplorerVc" bundle:nil] autorelease];
    UINavigationController* navC2 = [[[UINavigationController alloc] initWithRootViewController:tab2Vc] autorelease];
//    [navC2 setNavigationBarHidden:YES];

    SShowVc* tab3Vc = [[[SShowVc alloc] initWithNibName:@"SShowVc" bundle:nil] autorelease];
    UINavigationController* navC3 = [[[UINavigationController alloc] initWithRootViewController:tab3Vc] autorelease];
//    [navC3 setNavigationBarHidden:YES];

    SProfileVc* tab4Vc = [[[SProfileVc alloc] initWithNibName:@"SProfileVc" bundle:nil] autorelease];
    UINavigationController* navC4 = [[[UINavigationController alloc] initWithRootViewController:tab4Vc] autorelease];
//    [navC4 setNavigationBarHidden:YES];

    SMoreVc* tab5Vc = [[[SMoreVc alloc] initWithNibName:@"SMoreVc" bundle:nil] autorelease];
    UINavigationController* navC5 = [[[UINavigationController alloc] initWithRootViewController:tab5Vc] autorelease];
    [navC5 setNavigationBarHidden:YES];

    self.tabBarController = [[[STabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = @[navC1,navC2,navC3,navC4,navC5];
    [self.tabBarController addCenterButtonWithImage:Image(@"movie_icon.png") highlightImage:Image(@"movie_icon_selected.png")];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor colorWithWhite:0.2f alpha:0.9f] }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor] }
                                             forState:UIControlStateSelected];

    UIImage *buttonImage = [UIImage imageNamed:@"tabItemOff.png"];
    UIImage *highlightImage = [UIImage imageNamed:@"tabItemSelected.png"];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    CGFloat heightDifference = buttonImage.size.height - self.tabBarController.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.tabBarController.tabBar.center;
    else
    {
        CGPoint center = self.tabBarController.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    [self.tabBarController.view addSubview:button];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:PARSE_APP_ID clientKey:PARSE_CLIENT_KEY];
    _launchedOtherApplication = NO;
    
    [Crashlytics startWithAPIKey:@"448ca20f309319feb66480225c0046491941db6f"];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    self.landingNavigationCntrl = [[[UINavigationController alloc] init] autorelease];
    NAPLandingVc* langindVc = [[[NAPLandingVc alloc] initWithNibName:@"NAPLandingVc" bundle:nil] autorelease];
    [self.landingNavigationCntrl setViewControllers:[NSArray arrayWithObject:langindVc]];
    [self.landingNavigationCntrl setNavigationBarHidden:YES];

    [self configureTabBar];
    
    self.window.rootViewController = self.landingNavigationCntrl;
    [self.window makeKeyAndVisible];
    
    [self setNavigationBarBackground:YES];
//    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    [_activity setHidesWhenStopped:YES];
//    [_activity setCenter:self.window.center];
//    [self.window addSubview:_activity];
    
    [self createScreenLock];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (_launchedOtherApplication) {
        [self showActivity:NO];
        _launchedOtherApplication = NO;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}
/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/
- (void)showLockScreenStatusWithMessage:(NSString*)msg {
    _statusMsgLabel.text = msg;
}
- (void)setLockScreenProgress:(float)value {
    static Byte i = 0;
    if (value < 1.0f && value > 0.01f) {
        _progressLabel.text = [NSString stringWithFormat:@"%0.2f %@",value*100,@"%"];
    }
    else {
        static NSString* str = nil;
        switch ((i++)%4) {
            case 0:
                str=@"...   ";
                break;
            case 1:
                str=@" ...  ";
                break;
            case 2:
                str=@"  ... ";
                break;
            case 3:
                str=@"   ...";
                break;
                
            default:
                break;
        }
        _progressLabel.text = str;
    }
}
- (void)showActivity:(BOOL)show {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_screenLock setHidden:!show];
        [_statusMsgLabel setHidden:!show];
        [_progressLabel setHidden:!show];
        if (show) {
            NSLog(@"showing");
            [self.window bringSubviewToFront:_screenLock];
            [_imgView startAnimating];
            [_progressLabel setFrame:CGRectMake(_progressLabel.frame.origin.x, _imgView.frame.origin.y-20, _progressLabel.frame.size.width, _progressLabel.frame.size.height)];
        }
        else {
            NSLog(@"hiding");
            [_imgView stopAnimating];
            [_statusMsgLabel setText:@""];
            [_progressLabel setText:@""];
        }
    });
}
- (void)setNavigationBarBackground:(BOOL)withAppName {
    if (withAppName) {
        UIImage *navBackgroundImage = [UIImage imageNamed:@"sliden_top_bar.png"];
        [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                               [UIColor whiteColor], UITextAttributeTextColor,
                                                               [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],UITextAttributeTextShadowColor,
                                                               [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                               UITextAttributeTextShadowOffset,
                                                               nil]];
    }
    else {
        UIImage *navBackgroundImage = [UIImage imageNamed:@"top_bar_without_txt.png"];
        [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                               [UIColor whiteColor], UITextAttributeTextColor,
                                                               [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],UITextAttributeTextShadowColor,
                                                               [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                               UITextAttributeTextShadowOffset,
                                                               nil]];
    }
    UIImage *backButtonImage = [[UIImage imageNamed:@"back_button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 6)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}
#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"sliden" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"sliden.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
