//
//  MainMenu.h
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <UIKit/UIKit.h>
#import "Background.h"
#import "Weather.h"
#import "Store.h"
#import "GameData.h"
#import "GameDataParser.h"
//#import "CCScrollLayer.h"

@interface NOscrollMainMenu : CCLayer {
    
    CCSpriteBatchNode *_spriteSheetMain;
    CCSpriteBatchNode *_spriteSheet;
    CCSpriteBatchNode *_spriteSheetStore;
    CCMenuItem *_storeButton;
    CCMenuItem *_musicOn;
    CCMenuItem *_musicOff;
    CCMenuItemToggle *toggleMusicButton;
    CCMenu *toggleMusicMenu;
    int menuMargin;
    BOOL _storeClosed;
    CGSize screenSize;
    GameData *gameData;
    
    Background *_background;
    Weather *_weather;
    Store *_store;
    BOOL allPurchased;
    
    CCLayerColor *_shadowLayer;
    CCParticleSystem *emitter_;
    NSDictionary *problem1;
    NSDictionary *problem2;
    NSDictionary *problem3;
    NSDictionary *problem0;
    NSDictionary *answers;
    NSDictionary *currentMathProblem;
    NSInteger currentProblemIndex;
    NSMutableArray * mathAnswerBoundingBox;
    NSMutableArray * mathAnswerThumbs;
    CCSprite * selMathSprite;
    
    
    
}

@property (nonatomic, assign) BOOL iPad;
@property (nonatomic, assign) NSString *device;
+(CCScene *) scene;
@end
