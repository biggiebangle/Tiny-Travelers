//
//  WeatherData.h
//

#import <Foundation/Foundation.h>

@interface WeatherData : NSObject {
    
    int _weatherNumber;
    int _windSpeed;
    int _cloudCover;
    int _temperature;
 

}

@property (nonatomic, assign) int weatherNumber;
@property (nonatomic, assign) int windSpeed;
@property (nonatomic, assign) int cloudCover;
@property (nonatomic, assign) int temperature;


-(id)initWithWeatherNumber:(int)number
               windSpeed:(int)speed
             cloudCover:(int)coverage
            temperature:(int)temp;

@end