//
//  Puzzle.h
//  KTA
//
//  Created by Catherine Cavanagh on 8/27/13.
//  Copyright Catherine Cavanagh 2013. All rights reserved.
//


//#import <GameKit/GameKit.h>


#import "cocos2d.h"
#import "HUDLayer.h"
#import "Background.h"




// Puzzle
@interface Puzzle : CCLayer
{
    HUDLayer * _hud;
    CCSpriteBatchNode *_spriteSheetPuzzle;
    CCSpriteBatchNode *_spriteSheetPuzzle2;
    CCSpriteBatchNode *_spriteSheet;
    NSMutableArray * boundingBoxes;
    CCSprite *puzzleBg;
    CCSprite * selSprite;
    NSMutableArray * movableThumbs;
    NSString *thumbDataString;
    ccColor3B oldColor;
    int puzzleMargin;
    CCParticleSystem *ps;
    BOOL touchFlag;
    Background *_background;
    int selectedLevel;
    NSArray *thumbXMLData;

   
}


+(CCScene *) scene;

- (id)initWithHUD:(HUDLayer *)hud;

- (void)matchCheck;

- (void)matchGame:(BOOL)won;

- (void)spawnPuzzleThumbs;

- (void)spawnBoundingBox;




@end
