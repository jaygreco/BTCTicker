//
//  NotifierBackend.h
//  BTCTicker
//
//  Created by Jay Greco on 12/28/13.
//  Copyright (c) 2013 Jay Greco. All rights reserved.
//

//#import "Appirater.h"
#import <Foundation/Foundation.h>

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@import UserNotifications;

@interface NotifierBackend : NSObject

+ (void)checkAlertStatus:(NSInteger)currentBTCValue;
+ (void)createLocalNotification:(NSString *)alertString;
+ (void)resetNotification;
+ (void)syncCurrency;

@end
