

#import "cocos2d.h"
#import "HUDLayer.h"
#import "Background.h"
#import "Words.h"

#import "SimpleAudioEngine.h"

@interface Scene06 : CCLayer <UIGestureRecognizerDelegate>{
    
    HUDLayer * _hud;
    CCSpriteBatchNode *_spriteSheetObjects;
    CCSpriteBatchNode *_spriteSheet;

    
    int Margin;
    
    Background *_background;
    Words *_story;
     
    BOOL readText;
    CGSize winSize;
    
}
+(CCScene *) scene;

- (id)initWithHUD:(HUDLayer *)hud;

@end
