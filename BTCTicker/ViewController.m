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
    
    NSString *currencyString = @"btc_to_";
    currencyString = [currencyString stringByAppendingString:[self.currencyCode.text lowercaseString]];
    
    NSLog(@"%@", currencyString);
    
    [[NSUserDefaults standardUserDefaults] setBool:self.alertsSwitch.on forKey:@"kAlertsEnabled"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[self.lowInput.text intValue]] forKey:@"kLowAlertValue"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[self.highInput.text intValue]] forKey:@"kHighAlertValue"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithString:currencyString] forKey:@"kCurrencyCode"];
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
            
            NSString *BTCValue = [json objectForKey:kUSA];
            
            //This is the currency line. Change this to change the
            //Preferred currency. btc_to_<xxx> where <xxx> is the
            //Three digit currency code. Check definitions.h.
            
            NSLog(@"Coinbase: %@ USD", BTCValue);
            
            int value = [BTCValue intValue];
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = value;       //Update the icon badge to reflect the BTC price.
            
            NSString *priceString = [NSString stringWithFormat:@"$%d", value];          //Update the app view.
            //write to some label?
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
