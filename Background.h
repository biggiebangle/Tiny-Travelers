//
//  Words.h
//  dkta
//
//  Created by Catherine Cavanagh on 12/23/13.
//  Copyright 2013 Catherine Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface Background : CCNode {
    
    int _weatherNumber;
    int _windSpeed;
    int _cloudCover;
    CCSprite *_background;
    CCSpriteBatchNode *_spriteSheet;
    CGSize winSize;
    
}


@property (nonatomic, assign) int weatherNumber;
@property (nonatomic, assign) int windSpeed;
@property (nonatomic, assign) int cloudCover;
@property (nonatomic, assign) BOOL iPad;
@property (nonatomic, assign) NSString *device;

-(void)createCity;
-(void)createBackgroundWithNoise;

@end
