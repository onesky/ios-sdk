#import "NSMutableDictionary+Merge.h"


@implementation NSMutableDictionary (Merge)

- (id)mutableDictionaryCopyIfNeeded:(id)dictObj
{
    if ([dictObj isKindOfClass:[NSDictionary class]] &&
        ![dictObj isKindOfClass:[NSMutableDictionary class]]) {
        dictObj = [[dictObj mutableCopy] autorelease];
    }
    return dictObj;
}

- (void)mergingWithDictionary:(NSDictionary *)dict
{
    for (id key in [dict allKeys]) {
        id obj = [dict objectForKey:key];
        id localObj = [self objectForKey:key];
        // Ensure localObj is mutable dictionary for merging
        localObj = [self mutableDictionaryCopyIfNeeded:localObj];
        obj = [self mutableDictionaryCopyIfNeeded:localObj];
        if ([obj isKindOfClass:[NSDictionary class]] &&
            [localObj isKindOfClass:[NSMutableDictionary class]]) {
            // Recursive merge for NSDictionary
            [localObj mergingWithDictionary:obj];
        } else if (obj) {
            [self setObject:obj forKey:key];
        }
    }
}

@end
