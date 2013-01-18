OneSky iOS SDK
============================

```objc
OneSkyHelper* helper = [OneSkyHelper sharedHelper];
helper.platformId = 868;
helper.key = @"535e19975998c52ad19470eb4805f515";
helper.defaultTableName = @"Localizable.strings";
helper.delegate = self;
helper.preferredLanguage = @"zh-Hant";
[helper setFallbackJsonNamed:@"onesky.json"];
[helper checkForUpdateOfPreferredLanguage];
```