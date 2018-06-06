//
//  Store.h
//  dkta
//
//  Created by Catherine Cavanagh on 3/14/14.
//  Copyright 2014 Catherine Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Background.h"
#import "Weather.h"
#import "GameData.h"
#import "GameDataParser.h"


@interface Store : CCNode<CCTouchOneByOneDelegate >{
    
    Background *_background;
    CCLayerColor *_shadowLayer;
    CCSpriteBatchNode *_spriteSheet;
    CCSpriteBatchNode *_spriteSheetStore;
    CCMenuItem *_exitButton;
    
    CCMenuItemSprite *imageButton;
    CCMenu *imageMenu;
    CCMenu *buyMenu;
    CCMenu *_exitMenu;
    CCMenu *_restoreMenu;
    CCLayer *purchaseItem;
    
    
    int menuMargin;
    CGSize screenSize;
    CCParticleSystem *emitter_;

    
    BOOL childGateON;
    
    NSDictionary *problem1;
    NSDictionary *problem2;
    NSDictionary *problem3;
    NSDictionary *problem0;

    NSDictionary *currentMathProblem;
    NSInteger currentProblemIndex;
    
    NSMutableArray * answers;
    NSMutableArray * boundingBoxes;
    NSMutableArray * movableThumbs;
    CCSprite * selSprite;
    CGPoint selSpriteOriginalPosition;
    int numberOfGates;
   
}


@property (nonatomic, assign) BOOL iPad;
@property (nonatomic, assign) NSString *device;

//- (void)specifyStartLevel;

@end
