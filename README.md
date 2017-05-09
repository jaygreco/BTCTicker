BTCTicker
=========

An open source Bitcoin ticker for iOS.

The main purpose of BTCTicker is to allow you to view the exchange rate right on your homescreen. It does this by using background fetch and app icon badging. The actual display of the app is very basic, and only shows the current price, since its main purpose is to display update data on the homescreen.

BTCTicker uses background fetch, favoring power efficiency over continous updating. Because of the way background fetch is implemented by Apple, it's tough to know exactly how often the price will update. I've been seeing updates every 3-5 minutes, although it greatly depends on your usages patterns for your device. Enabling push notifications for price limits increases the time between refreshes, but not by much.

Currently, BTCTicker is using the CoinBase API to pull exchange data and displays it in USD by default. However, I've added a settings bundle which allows the conversion of BTC to any ISO compliant currency using the 3 digit currency code (USD, JPY, EUR, GBP, etc), and the selection of different exchanges (for the future). Push notifications for price alerts are also supported. Users can set a high and low margin and if the price crosses the threshold upon background fetch, a notification is displayed. In the works is an option in the settings bundle to change between mBTC or BTC display. 

Finally, for those who are not iPhone developers, and cannot find a way to sign the package for their iOS device, I will be submitting the 2.0 verson to Apple for App Store approval!

If you like BTCTicker, please contribute on GitHub, or consider making a BTC donation :) 
13cLLkmkfznBcfhuKfQuiPq298G59efQZ6
