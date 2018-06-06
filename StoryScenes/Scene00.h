



#import "cocos2d.h"
#import "HUDLayer.h"
#import "Background.h"


#import "SimpleAudioEngine.h"


@interface Scene00 : CCLayer <UIGestureRecognizerDelegate>
{
    HUDLayer * _hud;
    CCSpriteBatchNode *_spriteSheetObjects;
    CCSpriteBatchNode *_spriteSheetTextandTravelers;
    CCSpriteBatchNode *_spriteSheet;
    
    //CCSprite *buttonStart;

    int Margin;

    Background *_background;

    
    
    
}

@property (nonatomic, assign) BOOL unlockedGame;

+(CCScene *) scene;

- (id)initWithHUD:(HUDLayer *)hud;




@end
