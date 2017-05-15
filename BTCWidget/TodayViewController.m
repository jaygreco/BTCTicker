//
//  TodayViewController.m
//  BTCWidget
//
//  Created by Jay Greco on 5/12/17.
//  Copyright © 2017 Jay Greco. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self syncCurrency];
    [self updateBTC];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    [self syncCurrency];
    [self updateBTC];

    completionHandler(NCUpdateResultNewData);
}

- (void)syncCurrency { //make sure currency and exchange preferences are properly configured at runtime.
    NSLog(@"[Notifier] Syncing currency...");
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.jay-greco.BTCExtensionSharingDefaults"];
    
    BOOL customCurrencyEnabled = [sharedDefaults boolForKey:@"enabled_preference"];
    NSLog(@"[Notifier] Custom currency: %d", customCurrencyEnabled);
    
    if (customCurrencyEnabled) {
        NSString *ISOCurrency = [sharedDefaults stringForKey:@"code_preference"];
        NSString *currencyString = @"btc_to_";
        
        if(!ISOCurrency) { //In case the setting is enabled, but the field hasn't been changed.
            ISOCurrency = @"USD";
            [sharedDefaults setObject:ISOCurrency forKey:@"code_preference"];
            [sharedDefaults synchronize];
        }
        
        currencyString = [currencyString stringByAppendingString:[ISOCurrency lowercaseString]];
        //NSLog(@"%@", currencyString);
        
        [sharedDefaults setObject:currencyString forKey:@"kEncodedCurrencyCode"];
        [sharedDefaults synchronize];
        NSLog(@"[Notifier] kEncodedCurrencyCode: %@", currencyString);
    }
    
}

- (void)updateBTC {
    NSLog(@"[Widget] Widget Fetch");
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.jay-greco.BTCExtensionSharingDefaults"];
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSURL *requestURL;
    NSString *ISOcurrency = [sharedDefaults stringForKey:@"code_preference"];
    BOOL customCurrencyEnabled = [sharedDefaults boolForKey:@"enabled_preference"];
    BOOL displayMilliBTC = [sharedDefaults boolForKey:@"mBTC_preference"];
    
    //synchronously load the request, since the app is already in the background.
    requestURL = kCoinBaseURL;
    NSURLRequest *urlRequest=[NSURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    NSData* data = [self sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    //This is a simple JSON parser.
    if(error) {
        //there was an error
        NSLog(@"[Widget] Widget Fetch Failure");
        NSLog(@"[Widget] %@", error);
    }
    
    else {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              
                              options:kNilOptions
                              error:&error];
        //there was no error, so update the results.
        NSString *BTCValue;
        
        if (customCurrencyEnabled) {
            NSString *formattedCurrencyCode = [sharedDefaults stringForKey:@"kEncodedCurrencyCode"];
            
            BTCValue = [json objectForKey:formattedCurrencyCode];
        }
        
        else {
            BTCValue = [json objectForKey:kUSA];
        }
        
        
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
        
        //NSInteger value = [numberValue integerValue];
        
        
        //Print the values to the log.
        if(customCurrencyEnabled) {
            NSLog(@"[Widget] %@ %@", BTCValue, ISOcurrency);
        }
        else {
            NSLog(@"[Widget] %@ USD", BTCValue);
        }
        
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
            NSLog(@"[Widget] %@ %@", BTCValue, ISOcurrency);
            [symbol setCurrencyCode:ISOcurrency];
        }
        
        else {
            NSLog(@"[Widget] %@ USD", BTCValue);
            [symbol setCurrencyCode:@"USD"];
        }
        
        //Update the app view with the correct currency symbol.
        NSString *priceString = [symbol stringFromNumber:numberValue];
        self.priceLabel.text = priceString;
        
        NSLog(@"[Widget] Widget Fetch Success");
    }
}

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    
    NSError __block *err = NULL;
    NSData __block *data;
    BOOL __block reqProcessed = false;
    NSURLResponse __block *resp;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable _data, NSURLResponse * _Nullable _response, NSError * _Nullable _error) {
        resp = _response;
        err = _error;
        data = _data;
        reqProcessed = true;
    }] resume];
    
    while (!reqProcessed) {
        [NSThread sleepForTimeInterval:0];
    }
    
    *response = resp;
    *error = err;
    return data;
}

- (IBAction)launchApp:(id)sender {
    NSURL *url = [NSURL URLWithString:@"btcticker://"];
    [self.extensionContext openURL:url completionHandler:nil];
}
@end
