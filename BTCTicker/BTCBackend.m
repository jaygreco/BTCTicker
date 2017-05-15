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

- (int)fetchedData:(NSData *)responseData {        //This method is a simple JSON parser.
    
    if(responseData) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        
        if(!error) {
            NSString* BTCValue = [json objectForKey:kUSA];
            NSLog(@"%@ USD", BTCValue);
            
            int value = [BTCValue intValue];
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = value;
            return value;
        }
        return 0;
    }
    return 0;
}

+ (void)getAsynchronously:(NSURL *)exchangeURL {
    dispatch_async(kBgQueue, ^{
        NSLog(@"Fetching Async...");
        NSData *data = nil;
        data = [NSData dataWithContentsOfURL: kCoinBaseURL];          //Asynchronously load the GET request.
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
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

@end
