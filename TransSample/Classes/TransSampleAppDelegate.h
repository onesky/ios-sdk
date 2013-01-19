//
//  TransSampleAppDelegate.h
//  TransSample
//
//  Created by Ratson on 7/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransSampleAppDelegate : NSObject <UIApplicationDelegate, OneSkyHelperDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

