//
//  WeatherDataParser.h
//

#import <Foundation/Foundation.h>

@class WeatherData;

@interface WeatherDataParser : NSObject {}


- (id)DataforXMLParser:(NSData*)xmlData;
+ (WeatherData *)loadData:(NSData*)xmlData;
//+ (void)saveData:(WeatherData *)saveData;

@end