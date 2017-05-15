//
//  TodayViewController.h
//  BTCWidget
//
//  Created by Jay Greco on 5/12/17.
//  Copyright © 2017 Jay Greco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "definitions.h"

@interface TodayViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
- (IBAction)launchApp:(id)sender;

@end
