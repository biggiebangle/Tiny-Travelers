//
//  MainMenu.h  
//  

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <UIKit/UIKit.h>
//#import "Background.h"
//#import "Weather.h"
//#import "Store.h"
#import "GameData.h"
#import "GameDataParser.h"
#import "CCScrollLayer.h"

@interface MainMenu : CCLayer {
    
    CCSpriteBatchNode *_spriteSheetMain;
    CCSpriteBatchNode *_spriteSheet;
    CCMenuItem *_storeButton;
    CCMenuItem *_musicOn;
    CCMenuItem *_musicOff;
    CCMenuItemToggle *toggleMusicButton;
    CCMenu *toggleMusicMenu;
    int menuMargin;
    BOOL _storeClosed;
    BOOL _storyPurchased;
    CGSize screenSize;
    GameData *gameData;

   // Background *_background;
   // Weather *_weather;
   // Store *_store;
    BOOL allPurchased;
    CCScrollLayer *scroller;
   //CCLayer *layer1;
  

 
}


// returns a CCScene that contains the MainMenu as the only child
+(CCScene *) scene;
@end
