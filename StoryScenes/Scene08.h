#import "cocos2d.h"
#import "HUDLayer.h"
#import "Background.h"
#import "Words.h"


#import "SimpleAudioEngine.h"

@interface Scene08 : CCLayer <UIGestureRecognizerDelegate>
{
    
    HUDLayer * _hud;
    CCSpriteBatchNode *_spriteSheetObjects;
    CCSpriteBatchNode *_spriteSheetTextandTravelers;
    CCSpriteBatchNode *_spriteSheet;
    
    CGSize winSize;    
    int Margin;
    
    Background *_background;
    Words *_story;
    
    BOOL readText;
    
}
+(CCScene *) scene;

- (id)initWithHUD:(HUDLayer *)hud;

@end
