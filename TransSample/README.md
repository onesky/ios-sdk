1. Use the ```NSLocalizedString``` macro. [Learn how](http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPInternational/Articles/StringsFiles.html#//apple_ref/doc/uid/20000005)
2. Replace all ```NSLocalizedString``` with ```OneSkyString```
3. Open Terminal and run
	
	```genstrings Classes/*.m -s OneSkyString```

4. A ```Localizable.strings``` file is generate.
