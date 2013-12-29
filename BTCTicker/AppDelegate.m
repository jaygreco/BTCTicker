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
    NSTimeInterval waitTime = 60.0;
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:waitTime]; //waitTime delegates the minimum wait time.
    
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    //This method is responsible for loading the BTC exchange price in the app background. It will run as defined by the
    //setMinimumBackgroundFetchInterval set in the didFinishLaunchingWithOptions method.
    
    NSLog(@"Background Fetch");
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSDictionary* json;
    
    //synchronously load the request, since the app is already in the background.
    
    NSURLRequest *urlRequest=[NSURLRequest requestWithURL:kCoinBaseURL
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
        
        NSLog(@"BG Fetch Success");
        
        NSString* BTCValue = [json objectForKey:@"btc_to_usd"];
        
        //This is the currency line. Change this to change the
        //Preferred currency. btc_to_<xxx> where <xxx> is the
        //Three digit currency code.
        
        NSLog(@"Coinbase: %@ USD", BTCValue);
        
        int value = [BTCValue intValue];
        [UIApplication sharedApplication].applicationIconBadgeNumber = value;
        //Display the result on the app badge.
        
        [NotifierBackend checkAlertStatus:value];
        
        completionHandler(UIBackgroundFetchResultNewData);
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
