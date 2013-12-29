//
//  NotifierBackend.m
//  BTCTicker
//
//  Created by Jay Greco on 12/28/13.
//  Copyright (c) 2013 Jay Greco. All rights reserved.
//

#import "NotifierBackend.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation NotifierBackend

+ (void)checkAlertStatus:(NSInteger)currentBTCValue {
    
    //Load the alert preferences.
    BOOL alertsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAlertsEnabled"];
    NSInteger lowValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"kLowAlertValue"] intValue];
    NSInteger highValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"kHighAlertValue"] intValue];
    
    if (alertsEnabled) {
     
        if (currentBTCValue > highValue) {
            //BTC has reached a value higher than the set threshold. Create an alert.
            
            NSString *alertString = [NSString stringWithFormat:@"Bitcoin has exceeded %ld USD", (long)highValue];
            [NotifierBackend createLocalNotification:alertString];
            [NotifierBackend resetNotification];
        }
        
        if (currentBTCValue < lowValue) {
            //BTC has reached a value lower than the set threshold. Create an alert.
            
            NSString *alertString = [NSString stringWithFormat:@"Bitcoin has fallen below %ld USD", (long)lowValue];
            [NotifierBackend createLocalNotification:alertString];
            [NotifierBackend resetNotification];
        }
        
    }
    
}

+ (void)createLocalNotification:(NSString *)alertString {
    //create and present the local alert, and make it fire immediately.
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotification.alertBody = alertString;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    
    //Add a vibration, for iPhone.
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (void)resetNotification {
    //Turn any newer alerts off, so an alert doesn't fire twice.
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kAlertsEnabled"];
    
    //Synchronize the defaults.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
