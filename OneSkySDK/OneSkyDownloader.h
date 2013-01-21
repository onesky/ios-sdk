#import "NSString+Additions.h"

#import "OneSkyHelper.h"

@interface OneSkyDownloader : NSObject {
    NSURLConnection *           _connection;
    NSString *                  _filePath;
    NSOutputStream *            _fileStream;
    
    NSArray* _languages;
    
    OneSkyHelper* _helper;
}

//+ (OneSkyDownloader*)sharedDownloader;

@property(nonatomic, retain) NSArray* languages;

- (id)initWithHelper:(OneSkyHelper*)helper;
- (void)startReceive;


@end
