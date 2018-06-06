//
//  GameData.m
//

#import "GameData.h"

@implementation GameData

@synthesize selectedChapter = _selectedChapter; 
@synthesize selectedLevel = _selectedLevel;
@synthesize sound = _sound; 
@synthesize music = _music;
@synthesize weatherNumber = _weatherNumber;
@synthesize windSpeed = _windSpeed;
@synthesize cloudCover = _cloudCover;
@synthesize temperature = _temperature;

-(id)initWithSelectedChapter:(int)chapter
             selectedLevel:(int)level
                     sound:(BOOL)sound
                     music:(BOOL)music
               weatherNumber:(int)number
                   windSpeed:(int)speed
                  cloudCover:(int)coverage
                  temperature:(int)temp{
    
    if ((self = [super init])) {
        
        self.selectedChapter = chapter; 
        self.selectedLevel = level; 
        self.sound = sound;  
        self.music = music;
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



