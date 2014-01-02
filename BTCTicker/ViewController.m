//
//  ViewController.m
//  BTCTicker
//
//  Created by Jay Greco on 12/21/13.
//  Copyright (c) 2013 Jay Greco. All rights reserved.
//

#import "ViewController.h"
#import "definitions.h"

//perhaps use userdefaults to determine selected exchange and currency.
NSURL *userURL;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoadFromNotification)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self getAsynchronously:kCoinBaseURL];
    [NSTimer scheduledTimerWithTimeInterval:30                                          //Run a NSTimer to refresh status automatically.
                                     target:self
                                   selector:@selector(getAsynchronously:)
                                   userInfo:kCoinBaseURL
                                    repeats:YES];
    
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

- (void)getAsynchronously:(NSURL *)exchangeURL {
    dispatch_async(kBgQueue, ^{
        NSData *data = nil;
        data = [NSData dataWithContentsOfURL:
                kCoinBaseURL];                                                          //Asynchronously load the GET request.
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {                                            //This method is a simple JSON parser.
    
    if(responseData) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              
                              options:kNilOptions
                              error:&error];
        
        if(!error) {
            
            /*NSArray *allCurrencies = [NSArray arrayWithObjects:kUSA,kEURO,kENGLAND,kINDIA,kJAPAN,kSINGAPORE,kHONGKONG,kAUSTRALIA,
                                      kNEWZEALAND,kSWITZERLAND,kSWEDEN,kDENMARK,kCANADA,kNORWAY,kBRUNEI,kINDONESIA,kMALAYSIA,
                                      kCHINA,kKOREA,kTAIWAN,kUAE,kBAHRAIN,kOMAN,kQATAR,kSAUDIARABIA,kSOUTHAFRICA,nil];
            
            NSArray *allBTCValues = [json objectsForKeys:allCurrencies notFoundMarker:[NSNull null]];
            
            NSLog(@"%@", allBTCValues);*/
            
            BOOL customCurrencyEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"enabled_preference"];
            NSString *BTCValue;
            
            if (customCurrencyEnabled) {
                NSLog(@"Custom currency enabled.");
                NSString *formattedCurrencyCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"kEncodedCurrencyCode"];

                BTCValue = [json objectForKey:formattedCurrencyCode];
            }
            
            else {
                NSLog(@"No custom currency. Defaulting to USD.");
                BTCValue = [json objectForKey:kUSA];
            }
            
            //This is the currency line. Change this to change the
            //Preferred currency. btc_to_<xxx> where <xxx> is the
            //Three digit currency code. Check definitions.h.
            
            NSString *ISOcurrency = [[NSUserDefaults standardUserDefaults] stringForKey:@"code_preference"];
            ISOcurrency = [ISOcurrency uppercaseString];
            
            int value = [BTCValue intValue];
            NSNumber *stringNumber = [NSNumber numberWithInt:value];
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = value;       //Update the icon badge to reflect the BTC price.
            
            NSNumberFormatter *symbol = [[NSNumberFormatter alloc] init];
            [symbol setNumberStyle:NSNumberFormatterCurrencyStyle];
            [symbol setMaximumFractionDigits:0];
            
            if (customCurrencyEnabled) {
                NSLog(@"Coinbase: %@ %@", BTCValue, ISOcurrency);
                [symbol setCurrencyCode:ISOcurrency];
            }
            
            else {
                NSLog(@"Coinbase: %@ USD", BTCValue);
                [symbol setCurrencyCode:@"USD"];
            }
            
            NSString *priceString = [symbol stringFromNumber:stringNumber];          //Update the app view with the correct currency symbol.
            
            self.priceLabel.text = priceString;
        }
    }
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)exitKeyboard:(id)sender {
    [self.lowInput resignFirstResponder];
    [self.highInput resignFirstResponder];
    [self.currencyCode resignFirstResponder];
    //resign the first responders and update the nsuserdefaults.
}

@end
