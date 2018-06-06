//
//  HelloWorldLayer.h
//  matchingGame
//
//  Created by Catherine Cavanagh on 8/27/13.
//  Copyright Catherine Cavanagh 2013. All rights reserved.
//


//#import <GameKit/GameKit.h>


#import "cocos2d.h"
#import "HUDLayer.h"
#import "Background.h"







//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32


// MatchingGame
@interface MatchingGame : CCLayer
{
    HUDLayer * _hud;
    CCSpriteBatchNode *_spriteSheetMatching;
    CCSpriteBatchNode *_spriteSheetMatchingB;
    CCSpriteBatchNode *_spriteSheetMatchingC;
    CCSpriteBatchNode *_spriteSheetMatchingD;
    CCSpriteBatchNode *_spriteSheet;
    NSMutableArray * boundingBoxes;
    CCSprite * selSprite;
    NSMutableArray * movableThumbs;
    NSString *thumbDataString;
    int matchMargin;
    CCParticleSystem *ps;
    BOOL touchFlag;
    Background *_background;


   
}



+ (CCScene *) scene;

- (id)initWithHUD:(HUDLayer *)hud;

- (void)spawnThumbs;

- (void)spawnBoundingBox;

- (void) psDone;



@end
