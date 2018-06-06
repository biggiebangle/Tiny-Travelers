//
//  GameData.h
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject {
    
    int _selectedChapter;
    int _selectedLevel;
    BOOL _sound;
    BOOL _music;
    int _weatherNumber;
    int _windSpeed;
    int _cloudCover;
    int _temperature;
}

@property (nonatomic, assign) int selectedChapter;
@property (nonatomic, assign) int selectedLevel;
@property (nonatomic, assign) BOOL sound;
@property (nonatomic, assign) BOOL music;
@property (nonatomic, assign) int weatherNumber;
@property (nonatomic, assign) int windSpeed;
@property (nonatomic, assign) int cloudCover;
@property (nonatomic, assign) int temperature;

-(id)initWithSelectedChapter:(int)chapter
             selectedLevel:(int)level
                     sound:(BOOL)sound
                     music:(BOOL)music
            weatherNumber:(int)number
                windSpeed:(int)speed
                cloudCover:(int)coverage
                  temperature:(int)temp;

@end