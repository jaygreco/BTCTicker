//
//  ViewController.m
//  BTCTicker
//
//  Created by Jay Greco on 12/21/13.
//  Copyright (c) 2013 Jay Greco. All rights reserved.
//

#import "ViewController.h"

//Define the asynchronous HTTP request and the BTC exchange API address.
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kLatestKivaLoansURL [NSURL URLWithString:@"https://coinbase.com/api/v1/currencies/exchange_rates"]
//Right now, CoinBase is the default exchange. Support for choosing multiple exchanges is planned.

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self GET];                                                                     //Load BTC status upon launch.
    [NSTimer scheduledTimerWithTimeInterval:30                                      //Run a NSTimer to refresh status automatically.
                                     target:self
                                   selector:@selector(GET)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)fetchedData:(NSData *)responseData {                                        //This method is a simple JSON parser.
    
    if(responseData) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              
                              options:kNilOptions
                              error:&error];
        
        if(!error) {
            
            NSString* BTCValue = [json objectForKey:@"btc_to_usd"];                 //This is the currency line. Change this to change the
                                                                                    //Preferred currency. btc_to_<xxx> where <xxx> is the
                                                                                    //Three digit currency code.
            
            NSLog(@"Coinbase: %@ USD", BTCValue);
            
            int value = [BTCValue intValue];
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = value;   //Update the icon badge to reflect the BTC price.
            
            NSString *priceString = [NSString stringWithFormat:@"$%d", value];      //Update the app view.
            [UIView animateWithDuration:0.5 animations:^{
                self.priceLabel.text = priceString;
            }];
        }
    }
}

- (void)GET {
                                                                                    // create the connection with the request
                                                                                    // and start loading the data
    dispatch_async(kBgQueue, ^{
        NSData *data = nil;
        data = [NSData dataWithContentsOfURL:
                kLatestKivaLoansURL];                                               //Asynchronously load the GET request.
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
    
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
