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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Sync the currency and exchange preferences.
    [NotifierBackend syncCurrency];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoadFromNotification)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
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

- (void)getAsynchronously {
    
    //Load user preferences from NSUserDefaults.
    NSString *exchange = [[NSUserDefaults standardUserDefaults] objectForKey:@"exchange_preference"];
    BOOL customCurrencyEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"enabled_preference"];
    NSString *ISOCurrency;
    
    if (customCurrencyEnabled) {
        ISOCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"currency_preference"];
        //Ensure that the result is uppercase.
        ISOCurrency = [ISOCurrency uppercaseString];
    }
    else {
        //Set the ISO to default to USD.
        ISOCurrency = @"USD";
    }
    
    if ([exchange isEqualToString:@"coinbase"]) {
        //Asynchronously load the GET request from CoinBase.
        dispatch_async(kBgQueue, ^{
            NSData *data = nil;
            data = [NSData dataWithContentsOfURL:
                    kCoinBaseURL];
            [self performSelectorOnMainThread:@selector(fetchedData:)
                                   withObject:data waitUntilDone:YES];
        });
    }
    else if ([exchange isEqualToString:@"coindesk"]) {
        //Asynchronously load the GET request from CoinDesk.
        dispatch_async(kBgQueue, ^{
            NSData *data = nil;
            data = [NSData dataWithContentsOfURL:
            kCoinDeskURL(ISOCurrency)];
            [self performSelectorOnMainThread:@selector(fetchedData:)
                                   withObject:data waitUntilDone:YES];
        });
    }
    
}

- (void)fetchedData:(NSData *)responseData {
    //This method is a simple JSON parser.
    
    if(responseData) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              
                              options:kNilOptions
                              error:&error];
        
        if(!error) {
            
            //The data returned was OK, so parse it based on which exchange is selected.
            
            NSString *exchange = [[NSUserDefaults standardUserDefaults] objectForKey:@"exchange_preference"];
            
            BOOL customCurrencyEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"enabled_preference"];
            NSString *BTCValue;
            
            if ([exchange isEqualToString:@"coinbase"]) {
                //CoinBase selected as the exchange.
                
                if (customCurrencyEnabled) {
                    NSLog(@"Custom currency enabled.");
                    NSString *formattedCurrencyCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"kEncodedCurrencyCode"];
                    
                    BTCValue = [json objectForKey:formattedCurrencyCode];
                }
                
                else {
                    BTCValue = [json objectForKey:kUSA];
                }
            }
            
            else if ([exchange isEqualToString:@"coindesk"]) {
                //Coindesk is selected as the exchange.
                
                if (customCurrencyEnabled) {
                    NSString *ISOcurrency = [[NSUserDefaults standardUserDefaults] stringForKey:@"code_preference"];
                    ISOcurrency = [ISOcurrency uppercaseString];
                    
                    NSDictionary* BTCDict = [json objectForKey:@"bpi"];
                    BTCDict = [BTCDict objectForKey:ISOcurrency];
                    BTCValue = [BTCDict objectForKey:@"rate"];
                }
                
                else {
                    NSDictionary* BTCDict = [json objectForKey:@"bpi"];
                    BTCDict = [BTCDict objectForKey:@"USD"];
                    BTCValue = [BTCDict objectForKey:@"rate"];
                }
            }
            
            //Create a string in order to display the proper international currency symbol.
            NSString *ISOcurrency = [[NSUserDefaults standardUserDefaults] stringForKey:@"code_preference"];
            ISOcurrency = [ISOcurrency uppercaseString];
            
            //Convert the string into an integer value to display.
            int value = [BTCValue intValue];
            NSNumber *stringNumber = [NSNumber numberWithInt:value];
            
            //Update the icon badge to reflect the BTC price.
            [UIApplication sharedApplication].applicationIconBadgeNumber = value;
            
            //Update the currency symbol.
            NSNumberFormatter *symbol = [[NSNumberFormatter alloc] init];
            [symbol setNumberStyle:NSNumberFormatterCurrencyStyle];
            [symbol setMaximumFractionDigits:0];
            
            if (customCurrencyEnabled) {
                NSLog(@"%@: %@ %@", exchange, BTCValue, ISOcurrency);
                [symbol setCurrencyCode:ISOcurrency];
            }
            
            else {
                NSLog(@"%@: %@ USD", exchange, BTCValue);
                [symbol setCurrencyCode:@"USD"];
            }
            
            //Update the app view with the correct currency symbol.
            NSString *priceString = [symbol stringFromNumber:stringNumber];
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
    [self.currencyCode resignFirstResponder];
}

@end
