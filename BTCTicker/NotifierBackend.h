//
//  NotifierBackend.h
//  BTCTicker
//
//  Created by Jay Greco on 12/28/13.
//  Copyright (c) 2013 Jay Greco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotifierBackend : NSObject

+ (void)checkAlertStatus:(NSInteger)currentBTCValue;
+ (void)createLocalNotification:(NSString *)alertString;
+ (void)resetNotification;

@end
