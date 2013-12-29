//
//  definitions.h
//  BTCTicker
//
//  Created by Jay Greco on 12/23/13.
//  Copyright (c) 2013 Jay Greco. All rights reserved.
//

#ifndef BTCTicker_definitions_h
#define BTCTicker_definitions_h

//define the async method
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

//define the exchange URLs
#define kCoinBaseURL [NSURL URLWithString:@"https://coinbase.com/api/v1/currencies/exchange_rates"]

//define the different JSON Keys to select currency
#define kUSA @"btc_to_usd"
#define kEURO @"btc_to_eur"
#define kENGLAND @"btc_to_gbp"
#define kJAPAN @"btc_to_jpy"
#define kSINGAPORE @"btc_to_sgd"
#define kHONGKONG @"btc_to_hkd"
#define kAUSTRALIA @"btc_to_aud"
#define kNEWZEALAND @"btc_to_nzd"
#define kSWITZERLAND @"btc_to_chf"
#define kSWEDEN @"btc_to_sek"
#define kDENMARK @"btc_to_dkk"
#define kCANADA @"btc_to_cad"
#define kNORWAY @"btc_to_nok"
#define kBRUNEI @"btc_to_brd"
#define kINDONESIA @"btc_to_idr"
#define kMALAYSIA @"btc_to_myr"
#define kCHINA @"btc_to_cny"
#define kKOREA @"btc_to_krw"
#define kTAIWAN @"btc_to_twd"
#define kUAE @"btc_to_aed"
#define kBAHRAIN @"btc_to_bhd"
#define kOMAN @"btc_to_ohr"
#define kQATAR @"btc_to_qar"
#define kSAUDIARABIA @"btc_to_sar"
#define kSOUTHAFRICA @"btc_to_zar"

#endif
