//
//  LevelSelect.h  
//  

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MatchingGame.h"
#import "Background.h"
#import "Store.h"
#import "GameData.h"
#import "GameDataParser.h"

@interface LevelSelect : CCLayer {
    CCSpriteBatchNode *_spriteSheet;
    Background *_background;
    BOOL _storeClosed;
    Store *_store;
    GameData *gameData;
}

@property (nonatomic, assign) BOOL iPad;
@property (nonatomic, assign) NSString *device;

// returns a CCScene that contains the LevelSelect as the only child
+(CCScene *) scene;

@end
