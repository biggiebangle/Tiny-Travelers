//
//  Luggage.h
//  KTA
//
//  Created by Catherine Cavanagh on 8/27/13.
//  Copyright Catherine Cavanagh 2013. All rights reserved.
//


#import <GameKit/GameKit.h>


#import "cocos2d.h"
#import "HUDLayer.h"
#import "sceneTag.h"
#import "Background.h"




#ifdef ANDROID
#else
    #import "MyiAd.h"

#endif



// Luggage
@interface Luggage : CCLayer
{
    HUDLayer * _hud;
    CCSpriteBatchNode *_spriteSheetLuggage;
    CCSpriteBatchNode *_spriteSheetLuggageAnimation;
    CCSpriteBatchNode *_spriteSheet;
    NSMutableArray * boundingBoxes;
    NSMutableArray * matches;
    CCSprite *luggageBg;
    CCSprite * selSprite;
    CGPoint selSpriteOriginalPosition;
    NSMutableArray *circles;
    CCParticleSystem *checkEmitter;
    BOOL checkMarkParticles;
    BOOL touchFlag;
    NSString *thumbDataString;
    NSArray *thumbXMLData;
    NSMutableArray * movableThumbs;
    ccColor3B oldColor;
    int luggageMargin;
    NSMutableArray *luggageAnimFrames;
    CCParticleSystem *ps;
    Background *_background;
    int weatherNumber;
    int temperature;
    
    
    
#ifdef ANDROID
#else
    BOOL noiAdPurchased;
    MyiAd   *mIAd;
#endif
    

  
   

   
}

@property (nonatomic, assign) BOOL unlockedGame;

+(CCScene *) scene;

- (id)initWithHUD:(HUDLayer *)hud;

- (void)matchCheck;

- (void)matchGame:(BOOL)won;


@end
