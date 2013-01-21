#import "NSMutableDictionary+Merge.h"


@implementation NSMutableDictionary (Merge)

- (void)mergingWithDictionary:(NSDictionary *)dict {
    for (id key in [dict allKeys]) {
        id obj = [dict objectForKey:key];
        id localObj = [self objectForKey:key];
        // Ensure localObj is mutable dictionary for merging
        if ([localObj isKindOfClass:[NSDictionary class]] &&
            ![localObj isKindOfClass:[NSMutableDictionary class]]) {
            localObj = [[localObj mutableCopy] autorelease];
        }
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
