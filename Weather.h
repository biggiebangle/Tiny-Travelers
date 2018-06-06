//
//  Weather.h
//  dkta
//
//  Created by Catherine Cavanagh on 12/23/13.
//  Copyright 2013 Catherine Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface Weather : CCNode {
    
    int _weatherNumber;
    int _windSpeed;
    int _cloudCover;
    CCSpriteBatchNode *_spriteSheet;
    
}


@property (nonatomic, assign) int weatherNumber;
@property (nonatomic, assign) int windSpeed;
@property (nonatomic, assign) int cloudCover;


@end
