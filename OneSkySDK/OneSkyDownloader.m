#import "OneSkyDownloader.h"

#import "OneSkyHelper.h"

@interface OneSkyDownloader ()

// Properties that don't need to be seen by the outside world.

@property (nonatomic, readonly) BOOL              isReceiving;
@property (nonatomic, retain)   NSURLConnection * connection;
@property (nonatomic, copy)     NSString *        filePath;
@property (nonatomic, retain)   NSOutputStream *  fileStream;

@end


@implementation OneSkyDownloader

@synthesize connection    = _connection;
@synthesize filePath      = _filePath;
@synthesize fileStream    = _fileStream;
@synthesize languages=_languages;

//static OneSkyDownloader* _sharedDownloader = nil;

//+ (OneSkyDownloader*)sharedDownloader {
//  if (!_sharedDownloader){
//    _sharedDownloader = [[self alloc] init];
//  }
//  return _sharedDownloader;
//}

- (id)initWithHelper:(OneSkyHelper*)helper {
    self = [self init];
    if (self) {
        _helper = [helper retain];
    }
    return self;
}

- (void)dealloc {
    [_helper release], _helper=nil;
    
    [super dealloc];
}

- (void)_startReceive {
    BOOL                success;
    NSURL *             url;
    NSURLRequest *      request;
    
    assert(self.connection == nil);         // don't tap receive twice in a row!
    assert(self.fileStream == nil);         // ditto
    assert(self.filePath == nil);           // ditto
    
    // First get and check the URL.
    //OneSkyHelper* helper = [OneSkyHelper sharedHelper];
    OneSkyHelper* helper = _helper;
//    NSString* project = [helper.platformId URLEncodedString];
    NSString* project = [NSString stringWithFormat:@"%d", helper.platformId];
    if (helper.version) {
        project = [project stringByAppendingFormat:@"&version=%@", [helper.version URLEncodedString]];
    }
    NSMutableString* paramLanguages = [NSMutableString stringWithCapacity:10];
    for (NSString* language in self.languages) {
        if (paramLanguages.length > 0) {
            [paramLanguages appendString:@","];
        }
        [paramLanguages appendString:[language URLEncodedString]];
    }
    url = [NSURL URLWithString:
           [NSString stringWithFormat:
            @"https://%@/2/string/output?client=ios&api-key=%@&platform-id=%@&md5=%@&locale=%@", 
            //          @"http://%@/1/iphone/output?api-key=%@&project=%@&md5=%@&language=%@", 
            helper.domain,
            helper.key,
            project,
            helper.md5,
            paramLanguages]];
    success = (url != nil);
    if (helper.debug) {
        NSLog(@"OneSky: request url %@", url);
    }
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        //self.statusLabel.text = @"Invalid URL";
    } else {
        
        // Open a stream for the file we're going to receive into.
        
        self.filePath = helper.jsonFilePath;
        //self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"json"]]; 
        assert(self.filePath != nil);
        
        self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
        assert(self.fileStream != nil);
        
        [self.fileStream open];
        
        // Open a connection for the URL.
        request = [NSURLRequest requestWithURL:url]; 
        assert(request != nil);
        
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        assert(self.connection != nil);
        
        // Tell the UI we're receiving.
        //[self _receiveDidStart];
    }
}

- (void)_receiveDidStopWithStatus:(NSString *)statusString {
    if (statusString == nil) {
        assert(self.filePath != nil);
        //self.imageView.image = [UIImage imageWithContentsOfFile:self.filePath];
        //statusString = @"GET succeeded";
    }
    //self.statusLabel.text = statusString;
    //self.getOrCancelButton.title = @"Get";
    //[self.activityIndicator stopAnimating];
    //[[AppDelegate sharedAppDelegate] didStopNetworking];
}


- (void)_stopReceiveWithStatus:(NSString *)statusString {
    if (self.connection != nil) {
        NSLog(@"OneSky: connection= %@", self.connection);
        [self.connection cancel];
        self.connection = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
        
        //NSDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:self.plistFilePath];
        //[dict writeToFile:self.plistFilePath atomically:YES];
        //[[OneSkyHelper sharedHelper] refreshLocalizationsDictionaryFromJson];
        [_helper refreshLocalizationsDictionaryFromJson];
    }
    [self _receiveDidStopWithStatus:statusString];
    self.filePath = nil;
}

- (BOOL)isReceiving {
    return (self.connection != nil);
}

- (void)startReceive {
    if (self.isReceiving) {
        [self _stopReceiveWithStatus:@"Cancelled"];
    }
    [self _startReceive];
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    if (_helper.debug) {
        NSLog(@"didReceiveResponse %@: %@", [response URL],
              [(NSHTTPURLResponse*)response allHeaderFields]);
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data {
#pragma unused(theConnection)
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
    assert(theConnection == self.connection);
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    bytesWrittenSoFar = 0;
    do {
        bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
            [self _stopReceiveWithStatus:@"File write error"];
            break;
        } else {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
#pragma unused(theConnection)
#pragma unused(error)
    assert(theConnection == self.connection);
    
    [self _stopReceiveWithStatus:@"Connection failed"];
    
    if ([_helper.delegate respondsToSelector:@selector(helper:didFailWithError:)]) {
        [_helper.delegate helper:_helper didFailWithError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
#pragma unused(theConnection)
    assert(theConnection == self.connection);
    
    [self _stopReceiveWithStatus:nil];
    
    if ([_helper.delegate respondsToSelector:@selector(helperDidFinishLoading:)]) {
        [_helper.delegate helperDidFinishLoading:_helper];
    }
}

@end
