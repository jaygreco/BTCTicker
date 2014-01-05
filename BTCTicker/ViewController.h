//
//  ViewController.h
//  BTCTicker
//
//  Created by Jay Greco on 12/21/13.
//  Copyright (c) 2013 Jay Greco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UITextField *lowInput;
@property (weak, nonatomic) IBOutlet UITextField *highInput;
@property (weak, nonatomic) IBOutlet UISwitch *alertsSwitch;

- (IBAction)exitKeyboard:(id)sender;
- (IBAction)applyChanges:(id)sender;
- (IBAction)manualRefresh:(id)sender;

@end
