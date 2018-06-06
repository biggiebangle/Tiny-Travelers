//
//  HelloWorldLayer.h
//  cityscapeV2
//
//  Created by Catherine Cavanagh on 2/27/14.
//  Copyright Catherine Cavanagh 2014. All rights reserved.
//


//#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "HUDLayer.h"
#import "Store.h"
#import "MyContactListener.h"
#import <CoreMotion/CoreMotion.h>

 
#define PTM_RATIO 32


@interface Cityscape : CCLayer 
{
	
    
    b2World *_world;
    b2Body *_body;
    CCSprite *_ball;
    b2Body *groundBody;
    b2Body *_pizzaEaterBody;
    b2Fixture *_pizzaEaterFixture;
    
    MyContactListener *_contactListener;
    CCSprite *Guy;
    NSInteger n;
    int pizzaTag;
    NSMutableArray *allThePizzas;
    NSMutableArray *pizzaGuyAnimFrames;
    
    HUDLayer * _hud;
    CCSpriteBatchNode *_spriteSheet;
    CCSpriteBatchNode *_cityscapeSpriteSheet;
    
    NSString *_foodItem;
    CCMenu *foodMenu;
    
    CMMotionManager *_motionManager;
    
    Store *_store;
    BOOL allPurchased;
    BOOL _storeClosed;
}



+(CCScene *) scene;
- (id)initWithHUD:(HUDLayer *)hud;
@end
