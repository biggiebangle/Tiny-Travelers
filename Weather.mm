//
//  Weather.m
//  dkta
//
//  Created by Catherine Cavanagh on 12/23/13.
//  Copyright 2013 Catherine Cavanagh. All rights reserved.
//

#import "Weather.h"
#import "GameData.h"
#import "GameDataParser.h"


@implementation Weather



- (id)init {
    if ((self = [super init])) {
        
        GameData *gameData = [GameDataParser loadData];
        self.weatherNumber = gameData.weatherNumber;
        self.windSpeed = gameData.windSpeed;
        self.cloudCover = gameData.cloudCover;
        
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"MENU25.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"MENU25.plist"];
        [self addChild:_spriteSheet];
        
        [self weatherConditions:_weatherNumber ];

    }
    return self;
}


- (void) weatherConditions: (int)weatherNumber {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;

   
    
    int someNumber = weatherNumber;
    NSString * allDigits = [NSString stringWithFormat:@"%i", someNumber];
    NSString * firstDigit = [allDigits substringToIndex:1];
    
    
    if ([firstDigit isEqual: @"5"] || [firstDigit isEqual: @"3"] || [firstDigit  isEqual: @"2"]){

        CCParticleRain *emiter = [[CCParticleRain alloc] init ];
        emiter.texture = [[CCTextureCache sharedTextureCache] addImage:@"r2.png"];
        emiter.position = ccp(winSize.width/2, winSize.height);
        [self addChild:emiter];
        
        }
    
    if ([firstDigit isEqual: @"6"]){
        
        CCParticleSnow *emiter = [[CCParticleSnow alloc] init ];
        emiter.texture = [[CCTextureCache sharedTextureCache] addImage:@"snow.png"];
        emiter.position = ccp(winSize.width/2, winSize.height);
        [self addChild:emiter];
        
    }
    
    if ([firstDigit isEqual: @"8"]){
        NSString *sunName =  [NSString stringWithFormat:@"Sunshine-smile.png"];
        CCSprite *sun = [CCSprite spriteWithSpriteFrameName:sunName];
        sun.scale = .5;
        int x1 = winSize.width - sun.contentSize.width/4;
        int y1 = winSize.height - sun.contentSize.height/4;
        int x2 = sun.contentSize.width/4;
        int y2 = winSize.height - sun.contentSize.height/4;
        
        NSMutableArray *xArray = [[NSMutableArray alloc] init];
        [xArray addObject:[NSNumber numberWithInt:x1]];
        [xArray addObject:[NSNumber numberWithInt:x2]];

        
        NSMutableArray *yArray = [[NSMutableArray alloc] init];
        [yArray addObject:[NSNumber numberWithInt:y1]];
        [yArray addObject:[NSNumber numberWithInt:y2]];

        
        int a = arc4random() % 2;
        int xOriginal=[xArray[a]intValue];
        int yOriginal=[yArray[a]intValue];
        
        int b = arc4random() % 2;
        int xSecond =[xArray[b]intValue];
        int ySecond =[yArray[b]intValue];
  
        
        //CCLOG(@"Positions= %i,%i,%i,%i", a,b,c,d);
       
        sun.position = ccp(xOriginal, yOriginal);
        [self addChild:sun];
        
        CCAction *action = [CCSequence actions:
                            [CCRotateBy actionWithDuration:0.25 angle:-45],
                            [CCRotateBy actionWithDuration:0.5 angle:90],
                            [CCRotateBy actionWithDuration:0.25 angle:-45],
                            [CCDelayTime actionWithDuration:1],
                            [CCMoveTo actionWithDuration:45 position:ccp(xSecond,ySecond)],
                            [CCDelayTime actionWithDuration:2],
                            [CCRotateBy actionWithDuration:0.25 angle:-45],
                            [CCRotateBy actionWithDuration:0.5 angle:90],
                            [CCRotateBy actionWithDuration:0.25 angle:-45],
                            [CCDelayTime actionWithDuration:1],
                            [CCMoveTo actionWithDuration:45 position:ccp(xOriginal,yOriginal)],
                            [CCDelayTime actionWithDuration:4],
                            [CCRotateBy actionWithDuration:0.25 angle:-45],
                            [CCRotateBy actionWithDuration:0.5 angle:90],
                            [CCRotateBy actionWithDuration:0.25 angle:-45],
                            [CCDelayTime actionWithDuration:1],
                            [CCMoveTo actionWithDuration:45 position:ccp(xSecond,ySecond)],
                            [CCDelayTime actionWithDuration:4],
                            [CCRotateBy actionWithDuration:0.25 angle:-45],
                            [CCRotateBy actionWithDuration:0.5 angle:90],
                            [CCRotateBy actionWithDuration:0.25 angle:-45],
                            [CCDelayTime actionWithDuration:1],
                            [CCMoveTo actionWithDuration:45 position:ccp(xOriginal,yOriginal)],nil];
        
        [sun runAction:action];
        
        
    }
    
}

- (void) onExit {
    [self removeAllChildrenWithCleanup:YES];
    
}

@end
