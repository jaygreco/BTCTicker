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
//#import "Appirater.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        //iOS 10
        NSLog(@"iOS10 Notifications enabled!");
        [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNAuthorizationOptions options = UNAuthorizationOptionBadge + UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
        [center requestAuthorizationWithOptions:options
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  if (!granted) {
                                      NSLog(@"Something went wrong");
                                  }}];
        [[UNUserNotificationCenter currentNotificationCenter] setDelegate: self];
    }
    else {
        //iOS 9
        NSLog(@"iOS9 Notifications enabled!");
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
    
    [NotifierBackend syncCurrency];
    
    //waitTime delegates the minimum wait time.
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //[Appirater appLaunched:YES];
    
    return YES;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSLog(@"Notification Processed");
    [NotifierBackend resetNotification];
    completionHandler();
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [NotifierBackend syncCurrency];

    //This method is responsible for loading the BTC exchange price in the app background. It will run as defined by the
    //setMinimumBackgroundFetchInterval set in the didFinishLaunchingWithOptions method.
    
    NSLog(@"Background Fetch");
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSURL *requestURL;
    NSString *ISOcurrency = [[NSUserDefaults standardUserDefaults] stringForKey:@"code_preference"];
    BOOL customCurrencyEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"enabled_preference"];
    BOOL displayMilliBTC = [[NSUserDefaults standardUserDefaults] boolForKey:@"mBTC_preference"];
    
    //synchronously load the request, since the app is already in the background.
    requestURL = kCoinBaseURL;
    NSURLRequest *urlRequest=[NSURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
   
    NSData* data = [self sendSynchronousRequest:urlRequest returningResponse:&response error:&error];

    //This is a simple JSON parser.
    if(error) {
        //there was an error
        NSLog(@"BG Fetch Failure");
        completionHandler(UIBackgroundFetchResultFailed);
    }
    
    else {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              
                              options:kNilOptions
                              error:&error];
        //there was no error, so update the results.
        NSString *BTCValue;
        
        if (customCurrencyEnabled) {
            //NSLog(@"Custom currency enabled.");
            NSString *formattedCurrencyCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"kEncodedCurrencyCode"];
            
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
        
        NSInteger value = [numberValue integerValue];
        
        
        //Print the values to the log.
        if(customCurrencyEnabled) {
            NSLog(@"%@ %@", BTCValue, ISOcurrency);
        }
        else {
            NSLog(@"%@ USD", BTCValue);
        }
        
        
        if (value > 19999) {
            //Round it so that it properly displays on the app icon, without changing the in-app display.
            int modulo = value % 100;
            long roundedValue = value - modulo + 11;
            NSLog(@"%ld",roundedValue);
            //Update only the badge number.
            [UIApplication sharedApplication].applicationIconBadgeNumber = roundedValue;
        }
        
        else if (value > 9999) {
            //Round it so that it properly displays on the app icon, without changing the in-app display.
            int modulo = value % 10;
            long roundedValue = value - modulo + 1;
            NSLog(@"%ld",roundedValue);
            //Update only the badge number.
            [UIApplication sharedApplication].applicationIconBadgeNumber = roundedValue;
        }
        
        else {
            [UIApplication sharedApplication].applicationIconBadgeNumber = value;
            //Display the result on the app badge.
        }
        
        [NotifierBackend checkAlertStatus:value];
        NSLog(@"BG Fetch Success");
        
        completionHandler(UIBackgroundFetchResultNewData);
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

@end
