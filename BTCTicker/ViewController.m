//
//  ViewController.m
//  BTCTicker
//
//  Created by Jay Greco on 12/21/13.
//  Copyright (c) 2013 Jay Greco. All rights reserved.
//

#import "ViewController.h"
#import "definitions.h"
#import "NotifierBackend.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    //Don't do this on the first launch
    if ([self isAppAlreadyLaunchedOnce]) {
        [self checkNotifications];
        [self checkBackgroundRefresh];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Sync the currency and exchange preferences.
    [NotifierBackend syncCurrency];
    
    //Load the BTC exchange rate data upon startup.
    [self getAsynchronously];
    
    //Run a NSTimer to refresh status automatically.
    [NSTimer scheduledTimerWithTimeInterval:30
                                     target:self
                                   selector:@selector(getAsynchronously)
                                   userInfo:nil
                                    repeats:YES];
    
    //Load the saved alert values fron NSUserDefaults.
    NSInteger lowValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"kLowAlertValue"] intValue];
    NSInteger highValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"kHighAlertValue"] intValue];
    BOOL alertsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAlertsEnabled"];
    
    //Set up the alerts fields to reflect their states as stored with NSUserDefaults.
    self.priceLabel.adjustsFontSizeToFitWidth = YES;
    self.alertsSwitch.on = alertsEnabled;
    self.lowInput.text = [NSString stringWithFormat:@"%ld",(long)lowValue];
    self.highInput.text = [NSString stringWithFormat:@"%ld",(long)highValue];
}

- (void)didLoadFromNotification {
    //Clear the alerts and disable alerts in the future.
    BOOL alertsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAlertsEnabled"];
    self.alertsSwitch.on = alertsEnabled;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (IBAction)applyChanges:(id)sender {
    
    //Save the alert preferences when a change is made.
    [[NSUserDefaults standardUserDefaults] setBool:self.alertsSwitch.on forKey:@"kAlertsEnabled"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[self.lowInput.text intValue]] forKey:@"kLowAlertValue"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[self.highInput.text intValue]] forKey:@"kHighAlertValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)manualRefresh:(id)sender {
    [self getAsynchronously];
}

- (void)getAsynchronously {
    
    //Load user preferences from NSUserDefaults.
    BOOL customCurrencyEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"enabled_preference"];
    NSString *ISOCurrency;
    
    if (customCurrencyEnabled) {
        ISOCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"code_preference"];
        //Ensure that the result is uppercase.
        ISOCurrency = [ISOCurrency uppercaseString];
    }
    else {
        //Set the ISO to default to USD.
        ISOCurrency = @"USD";
    }
    
    if (!ISOCurrency) {
        //For some reason, the currency didn't load. Prevent a crash.
        ISOCurrency = @"USD";
    }
    
    //Asynchronously load the GET request from CoinBase.
    dispatch_async(kBgQueue, ^{
        NSData *data = nil;
        data = [NSData dataWithContentsOfURL:kCoinBaseURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    
}

- (void)fetchedData:(NSData *)responseData {
    //This method is a simple JSON parser.
    
    if(responseData) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        
        if(!error) {
            //The data returned was OK, so parse it.
            
            BOOL customCurrencyEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"enabled_preference"];
            NSString *BTCValue;
            
            BOOL displayMilliBTC = [[NSUserDefaults standardUserDefaults] boolForKey:@"mBTC_preference"];
            
            
            if (customCurrencyEnabled) {
                NSString *formattedCurrencyCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"kEncodedCurrencyCode"];
                
                BTCValue = [json objectForKey:formattedCurrencyCode];
            }
            
            else {
                BTCValue = [json objectForKey:kUSA];
            }
            
            
            //Create a string in order to display the proper international currency symbol.
            NSString *ISOcurrency = [[NSUserDefaults standardUserDefaults] stringForKey:@"code_preference"];
            ISOcurrency = [ISOcurrency uppercaseString];
            
            //Convert the string into an integer value to display.
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *numberValue = [formatter numberFromString:BTCValue];
            
            if (displayMilliBTC) {
                //Display in mBTC, so divide by 1000.
                float tempFloat = [numberValue floatValue];
                tempFloat *= 0.001;
                BTCValue = [NSString stringWithFormat:@"%f",tempFloat];
                numberValue = [formatter numberFromString:BTCValue];
            }
            
            NSInteger value = roundf([numberValue floatValue]);
            //Uses roundf because integerValue and conversion to int round differently.
            //This gives some consistency across the platform.
            
            if (value > 19999) {
                //Round it so that it properly displays on the app icon, without changing the in-app display.
                int modulo = value % 100;
                value = value - modulo + 11;
                NSLog(@"%ld",(long)value);
                //Update only the badge number.
            }
        
            else if (value > 9999) {
                //Round it so that it properly displays on the app icon, without changing the in-app display.
                int modulo = value % 10;
                value = value - modulo + 1;
                NSLog(@"%ld",(long)value);
                //Update only the badge number.
            }
            
            //Update the icon badge to reflect the BTC price.
            [UIApplication sharedApplication].applicationIconBadgeNumber = value;
            
            //Update the currency symbol.
            NSNumberFormatter *symbol = [[NSNumberFormatter alloc] init];
            [symbol setNumberStyle:NSNumberFormatterCurrencyStyle];
            [symbol setMaximumFractionDigits:0];
            
            if (displayMilliBTC) {
                //Display a few decimal places in the event that mBTC display is on.
                //This way, we can see BTC value with a little bit more precision.
                [symbol setMaximumFractionDigits:3];
            }
            
            if (customCurrencyEnabled) {
                NSLog(@"%@ %@", BTCValue, ISOcurrency);
                [symbol setCurrencyCode:ISOcurrency];
            }
            
            else {
                NSLog(@"%@ USD", BTCValue);
                [symbol setCurrencyCode:@"USD"];
            }
            
            //Update the app view with the correct currency symbol.
            NSString *priceString = [symbol stringFromNumber:numberValue];
            self.priceLabel.text = priceString;
        }
    }
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)exitKeyboard:(id)sender {
    //resign the first responders.
    [self applyChanges:self];
    [self.lowInput resignFirstResponder];
    [self.highInput resignFirstResponder];
}

- (void)checkBackgroundRefresh {
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {
        NSLog(@"Background updates are available for the app.");
    }
    
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        
        // Notifications not allowed
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Background Refresh Disabled!" message:@"BTCTicker uses background refresh to update the price. If you want this to work, you need to enable it in settings." preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //Show the settings menu
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        NSLog(@"The user explicitly disabled background behavior for this app or for the whole system.");
    }
    
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted) {
        
        // Notifications not allowed
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Background Refresh Disabled!" message:@"BTCTicker uses background refresh to update the price. If you want this to work, you need to enable it in settings." preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //Show the settings menu
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        NSLog(@"Background updates are unavailable and the user cannot enable them again. For example, this status can occur when parental controls are in effect for the current user.");
    }
}

- (void)checkNotifications {
    //Check for notifications enabled
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        //iOS10
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            
            if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
                
                // Notifications not allowed
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Notifications Disabled!" message:@"BTCTicker uses local notifications to deliver price alerts. If you want this to work, you need to enable it in settings." preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    //Show the settings menu
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }];
    }
    else {
        //iOS9
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadFromNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){ // Check it's iOS 8 and above
            UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
            
            if (!(grantedSettings.types & UIUserNotificationTypeAlert)){
                // Notifications not allowed
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Notifications Disabled!" message:@"BTCTicker uses local notifications to deliver price alerts. If you want this to work, you need to enable it in settings." preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    //Show the settings menu
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}

- (BOOL)isAppAlreadyLaunchedOnce {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAppAlreadyLaunchedOnce"])
    {
        return true;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAppAlreadyLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"First launch!");
        return false;
    }
}

@end
