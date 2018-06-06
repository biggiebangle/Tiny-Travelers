//
//  WeatherData.m
//

#import "WeatherData.h"

@implementation WeatherData

@synthesize weatherNumber = _weatherNumber;
@synthesize windSpeed = _windSpeed;
@synthesize cloudCover = _cloudCover;
@synthesize temperature = _temperature;


-(id)initWithWeatherNumber:(int)number
                 windSpeed:(int)speed
                cloudCover:(int)coverage
                temperature:(int)temp{
    
    if ((self = [super init])) {
        
        self.weatherNumber = number;
        self.windSpeed = speed;
        self.cloudCover = coverage;
        self.temperature = temp;

    }
    return self;
}

- (void) dealloc {
    //[super dealloc];
}

@end