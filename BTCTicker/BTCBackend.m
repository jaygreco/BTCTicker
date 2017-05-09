//
//  BTCBackend.m
//  BTCTicker
//
//  Created by Jay Greco on 12/23/13.
//  Copyright (c) 2013 Jay Greco. All rights reserved.
//

#import "BTCBackend.h"
#import "definitions.h"

@implementation BTCBackend

- (void)getSynchronously:(NSURL *)exchangeURL {
}

- (void)fetchedData:(NSData *)responseData {        //This method is a simple JSON parser.
    
    if(responseData) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        
        if(!error) {
            NSString* BTCValue = [json objectForKey:kUSA];
            NSLog(@"%@ USD", BTCValue);
            
            int value = [BTCValue intValue];
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = value;       //Update the icon badge to reflect the BTC price.
            
            //NSString *priceString = [NSString stringWithFormat:@"$%d", value];          //Update the app view.
            //write to some label?
        }
    }
}

+ (void)getAsynchronously:(NSURL *)exchangeURL {
    dispatch_async(kBgQueue, ^{
        NSLog(@"Fetching Async...");
        NSData *data = nil;
        data = [NSData dataWithContentsOfURL: kCoinBaseURL];          //Asynchronously load the GET request.
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

@end
