//
//  sceneTag.h
//  puzzle
//
//  Created by Catherine Cavanagh on 9/16/13.
//  Copyright 2013 Catherine Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface sceneTag : CCLayer {
    
enum {  
    
        kScenePuzzle = 0,
        kSceneMatch = 1,
        kSceneCityscape = 2,
        kSceneLuggage = 3,
        kSceneStory = 4,
        kStoryPage = 5
       };
}

@property (nonatomic, assign) BOOL openStoreTag;

@end
