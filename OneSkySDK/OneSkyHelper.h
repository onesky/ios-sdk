@class OneSkyHelper;
@class OneSkyDownloader;

@protocol OneSkyHelperDelegate <NSObject>

@optional

- (void)helperDidFinishLoading:(OneSkyHelper*)helper;
- (void)helper:(OneSkyHelper*)helper didFailWithError:(NSError*)error;

- (void)helper:(OneSkyHelper*)helper didFailToFindStringKey:(NSString*)key;

@end

// v2
@interface OneSkyHelper : NSObject {
    NSString* _domain;
    NSString* _key;
    NSInteger _platformId;
    NSString* _version;
    NSBundle* _bundle;
    NSString* _defaultTableName;
    
    NSString* _preferredLanguage;
    
    NSMutableDictionary* _localizationsDictionary;
    NSMutableDictionary *_fallbackDictionary;
    
    BOOL _debug;
    
    BOOL _refreshUpdatesImmediately;
    id<OneSkyHelperDelegate> _delegate;
    OneSkyDownloader* _downloader;
}

+ (OneSkyHelper*)sharedHelper;

@property(nonatomic, assign) id<OneSkyHelperDelegate> delegate;
@property(nonatomic, copy) NSString* domain;
@property(nonatomic, copy) NSString* key;
@property(nonatomic, assign) NSInteger platformId;
@property(nonatomic, copy) NSString* version;
@property(nonatomic, copy) NSString* defaultTableName;
@property(nonatomic, copy) NSString* preferredLanguage;
@property(nonatomic, retain) NSBundle* bundle;
@property(nonatomic, retain, readonly) NSString* md5;
@property(nonatomic, retain, readonly) NSString* jsonFilePath;
@property(nonatomic, retain, readonly) NSString* plistFilePath;
@property(nonatomic, retain, readonly) NSString* historyPlistFilePath;
@property(nonatomic, retain, readonly) NSArray* history;
@property(assign) BOOL debug;
@property(assign) BOOL refreshUpdatesImmediately;

- (void)checkForUpdate;
- (void)checkForUpdateOfPreferredLanguage;
- (void)checkForUpdateOfLanguages:(NSArray*)languages;
- (void)deleteCache;
- (NSString*)localizedStringForKey:(NSString*)key value:(NSString*)value table:(NSString*)tableName;

- (NSString*)filePath:(NSString*)fileName;
- (void)refreshLocalizationsDictionaryFromJson;

- (void)setFallbackJsonPath:(NSString*)path;
- (void)setFallbackJsonNamed:(NSString*)nameWithExtension;

- (NSArray*)sortedHistoryKeys;

@end

#define OneSkyString(key, comment) \
[[OneSkyHelper sharedHelper] localizedStringForKey:(key) value:@"" table:nil]
#define OneSkyStringFromTable(key, tbl, comment) \
[[OneSkyHelper sharedHelper] localizedStringForKey:(key) value:@"" table:(tbl)]
#define OneSkyStringFromTableInBundle(key, tbl, bundle, comment) \
[bundle localizedStringForKey:(key) value:@"" table:(tbl)]
#define OneSkyStringWithDefaultValue(key, tbl, bundle, val, comment) \
[bundle localizedStringForKey:(key) value:(val) table:(tbl)]
