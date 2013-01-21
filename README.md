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

Steps
============================

1. Drag OneSky folder under the group Classes to XCode project. Check the box "copy" for prompt
2. Download [JSON for Objective-C](http://github.com/stig/json-framework/downloads)
3. Drag Classes folder under the group Classes to XCode project. Check the box "copy" for prompt
4. Insert following code to TransSample_Prefix.pch under
	``` #import <UIKit/UIKit.h>```
	
	``` #import "OneSkyHelper.h"```
5. Open TransSampleAppDelegate.m
6. Add following code inside

	```
	{
	OneSkyHelper* helper = [OneSkyHelper sharedHelper];
	helper.platformId = @1234; // the platform Id of iPhone App, found on OneSky UI
	helper.key = @"Your Key";
	helper.defaultTableName = @"Localizable.strings"; // the file name you uploaded
	[helper checkForUpdate];
	}
	```

	OneSkyString(@"Hello", @"Welcome message");

7. Build and install it on iphone
8. To test, exit the app, change the iPhone language, and re-launch the app. You will see the strings in the new language.
