#import "TTIAPHelper.h"

@implementation TTIAPHelper

+ (TTIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static TTIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:

#ifdef TTLUGGAGE
                                      @"com.biggiebangle.luggagegame.removeAd",
#else 
                                      @"com.biggiebangle.tinytravelersnyc.complete",

#endif
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end