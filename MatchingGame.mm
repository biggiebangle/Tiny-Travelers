//
//  HelloWorldLayer.mm
//  matchingGame
//
//  Created by Catherine Cavanagh on 8/27/13.
//  Copyright Catherine Cavanagh 2013. All rights reserved.
//

// Import the interfaces
#import "MatchingGame.h"
#import "sceneTag.h"
#import "LevelSelect.h"
#import "Level.h"
#import "Levels.h"
#import "LevelParser.h"
#import "GameData.h"
#import "GameDataParser.h"

#import "SimpleAudioEngine.h"



@implementation MatchingGame

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    scene.tag = kSceneMatch;
	
	HUDLayer *hud = [HUDLayer node];
    [scene addChild:hud z:1];
    
    MatchingGame *layer = [[MatchingGame alloc] initWithHUD:hud];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)initWithHUD:(HUDLayer *)hud
{
	if( (self=[super init])) {
        
        _hud = hud;
        
        //Arrays for Collision Detection
        boundingBoxes = [[NSMutableArray alloc] init];
        movableThumbs = [[NSMutableArray alloc] init];
        
        //preventing multitouch
        touchFlag = false;
        
        // Create our sprite sheet and frame cache
        _spriteSheetMatching = [CCSpriteBatchNode batchNodeWithFile:@"13Match_apart.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"13Match_apart.plist"];
        [self addChild:_spriteSheetMatching];
        
        _spriteSheetMatchingB = [CCSpriteBatchNode batchNodeWithFile:@"13Match_bpart.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"13Match_bpart.plist"];
        [self addChild:_spriteSheetMatchingB];
        
        _spriteSheetMatchingC = [CCSpriteBatchNode batchNodeWithFile:@"13Match_cpart.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"13Match_cpart.plist"];
        [self addChild:_spriteSheetMatchingC];
        
        _spriteSheetMatchingD = [CCSpriteBatchNode batchNodeWithFile:@"13Match_dpart.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"13Match_dpart.plist"];
        [self addChild:_spriteSheetMatchingD];
        
       
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"HUDSPRITES12.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"HUDSPRITES12.plist"];
        [self addChild:_spriteSheet];
        
        
        GameData *gameData = [GameDataParser loadData];        
        NSString *LargeImage =  [NSString stringWithFormat:@"%dlevel.png", gameData.selectedLevel];
        
      
        //Create Large Image       
        CCSprite *bigImage = [CCSprite spriteWithSpriteFrameName:LargeImage];
        
        //Consistent margin for game and device
        double myDouble = bigImage.contentSize.height*.03125;
        matchMargin = (int)myDouble;
        
        
        //POSITIONING for large image
        CGSize winSize = [CCDirector sharedDirector].winSize;
        bigImage.position = ccp(bigImage.contentSize.width/2 + matchMargin, winSize.height-(bigImage.contentSize.height/2) - matchMargin);
        //[_spriteSheetMatching addChild:bigImage];
        [self addChild:bigImage];
        
        _background = [Background node];
        [self addChild:_background z:-5];
        [_background createCity];
      
        
        [_hud spawnMidGameMenu];
        
        [self spawnBoundingBox];
        
        [self spawnThumbs];
       
        [self schedule:@selector(update:)];
        
        
        [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
   
        

        
        


	}
	return self;
}



- (void)onExitTransitionDidStart{
    
    [[[CCDirector sharedDirector]touchDispatcher] removeDelegate:self];
    
}
- (void)onExit{
  [self removeAllChildrenWithCleanup:YES];
}

- (void)panForTranslation:(CGPoint)translation {
    if (selSprite) {
        [selSprite stopAllActions];
        CGPoint newPos = ccpAdd(selSprite.position, translation);
        selSprite.position = newPos;
    } else {

    }
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch]; 
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    [self panForTranslation:translation];
}

- (void)selectSpriteForTouch:(CGPoint)touchLocation {
    CCSprite * newSprite = nil;
    for (CCSprite *sprite in movableThumbs) {
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
          
            newSprite = sprite;
            break;
        }
    }
    if (newSprite != selSprite) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"shakerpop.mp3"];
        CCRotateTo * rotLeft = [CCRotateBy actionWithDuration:0.1 angle:-4.0];
        CCRotateTo * rotCenter = [CCRotateBy actionWithDuration:0.1 angle:0.0];
        CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.1 angle:4.0];
        CCSequence * rotSeq = [CCSequence actions:rotLeft, rotCenter, rotRight, rotCenter, nil];
        [newSprite runAction:[CCRepeatForever actionWithAction:rotSeq]];
        selSprite = newSprite;
    }
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // NSLog(@"touch began in match");
    if (touchFlag == false) {
        CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
        [self selectSpriteForTouch:touchLocation];
        touchFlag = true;
    }
    return TRUE;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // NSLog(@"touch ended");
    touchFlag = false;
    [selSprite stopAllActions];
    [selSprite runAction:[CCRotateTo actionWithDuration:0.1 angle:0]];
    //trying to prevent babies from putting the pieces beyond the screen
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint outOfRange = ccp(winSize.width, winSize.height);
     for (CCSprite *movableThumb in movableThumbs) {
        if (movableThumb.position.x > outOfRange.x) {
            movableThumb.position = ccp(winSize.width, movableThumb.position.y);
        }
        if (movableThumb.position.y > outOfRange.y) {
            movableThumb.position = ccp(movableThumb.position.x, winSize.height);
        }
        if (movableThumb.position.x < 0) {
            movableThumb.position = ccp(0, movableThumb.position.y);
        }
        if (movableThumb.position.y < 0) {
            movableThumb.position = ccp(movableThumb.position.x, 0);
        }
     }
    //Do I need this with the update doing the checking?
     selSprite = nil;
    
}

- (void)update:(ccTime)dt {
  
    for (CCSprite *boundingBox in boundingBoxes) {
      
       
        for (CCSprite *movableThumb in movableThumbs) {
           
            if (CGRectIntersectsRect(movableThumb.boundingBox, boundingBox.boundingBox)) {
             
                [self stopScheduler];
                [selSprite runAction:[CCRotateTo actionWithDuration:0.1 angle:0]];
                selSprite = nil;
                movableThumbs = nil;
                
                [movableThumb runAction:[CCSequence actions:
                                    [CCMoveTo actionWithDuration:.25 position:ccp((boundingBox.position.x),(boundingBox.position.y))],
                                    [CCCallFuncN actionWithTarget:self
                                                         selector:@selector(spriteDone:)],
                                    nil]];
              
              
            }
           
        }


      
    }
   
}



- (void)stopScheduler {

     [self unschedule:@selector(update:)];

}


//When sprite is finished with animation, load in new game data
- (void) spriteDone:(id)sender{
    
    CCSprite *thumb  = sender;
    int thumbTag = (int)thumb.tag;
   
    if (thumbTag == 0){
        [thumb runAction:[CCScaleTo actionWithDuration:.5 scale:1]];
        //CCLOG (@"Correct Tag");
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        ps = [CCParticleFlower node];
        ps.position = ccp(winSize.width/2, winSize.height*.7);
        ps.scale = 2;
        ps.texture = [[CCTextureCache sharedTextureCache] addImage:@"stars.png"];
        [ps setLife:0.5f];
        [self addChild: ps];
        
        
        ///Add unlock and trophy to Level Data

        GameData *gameData = [GameDataParser loadData];
        int unlockedLevel = gameData.selectedLevel + 1;
        Levels *selectedLevels = [LevelParser loadLevelsForChapter:gameData.selectedChapter];
        for (Level *level in selectedLevels.levels) {
            
            if (unlockedLevel == level.number){

                level.unlocked = YES;
                CCLOG(@"Unlocking Level %i", level.number);
            }
            if (gameData.selectedLevel == level.number){
                
                level.stars = 1;
                CCLOG(@"Adding Trophy to level  %i", level.number);
            }
            
        }
        
        // store the selected level in GameData
        [LevelParser saveData:selectedLevels forChapter:gameData.selectedChapter];
    
        
        [_hud hideMidGameMenuAtEnd];
        [_hud showRestartMenu:YES];
        
        
        
    }else {
       // CCLOG (@"Wrong Tag");
        
        [_hud hideMidGameMenuAtEnd];
        [_hud showRestartMenu:NO];
        
        
    }
    
}

- (void) psDone {
    ps = [CCParticleFlower node];
    [ps stopSystem];
}




- (void)spawnBoundingBox {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    CCSprite *matchBox = [CCSprite spriteWithSpriteFrameName:@"largeBoundingBox.png"];

    matchBox.position = ccp(matchBox.contentSize.width/2 + matchMargin, winSize.height-(matchBox.contentSize.height/2) - matchMargin);
    matchBox.tag = 4;
    matchBox.opacity = 0;
    [boundingBoxes addObject:matchBox];
    [self addChild:matchBox];
    
}

- (void)spawnThumbs {
    
    GameData *gameData = [GameDataParser loadData];
    int selectedLevel = gameData.selectedLevel;    
    Levels *selectedLevels = [LevelParser loadLevelsForChapter:gameData.selectedChapter];
  
    for (Level *level in selectedLevels.levels) {
        
        if (selectedLevel == level.number) {
            
            //thumb image names provided by XML 
            //The first one is always the matching one
            
            thumbDataString = level.data;
           
            NSArray *thumbImageData = [thumbDataString componentsSeparatedByString:@","];
        
        
            //Create thumb sprites
            for(int i = 0; i < thumbImageData.count; ++i) {
                NSString *imageNumber = [thumbImageData objectAtIndex:i];
                NSString *image = [NSString stringWithFormat:@"%@matchThumb.png",imageNumber];
                CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:image];
                sprite.tag = i;
                [movableThumbs addObject:sprite];
            
            }

        }
        
    }
    
    
    //Shuffle thumb sprites
    NSUInteger count = [movableThumbs count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [movableThumbs exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    


    
    //Add to screen
    CGSize winSize = [CCDirector sharedDirector].winSize;
     for (CCSprite *sprite in movableThumbs) {
         
         NSUInteger i = [movableThumbs indexOfObject:sprite];
         float offsetFraction = ((float)(i+1))/(movableThumbs.count+1);
         int spriteX = (winSize.width - sprite.contentSize.width*.3);
         sprite.position = ccp(spriteX, winSize.height*offsetFraction);
         sprite.scale = .3;
         
         //[_spriteSheetMatching addChild:sprite];
         [self addChild:sprite];
        
        
    }
    
    

    
}



@end
