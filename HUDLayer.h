//
//  HUDLayer.h
//  matchingGame
//
//  Created by Catherine Cavanagh on 9/1/13.
//  Copyright (c) 2013 Catherine Cavanagh. All rights reserved.
//



#import "cocos2d.h"
#import "Store.h"


@interface HUDLayer : CCLayer {
    
    int Margin;
    CCSpriteBatchNode *_spriteSheet;
    CCLayerColor *_shadowLayer;
    CCLayerColor *_sideShadowLayer;
    CCMenuItemSprite *endButton;
    CCMenuItemSprite *continueButton;
    CCMenuItemSprite *restartButton;
    CCMenuItem *_musicOn;
    CCMenuItem *_musicOff;
    CCMenuItemToggle *toggleMusicButton;
    CCSprite *frown;
    CCSprite *smileDance;
    
    CCMenu *endMenu;
    CCMenu *midGameMenu;
    
    CCMenuItem *_show;
    CCMenuItem *_hide;
    CCMenu *toggleMenu;
    
    
    int _openStore;
    Store *_store;
    
    CGSize winSize;
    
    
}


- (void)restartTapped:(id)sender;
- (void)levelUpTapped:(id)sender;
- (void)backTapped:(id)sender;
- (void)nextTapped:(id)sender;
- (void)continueGameTapped:(id)sender;
- (void)showRestartMenu:(BOOL)won;
- (void)showLuggageRestartMenu:(BOOL)won;
- (void)spawnShadowLayer;
- (void)removeShadowLayer;
- (void)showMidGameMenu;
- (void)hideMidGameMenu;
- (void)removeMidGameMenu;
- (void)hideMidGameMenuAtEnd;
- (void)spawnHappyFace;
- (void)spawnSadFace;
- (void)spawnMidGameMenu;



@end