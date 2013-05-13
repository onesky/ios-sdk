#import "OneSkyHelper.h"

#import "NSMutableDictionary+Merge.h"
#import "OneSkyDownloader.h"


static NSString* STRING_NOT_FOUND = @">>>*.*, STRING_NOT_FOUND!!!<<<";

@implementation OneSkyHelper

static OneSkyHelper* _sharedHelper = nil;

+ (OneSkyHelper*)sharedHelper {
    if (!_sharedHelper){
        _sharedHelper = [[self alloc] init];
        _sharedHelper.domain = @"api.oneskyapp.com";
        _sharedHelper.defaultTableName = @"Default";
        _sharedHelper.preferredLanguage = nil;
    }
    return _sharedHelper;
}

@synthesize domain = _domain;
@synthesize key = _key;
@synthesize debug = _debug;
@synthesize refreshUpdatesImmediately=_refreshUpdatesImmediately;
@synthesize md5;
@synthesize platformId=_platformId, version=_version;
@synthesize bundle=_bundle;
@synthesize delegate=_delegate;
@synthesize defaultTableName=_defaultTableName;
@synthesize preferredLanguage=_preferredLanguage;

- (NSBundle*)bundle {
    if (!_bundle) {
        _bundle = [NSBundle mainBundle];
    }
    return _bundle;
}

- (OneSkyDownloader*)downloader {
    if (!_downloader) {
        _downloader = [[OneSkyDownloader alloc] initWithHelper:self];
    }
    return _downloader;
}

- (NSMutableDictionary*)localizationsDictionary {
    if (!_localizationsDictionary) {
        assert(self.platformId != 0);
        _localizationsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:self.plistFilePath];
        if (nil == _localizationsDictionary) {
            _localizationsDictionary = [NSMutableDictionary new];
            [_localizationsDictionary writeToFile:self.plistFilePath atomically:YES];
        }
    }
    if ([_localizationsDictionary isKindOfClass:[NSDictionary class]] &&
        ![_localizationsDictionary isKindOfClass:[NSMutableDictionary class]]) {
        _localizationsDictionary = [[_localizationsDictionary mutableCopy] autorelease];
    }
    return _localizationsDictionary;
}

- (void)dealloc {
    [_downloader release], _downloader=nil;
    [_fallbackDictionary release], _fallbackDictionary=nil;
    
    [super dealloc];
}

- (NSString*)md5 {
    NSLog(@"OneSky: checking md5 %@", [self localizationsDictionary]);
    return [[self localizationsDictionary] objectForKey:@"md5"];
}

- (NSString*)filePath:(NSString*)fileName {
    static NSString* documentsPath = nil;
    if (!documentsPath) {
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [[dirs objectAtIndex:0] retain];
    }
    NSString* filePath = [documentsPath stringByAppendingPathComponent:fileName];
    return filePath;
}

- (NSString*)jsonFilePath {
    if (_debug) {
        NSLog(@"OneSky: jsonFilePath=%@", [self filePath:[NSString stringWithFormat:@"OneSkyStrings-%d.json", self.platformId]]);
    }
    return [self filePath:[NSString stringWithFormat:@"OneSkyStrings-%d.json", self.platformId]];
}

- (NSString*)plistFilePath {
    return [self filePath:@"OneSkyStrings.plist"];
}

- (NSString*)historyPlistFilePath {
    return [self filePath:[NSString stringWithFormat:@"OneSkyHistory-%d.plist", self.platformId]];
}

- (NSString*)localizedStringForKey:(NSString*)key value:(NSString*)value table:(NSString*)tableName dictionary:(NSDictionary*)dict {
    if ([dict count] > 0) {
        if (!tableName) {
            tableName = _defaultTableName;
        }
        NSDictionary* localizationTable = [dict objectForKey:tableName];
        if ([localizationTable count] > 0) {
            NSMutableArray *preferredLanguages = [NSMutableArray arrayWithCapacity:[[NSLocale preferredLanguages] count]];
            if (_preferredLanguage) {
                [preferredLanguages addObject:_preferredLanguage];
            }
            [preferredLanguages addObjectsFromArray:[NSLocale preferredLanguages]];
            for (NSString* language in preferredLanguages) {
                NSDictionary* localizationDictionary = [localizationTable objectForKey:language];
                if ([localizationDictionary objectForKey:key]) {
                    if (_debug) {
                        NSLog(@"OneSky: translate (%@) %@ => %@", language, key, [localizationDictionary objectForKey:key]);
                        NSLog(@"OneSky: localizedStringForKey localizationTable=%@, preferredLanguages=%@", localizationTable, preferredLanguages);
                    }
                    return [localizationDictionary objectForKey:key];
                }
            }
        } else if (_debug) {
            NSLog(@"OneSky: no localizationTable %@, %@", tableName, dict);
            return [self localizedStringForKey:key value:value table:tableName dictionary:[NSDictionary dictionaryWithObject:dict forKey:tableName]];
        }
    } else if (_debug) {
        NSLog(@"OneSky: localizationsDictionary empty!!!, %@", key);
    }
    return nil;
}

- (NSUInteger)historyMaxCount {
    return 20;
}

- (NSArray*)sortedHistoryKeys {
    NSMutableArray *keys = [NSMutableArray array];
    for (NSDictionary* dict in self.history) {
        [keys addObject:[dict objectForKey:@"key"]];
    }
    return keys;
}

- (NSArray*)history {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:self.historyPlistFilePath];
    NSMutableArray *history = [data objectForKey:@"history"];
    if (!history) {
        return [NSArray array];
    }
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"date"
                                                  ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [history sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

- (void)logKey:(NSString*)key {
    if (_debug) {
        NSLog(@"OneSky: logKey: %@", key);
    }
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:self.historyPlistFilePath];
    if (nil == data) {
        data = [NSMutableDictionary new];
    }
    NSMutableArray *history = [data objectForKey:@"history"];
    if (!history) {
        history = [NSMutableArray array];
        [data setObject:history forKey:@"history"];
    }
    NSInteger len = [history count] - [self historyMaxCount] + 1;
    if (len >= 0) {
        [history removeObjectsInRange:NSMakeRange(0, len)];
    }
    [history addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                        key, @"key",
                        [NSDate date], @"date",
                        nil]];
    [data writeToFile:self.historyPlistFilePath atomically:YES];
    [data release];
}

- (NSString*)localizedStringForKey:(NSString*)key value:(NSString*)value table:(NSString*)tableName {
    if (_debug) {
        NSLog(@"OneSky: localizationsDictionary=%@", [self localizationsDictionary]);
    }
    NSString *result = [self localizedStringForKey:key value:value table:tableName dictionary:[self localizationsDictionary]];
    if (_debug) {
        NSLog(@"OneSky: after [self localizationsDictionary], %@", result);
    }
    if (nil == result && [_fallbackDictionary count] > 0) {
        result = [self localizedStringForKey:key value:value table:tableName dictionary:_fallbackDictionary];
        if (_debug) {
            NSLog(@"OneSky: after _fallbackDictionary, %@, %@", result, _fallbackDictionary);
        }
    }
    if (nil == result) {
        result = [self.bundle localizedStringForKey:key value:STRING_NOT_FOUND table:tableName];
        if ([self.delegate respondsToSelector:@selector(helper:didFailToFindStringKey:)]
            && [result isKindOfClass:[NSString class]]
            && [STRING_NOT_FOUND isEqualToString:result]) {
            [self.delegate helper:self didFailToFindStringKey:key];
        }
        result = [self.bundle localizedStringForKey:key value:value table:tableName];
        if (_debug) {
            NSLog(@"OneSky: after bundle, %@", result);
        }
    }
    [self logKey:key];
    return result;
}

- (void)checkForUpdate {
    [[self downloader] startReceive];
}

- (void)checkForUpdateOfLanguages:(NSArray*)languages {
    OneSkyDownloader* downloader = [self downloader];
    downloader.languages = languages;
    [downloader startReceive];
}

- (void)checkForUpdateOfPreferredLanguage {
    NSString *preferredLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    if (_preferredLanguage) {
        preferredLanguage = _preferredLanguage;
    }
    [self checkForUpdateOfLanguages:[NSArray arrayWithObject:preferredLanguage]];
}

- (void)deleteCache {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:self.jsonFilePath error:NULL];
    [fileManager removeItemAtPath:self.plistFilePath error:NULL];
}

- (void)refreshLocalizationsDictionaryFromJson {
    NSData *jsonData = [NSData dataWithContentsOfFile:self.jsonFilePath];
    NSString* jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    if (_debug) {
        NSLog(@"OneSky: response= %@", jsonString);
    }
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    if (json 
        && !([[json objectForKey:@"response"] isKindOfClass:[NSString class]]
             && [[json objectForKey:@"response"] isEqualToString:@"up-to-date"])) {
            NSMutableDictionary* dict = nil;
            dict = [self localizationsDictionary];
            NSDictionary *newTranslationDict = [json objectForKey:@"translation"];
            if ([newTranslationDict isKindOfClass:[NSDictionary class]]) {
                if (_debug) {
                    NSLog(@"OneSky: mergingWithDictionary:newTranslationDict");
                }
                [dict mergingWithDictionary:newTranslationDict];
            } else if (_debug) {
                NSLog(@"OneSky: not a dictionary returned, probably a empty array");
            }
            if ([json objectForKey:@"md5"]) {
                [dict setObject:[json objectForKey:@"md5"] forKey:@"md5"];
            }
            if (_debug) {
                NSLog(@"OneSky: updating strings file with content = %@", dict);
            }
            BOOL success = [dict writeToFile:self.plistFilePath atomically:YES];
            if (success) {
                if (_debug) {
                    NSLog(@"OneSky: updated strings file with content = %@", dict);
                }
            } else if (_debug) {
                NSLog(@"OneSky: failed to save strings file");
            }
        } else if (_debug) {
            NSLog(@"OneSky: no need to save localizationsDictionary");
            NSLog(@"OneSky: response= %@", jsonString);
            NSLog(@"OneSky: localizationsDictionary= %@", [self localizationsDictionary]);
        }
}

- (void)setFallbackJsonPath:(NSString*)path {
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    _fallbackDictionary = [[NSMutableDictionary dictionaryWithCapacity:10] retain];
    if ([json objectForKey:@"translation"]) {
        [_fallbackDictionary setDictionary:[json objectForKey:@"translation"]];
    }
    if ([json objectForKey:@"md5"]) {
        [_fallbackDictionary setObject:[json objectForKey:@"md5"] forKey:@"md5"];
    }
    if (_debug) {
        NSLog(@"OneSky: set _fallbackDictionary, %@", _fallbackDictionary);
    }
}

- (void)setFallbackJsonNamed:(NSString*)name {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *jsonPath = [bundlePath stringByAppendingPathComponent:name];
    [self setFallbackJsonPath:jsonPath];
}

@end
