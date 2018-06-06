//
//  TinyTravelerIntro.h
//  dkta
//
//  Created by Catherine Cavanagh on 6/10/14.
//  Copyright 2014 Catherine Cavanagh. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <UIKit/UIKit.h>

#import "GameData.h"
#import "GameDataParser.h"
#import "Background.h"


@interface TinyTravelerIntro : CCLayer {
    
    CCSpriteBatchNode *_spriteSheetHUD;
    CCSpriteBatchNode *_spriteSheet;
    CCMenuItem *_musicOn;
    CCMenuItem *_musicOff;
    CCMenuItem *_nextButton;
    CCMenuItemToggle *toggleMusicButton;
    CCMenu *toggleMusicMenu;
    int Margin;
    CGSize screenSize;
    GameData *gameData;    
    CCSprite *_traveler1;
    CCSprite *_traveler2;
    CCSprite *_traveler3;
    
    Background *_background;


}

@property (nonatomic, assign) BOOL iPad;
@property (nonatomic, assign) NSString *device;

+(CCScene *) scene;
@end
