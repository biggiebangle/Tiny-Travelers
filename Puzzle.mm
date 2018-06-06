//
//  Puzzle.mm
//  Puzzle
//
//  Created by Catherine Cavanagh on 8/27/13.
//  Copyright Catherine Cavanagh 2013. All rights reserved.
//

// Import the interfaces
#import "Puzzle.h"
#import "sceneTag.h"
#import "SimpleAudioEngine.h"
#import "LevelSelect.h"
#import "Level.h"
#import "Levels.h"
#import "LevelParser.h"
#import "GameData.h"
#import "GameDataParser.h"



@implementation Puzzle

+(id) scene
{
	
	CCScene *scene = [CCScene node];
    scene.tag = kScenePuzzle;
	
	HUDLayer *hud = [HUDLayer node];
    [scene addChild:hud z:1];
    
    Puzzle *layer = [[Puzzle alloc] initWithHUD:hud];
		
	[scene addChild: layer];
	
	return scene;
}

- (id)initWithHUD:(HUDLayer *)hud
{
	if( (self=[super init])) {
    
        _hud = hud;
        
        //Arrays for Collision Detection
        boundingBoxes = [[NSMutableArray alloc] init];
        movableThumbs = [[NSMutableArray alloc] init];
       //unUsedThumbs = [[NSMutableArray alloc] init];
        
        //trying to prevent multitouch
        touchFlag = false;
        
        // Create our sprite sheet and frame cache      
        _spriteSheetPuzzle = [CCSpriteBatchNode batchNodeWithFile:@"BOXPuzzle15.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"BOXPuzzle15.plist"];
        [self addChild:_spriteSheetPuzzle];
        
        _spriteSheetPuzzle2 = [CCSpriteBatchNode batchNodeWithFile:@"PIECESpuzzle15.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PIECESpuzzle15.plist"];
        [self addChild:_spriteSheetPuzzle2];

        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"HUDSPRITES12.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"HUDSPRITES12.plist"];
        [self addChild:_spriteSheet];
        
        GameData *gameData = [GameDataParser loadData];
        selectedLevel = gameData.selectedLevel;
        Levels *selectedLevels = [LevelParser loadLevelsForChapter:gameData.selectedChapter];
        
        for (Level *level in selectedLevels.levels) {
            
            if (selectedLevel == level.number) {

                thumbDataString = level.data;
           
            
                   thumbXMLData = [thumbDataString componentsSeparatedByString:@","];

            }
            
        }

        NSString *puzzleBackground = [NSString stringWithFormat:@"%dlevelPuzzleBg.png", selectedLevel];
        
        //Create Large Image       
        puzzleBg = [CCSprite spriteWithSpriteFrameName:puzzleBackground];
        
        //Consistent margin for game and device
        double myDouble = puzzleBg.contentSize.height*.0625;
        puzzleMargin = (int)myDouble;
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        puzzleBg.position = ccp(puzzleBg.contentSize.width/2 + puzzleMargin, winSize.height-(puzzleBg.contentSize.height/2) - puzzleMargin);
        [_spriteSheetPuzzle addChild:puzzleBg];
        
        
        //color for selected sprite highlighting
        oldColor = puzzleBg.color;
        
        _background = [Background node];
        [self addChild:_background z:-5];
        [_background createCity];
       
        
        [_hud spawnMidGameMenu];
           
        [self spawnBoundingBox];
           
        [self spawnPuzzleThumbs];
          
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
            [[SimpleAudioEngine sharedEngine] playEffect:@"shakerpop.mp3"];
            newSprite = sprite;
            //NSUInteger i = [movableThumbs indexOfObject:sprite];
           //can you change the z without changing the index?
           
           //CCLOG(@"BEFORE: Z of currently selected sprite %li and index %lu", (long)sprite.zOrder, (unsigned long)i);

            break;
            
        }
    }
    if (newSprite != selSprite) {
        
    [selSprite stopAllActions];
        

       CCTintTo *tintTo = [CCTintTo actionWithDuration:.2 red:200 green:200 blue:200];
       
       [newSprite runAction:[CCSequence actions: tintTo, nil]];
        
        selSprite = newSprite;
    
    }
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if(touchFlag == false){
  
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self selectSpriteForTouch:touchLocation];
        touchFlag = true;
    }
    return TRUE;
    
}



-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CCTintTo *tintBackTouchEnd = [CCTintTo actionWithDuration:.2 red:oldColor.r green:oldColor.g blue:oldColor.b];
    [selSprite runAction:[CCSequence actions: tintBackTouchEnd, nil]];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    if (movableThumbs != nil){
        //what is this??
        if (selSprite.position.x < (winSize.width - selSprite.contentSize.width - puzzleMargin)){
          
            [self matchCheck];
            //CCLOG(@"match check!");
 
       }
        
        //selSprite = nil;
    }
    
  
    //trying to prevent babies from putting the pieces beyond the screen
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
    
    touchFlag = false;
 
}


- (void)matchCheck {
    [selSprite stopAllActions];
    //[selSprite runAction:[CCRotateTo actionWithDuration:0.1 angle:0]];
    CCTintTo *tintBackTouchEnd = [CCTintTo actionWithDuration:.2 red:oldColor.r green:oldColor.g blue:oldColor.b];
    [selSprite runAction:[CCSequence actions: tintBackTouchEnd, nil]];
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    NSMutableArray *boxTags = [[NSMutableArray alloc] init];
    for (CCSprite *movableThumb in movableThumbs) {
        
        NSMutableArray *boundingBoxCollection = [[NSMutableArray alloc] init];
        
        for (CCSprite *boundingBox in boundingBoxes) {
          
            if (CGRectIntersectsRect(movableThumb.boundingBox, boundingBox.boundingBox)) {
                [movableThumb runAction:[CCScaleTo actionWithDuration:.25 scale:1]];
                int thumbTag = (int)movableThumb.tag;
                int boundingBoxTag = (int)boundingBox.tag;
                    if (thumbTag == boundingBoxTag){
                       
                       // CCLOG(@"MATCH: %i and %i",  boundingBoxTag, thumbTag);
                        [boundingBoxCollection addObject:boundingBox];
                     
                        
                    }
                    else {
                        
                       // CCLOG(@"Selected sprites are boundingBox %i and thumb %i",  boundingBoxTag, thumbTag);
                        [boundingBoxCollection addObject:boundingBox];
                    
                    }
                
                selSprite = nil;
                        
            }
     
        }
        
       // CCLOG(@"Collection: boundingBox %i and thumb %i",  boundingBoxCollection.count, movableThumb.tag);
        if (boundingBoxCollection.count == 1) {
             
          for (CCSprite *box in boundingBoxCollection) {
              if (movableThumb.tag == box.tag) {
                  //CCLOG(@"MATCH: %i and %i",  box.tag, movableThumb.tag);
                  [matches addObject:[NSNumber numberWithInt:1]];
                  [movableThumb runAction:[CCMoveTo actionWithDuration:.25 position:ccp((box.position.x),(box.position.y))]];
              }
              else {
                  [matches addObject:[NSNumber numberWithInt:0]];
              }
              
             //CCLOG(@"MOVEME: thumb %i",  movableThumb.tag);
             // CCLOG(@"Here's my tag %i",  box.tag);
              
              
              
           
            [boxTags addObject:[NSNumber numberWithInt:(int)box.tag]];
           }
          
           
        }
 
      
    }
    
    //Lets make sure that each box tag is in the match arrray, if not, the game isn't over!
    NSSet *boxTagset = [NSSet setWithArray:boxTags];
    // CCLOG(@"what are my box tags? %@",  boxTagset);
   
    //CCLOG(@"how many matches? %i",  matches.count);
    if (matches.count == thumbXMLData.count && boxTagset.count == thumbXMLData.count) {
             
        if (![matches containsObject:[NSNumber numberWithInt:0]]) {
           // CCLOG(@"YOU WON");
            [self matchGame:YES];
            
            
        }
        else{
            [self matchGame:NO];
        }
        
    }
    
   }


- (void)matchGame:(BOOL)won {
    movableThumbs = nil;
   
    if (won == YES){
      
        
        ///Add unlock and trophy to Level Data

        GameData *gameData = [GameDataParser loadData];
        int unlockedLevel = selectedLevel + 1;
        Levels *selectedLevels = [LevelParser loadLevelsForChapter:gameData.selectedChapter];
        
        for (Level *level in selectedLevels.levels) {
            
            if (unlockedLevel == level.number){

                level.unlocked = YES;
                //CCLOG(@"Unlocking Level %i", level.number);
            }
            if (selectedLevel == level.number){
                
                level.stars = 1;
                //CCLOG(@"Adding Trophy level %i", level.number);
            }
        }
        
        // store the selected level in GameData
        [LevelParser saveData:selectedLevels forChapter:gameData.selectedChapter];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        ps = [CCParticleFlower node];
        ps.position = ccp(winSize.width/2, winSize.height*.5);
        ps.scale = 2;
        ps.texture = [[CCTextureCache sharedTextureCache] addImage:@"stars.png"];
        [ps setLife:0.5f];
        [self addChild: ps z:10];
    
        [_hud hideMidGameMenuAtEnd];
        [_hud showRestartMenu:YES];
        
        
        
        
    }else {
        //CCLOG (@"Wrong Tag");

        
        [_hud hideMidGameMenuAtEnd];
        [_hud showRestartMenu:NO];
    
        
        
    }
    
}




- (void)spawnBoundingBox {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    
    
    //The name needs to reflect the correct number of bounding boxes
    
   for(int i = 0; i < thumbXMLData.count; ++i) {
       
        NSString *puzzleBoundBox = [NSString stringWithFormat:@"puzzleBoundingBox%lu.png",(unsigned long)thumbXMLData.count];
        CCSprite *matchBox = [CCSprite spriteWithSpriteFrameName:puzzleBoundBox];
        //CCSprite *matchBox = [CCSprite spriteWithSpriteFrameName:@"puzzleBoundingBox.png"];
        [matchBox setTag:i]; 
        [boundingBoxes addObject:matchBox];
       matchBox.opacity = 1;
        
    }
    
    int nearBorder = puzzleMargin*2;
    int twoBorders = puzzleMargin*3;
    int threeBorders = puzzleMargin*4;

    for (CCSprite *bb in boundingBoxes) {
        int spriteX = nil;
        int spriteY = nil;
        NSUInteger i = [boundingBoxes indexOfObject:bb];
        if (thumbXMLData.count == 4){
            if (i % 2)
                {
                   // CCLOG(@"Selected sprite is number %i",  sprite.tag);
                    spriteX = twoBorders + bb.contentSize.width + bb.contentSize.width/2;
                }
            
                // odd
            else
                {
                 
                     // CCLOG(@"Selected sprite is number %i",  sprite.tag);
                     spriteX = nearBorder + bb.contentSize.width/2;
                }
                // even
            if (i < 2)
                
                {
                   // CCLOG (@"One or Two");
                   // CCLOG(@"Selected sprite is number %i",  sprite.tag);
                    spriteY = winSize.height - nearBorder - bb.contentSize.height/2;
                }
           else
                {
                   // CCLOG (@"Three or Four");
                     // CCLOG(@"Selected sprite is number %i",  sprite.tag);
                    spriteY =  winSize.height - twoBorders  - bb.contentSize.height - bb.contentSize.height/2;
                }
        }else if (thumbXMLData.count == 9){
            if (i == 0 || i == 3 || i == 6)
            {
                // CCLOG(@"Selected sprite is number %i",  sprite.tag);
              
                   spriteX = nearBorder + bb.contentSize.width/2;
            }

            else if(i == 1 || i == 4 || i == 7 )
            {
                spriteX = twoBorders + bb.contentSize.width + bb.contentSize.width/2;
                // CCLOG(@"Selected sprite is number %i",  sprite.tag);
             
            }else if(i == 2 || i == 5 || i == 8 )
            {
                
                // CCLOG(@"Selected sprite is number %i",  sprite.tag);
               spriteX = threeBorders + bb.contentSize.width*2 + bb.contentSize.width/2;
            }
            if (i < 3)
                
            {
                // CCLOG (@"One or Two");
                // CCLOG(@"Selected sprite is number %i",  sprite.tag);
                spriteY = winSize.height - nearBorder - bb.contentSize.height/2;
            }
            else if (i > 2 && i < 6)
            {
                // CCLOG (@"Three or Four");
                // CCLOG(@"Selected sprite is number %i",  sprite.tag);
                spriteY =  winSize.height - twoBorders  - bb.contentSize.height - bb.contentSize.height/2;
            }else if (i > 5){
                spriteY =  winSize.height - threeBorders - bb.contentSize.height*2 - bb.contentSize.height/2;
            }
            
       }

        bb.position = ccp(spriteX, spriteY);
        
        [self addChild:bb];
        //[_spriteSheetPuzzle2 addChild:bb];
    }
        
  
    
}

- (void)spawnPuzzleThumbs {
    


    //Create thumb sprites
    for(int i = 0; i < thumbXMLData.count; ++i) {
        NSString *imageNumber = [thumbXMLData objectAtIndex:i];
        NSString *image = [NSString stringWithFormat:@"%dlevel%@.png",selectedLevel,imageNumber];
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:image];
        sprite.tag = i;
        [movableThumbs addObject:sprite];
        //[unUsedThumbs addObject:sprite];
        
    }
     NSUInteger total = [movableThumbs count];
    
    //Shuffle thumb sprites
    for (NSUInteger i = 0; i < total; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = total - i;
        NSInteger n = (arc4random() % nElements) + i;
        [movableThumbs exchangeObjectAtIndex:i withObjectAtIndex:n];
        //[unUsedThumbs exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    //Add to screen
    CGSize winSize = [CCDirector sharedDirector].winSize;
     for (CCSprite *sprite in movableThumbs) {
         NSUInteger i = [movableThumbs indexOfObject:sprite];
         sprite.scale = .6;
         int spriteX;
         int spriteY;
         if (i <5){
             spriteX = (winSize.width - sprite.contentSize.width/2 - puzzleMargin*2);
             spriteY = winSize.height - puzzleMargin - sprite.contentSize.height/3  - (sprite.contentSize.height/2*i + puzzleMargin*i);
         }else {
             spriteX = (winSize.width - sprite.contentSize.width/2  - sprite.contentSize.width - puzzleMargin*2);
             spriteY = winSize.height - puzzleMargin - sprite.contentSize.height/3  - (sprite.contentSize.height/2*(i-5) + puzzleMargin*(i-5));
           
         }
         sprite.position = ccp(spriteX, spriteY);
         
         [_spriteSheetPuzzle2 addChild:sprite z:total-i];
         
    }
    
}

@end
