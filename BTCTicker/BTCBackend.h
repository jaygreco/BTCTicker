//
//  BTCBackend.h
//  BTCTicker
//
//  Created by Jay Greco on 12/23/13.
//  Copyright (c) 2013 Jay Greco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTCBackend : NSObject

- (void)fetchedData:(NSData *)responseData;
+ (void)getAsynchronously:(NSURL *)exchangeURL;
- (void)getSynchronously:(NSURL *)exchangeURL;

@end
