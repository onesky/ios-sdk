//
//  TransSampleAppDelegate.m
//  TransSample
//
//  Created by Ratson on 7/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TransSampleAppDelegate.h"
#import "RootViewController.h"

@implementation TransSampleAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)showConfirmAlert:(NSString*)msg
{
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Alert"];
	[alert setMessage:msg];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"OK"];
	[alert show];
	[alert release];
}

- (void)helperDidFinishLoading:(OneSkyHelper*)helper {
    [self showConfirmAlert:@"Finished download translations"];
}

- (void)helper:(OneSkyHelper*)helper didFailWithError:(NSError*)error {
    [self showConfirmAlert:@"Failed downloading translations"];
}

- (void)helper:(OneSkyHelper*)helper didFailToFindStringKey:(NSString*)key {
    
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    {
        OneSkyHelper* helper = [OneSkyHelper sharedHelper];
        helper.platformId = 868;
        helper.key = @"535e19975998c52ad19470eb4805f515";
        helper.defaultTableName = @"Localizable.strings";
        helper.delegate = self;
        helper.debug = YES;
        [helper setFallbackJsonNamed:@"onesky.json"];
        [helper checkForUpdateOfPreferredLanguage];
        NSLog(@"history====%@", helper.history);
    }

    // Add the navigation controller's view to the window and display.
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

