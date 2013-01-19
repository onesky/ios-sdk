//
//  RootViewController.h
//  TransSample
//
//  Created by Ratson on 7/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController {
    IBOutlet UIBarButtonItem *refreshButton;
    IBOutlet UIBarButtonItem *translateButton;
}

- (IBAction)refreshAction:(id)sender;
- (IBAction)translateAction:(id)sender;

@end
