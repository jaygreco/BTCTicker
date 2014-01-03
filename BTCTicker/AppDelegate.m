//
//  AppDelegate.m
//  BTCTicker
//
//  Created by Jay Greco on 12/21/13.
//  Copyright (c) 2013 Jay Greco. All rights reserved.
//

#import "AppDelegate.h"
#import "definitions.h"
#import "NotifierBackend.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NotifierBackend syncCurrency];
    
    NSTimeInterval waitTime = 60.0;
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:waitTime]; //waitTime delegates the minimum wait time.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [NotifierBackend syncCurrency];

    //This method is responsible for loading the BTC exchange price in the app background. It will run as defined by the
    //setMinimumBackgroundFetchInterval set in the didFinishLaunchingWithOptions method.
    
    NSLog(@"Background Fetch");
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSDictionary* json;
    NSURL *requestURL;
    NSString *ISOcurrency = [[NSUserDefaults standardUserDefaults] stringForKey:@"code_preference"];
    NSString *exchange = [[NSUserDefaults standardUserDefaults] objectForKey:@"exchange_preference"];
    BOOL customCurrencyEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"enabled_preference"];
    
    //synchronously load the request, since the app is already in the background.
    
    if ([exchange isEqualToString:@"coindesk"]) {
        if (customCurrencyEnabled) {
            NSString *ISOcurrency = [[NSUserDefaults standardUserDefaults] stringForKey:@"code_preference"];
            requestURL = kCoinDeskURL(ISOcurrency);
        }
        else {
            requestURL = kCoinDeskURL(@"USD");
        }
    }
    
    else if ([exchange isEqualToString:@"coinbase"]) {
        requestURL = kCoinBaseURL;
    }
    
    NSURLRequest *urlRequest=[NSURLRequest requestWithURL:requestURL
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:10.0];
    NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    //This is a simple JSON parser.
    
    if(error) {
        //there was an error
        NSLog(@"BG Fetch Failure");
        completionHandler(UIBackgroundFetchResultFailed);
    }
    
    else {
        
        json = [NSJSONSerialization
                JSONObjectWithData:data
                
                options:kNilOptions
                error:&error];
    }
    
    if(error) {
        //there was an error
        NSLog(@"BG Fetch Failure");
        completionHandler(UIBackgroundFetchResultFailed);
    }
    
    else {
        //there was no error, so update the results.
        NSString *BTCValue;
        
        if ([exchange isEqualToString:@"coinbase"]) {
            if (customCurrencyEnabled) {
                //NSLog(@"Custom currency enabled.");
                NSString *formattedCurrencyCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"kEncodedCurrencyCode"];
            
                BTCValue = [json objectForKey:formattedCurrencyCode];
            }
        
            else {
                //NSLog(@"Defaulting to USD.");
                BTCValue = [json objectForKey:kUSA];
            }
        }
        
        else if ([exchange isEqualToString:@"coindesk"]) {
            //parse for coindesk
            
            if (customCurrencyEnabled) {
                ISOcurrency = [[NSUserDefaults standardUserDefaults] stringForKey:@"code_preference"];
                ISOcurrency = [ISOcurrency uppercaseString];
                
                NSDictionary* BTCDict = [json objectForKey:@"bpi"]; //testing with GBP
                BTCDict = [BTCDict objectForKey:ISOcurrency]; //currecny preference
                BTCValue = [BTCDict objectForKey:@"rate"];
            }
            
            else {
                //NSLog(@"Defaulting to USD.");
                NSDictionary* BTCDict = [json objectForKey:@"bpi"]; //testing with GBP
                BTCDict = [BTCDict objectForKey:@"USD"]; //currency preference
                BTCValue = [BTCDict objectForKey:@"rate"];
            }
        }
        
        if(customCurrencyEnabled) {
            NSLog(@"%@: %@ %@", exchange, BTCValue, ISOcurrency);
        }
        else {
           NSLog(@"%@: %@ USD", exchange, BTCValue);
        }
        
        int value = [BTCValue intValue];
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = value;
        //Display the result on the app badge.
        
        [NotifierBackend checkAlertStatus:value];
        
        completionHandler(UIBackgroundFetchResultNewData);
        NSLog(@"BG Fetch Success");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [NotifierBackend syncCurrency];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
