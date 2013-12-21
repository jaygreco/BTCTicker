BTCTicker
=========

An open source Bitcoin ticker for iOS.

The main purpose of BTCTicker is to allow you to view the exchange rate right on your homescreen. It does this by using background fetch and app icon badging. The actual display of the app is very basic, and only shows the current price, since its main purpose is to display update data on the homescreen.

BTCTicker uses background fetch, favoring power efficiency over continous updating. Because of the way background fetch is implemented by Apple, it's tough to know exactly how often the price will update. I've been seeing updates every 3-5 minutes, although it greatly depends on your usages patterns for your device.

Currently, BTCTicker is using the CoinBase API to pull exchange data and displays it in USD. However, it is easily changed to display a different currency, by changing the JSON tag btc_to_xxx, where xxx is the three digit currency code. In the future, addition of different exchanges is also planned.

Push notifications for price alerts are also planned, as is a settings bundle to change the display currency, exchange, and mBTC or BTC display. 

Finally, for those who are not iPhone developers, and cannot find a way to sign the package for their iOS device, I will be submitting the 1.0 verson to Apple for App Store approval. Keeping the open-source motif, it will be free :)

If you like BTCTicker, please contribute on GitHub, or consider making a BTC donation :) 
1NXWWojVhD8kJ63FagytpDQuXDedBBQHzw
