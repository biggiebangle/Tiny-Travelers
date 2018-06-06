//
//  HelloWorldLayer.mm
//  luggageGame
//
//  Created by Catherine Cavanagh on 8/27/13.
//  Copyright Catherine Cavanagh 2013. All rights reserved.
//

// Import the interfaces
#import "Luggage.h"
#import "sceneTag.h"
#import "LevelSelect.h"
#import "Level.h"
#import "Levels.h"
#import "LevelParser.h"
#import "GameData.h"
#import "GameDataParser.h"
#import "Background.h"
#import "SimpleAudioEngine.h"

#import "AppDelegate.h"






@implementation Luggage
@synthesize unlockedGame;



+(id) scene
{
	
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    scene.tag = kSceneLuggage;
	
	HUDLayer *hud = [HUDLayer node];
    [scene addChild:hud z:1];
    
    Luggage *layer = [[Luggage alloc] initWithHUD:hud];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)initWithHUD:(HUDLayer *)hud
{
	if( (self=[super init])) {
        
        
        _hud = hud;

        
#ifdef FREE
#else
        
        noiAdPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:@"com.biggiebangle.tinytravelersnyc.complete"];
        if (!noiAdPurchased) {
            mIAd = nil;
            mIAd = [[MyiAd alloc] init];
        }

#endif


        
        _background = [Background node];
        [self addChild:_background];
        [_background createCity];
        
        //Add unlock to Level Data and make sure we only have one level
        //Get the weather
        GameData *gameData = [GameDataParser loadData];
        temperature = gameData.temperature;
        weatherNumber = gameData.weatherNumber;
        gameData.selectedLevel = 1;
        [GameDataParser saveData:gameData];
      
        unlockedGame = YES;
        touchFlag = false;
        //CCLOG(@"Unlocking Game %i", unlockedGame);
        
        //Arrays for Collision Detection
        boundingBoxes = [[NSMutableArray alloc] init];
        movableThumbs = [[NSMutableArray alloc] init];
        circles = [[NSMutableArray alloc] init];
        
        // Create our sprite sheets and frame cache
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"luggageANIMATION16.plist"];
        _spriteSheetLuggageAnimation = [CCSpriteBatchNode batchNodeWithFile:@"luggageANIMATION16.pvr.ccz"];
        [self addChild:_spriteSheetLuggageAnimation];
        
        //This will change I'm sure.
        luggageAnimFrames = [NSMutableArray array];
        for (int i=2; i<=5; i++) {
            [luggageAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"animation-luggage-%d.png",i]]];
        }
        
        _spriteSheetLuggage = [CCSpriteBatchNode batchNodeWithFile:@"luggageITEMS13.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"luggageITEMS13.plist"];
        [self addChild:_spriteSheetLuggage];
        
   
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"HUDSPRITES12.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"HUDSPRITES12.plist"];
        [self addChild:_spriteSheet];
        
        //Spawn empty luggage background
        NSString *luggageBackground =  [NSString stringWithFormat:@"animation-luggage-0.png"];
        luggageBg = [CCSprite spriteWithSpriteFrameName:luggageBackground];
        

        //Consistent margin for game and device
        double myDouble = luggageBg.contentSize.height*.03125;
        luggageMargin = (int)myDouble;
        // CCLOG(@"luggage margin: %i ",  luggageMargin);
        
        
        //color for selected sprite highlighting
         oldColor = luggageBg.color;
       
        CGSize winSize = [CCDirector sharedDirector].winSize;
#ifdef FREE
        luggageBg.position = ccp(winSize.width/2, luggageMargin + luggageBg.contentSize.height/2);
  
#else
        luggageBg.position = ccp(winSize.width/2, luggageMargin*4.5 + luggageBg.contentSize.height/2);
#endif

        luggageBg.opacity = 0;
        [luggageBg setScale:.02];
        [_spriteSheetLuggageAnimation addChild:luggageBg];
                
        id scaleAction = [CCScaleTo actionWithDuration:1.5 scale:1];
        id easeAction = [CCEaseBounceOut actionWithAction:scaleAction];
        id fadeAction = [CCFadeIn actionWithDuration:.8];
        
        [luggageBg runAction:fadeAction];
        [luggageBg runAction:easeAction];
        
           
        [self spawnBoundingBox];
        
        [self spawnCircles];
        
        checkMarkParticles = NO;
           
        [self spawnLuggageThumbs];

        
        [_hud spawnMidGameMenu];
          
        [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        

	}
	return self;
}

- (void)onExitTransitionDidStart{

    [[[CCDirector sharedDirector]touchDispatcher] removeDelegate:self];
  
    
}


-(void)onExit
{

   
    

#ifdef FREE
    

#else
    if(mIAd)
    {
        [mIAd RemoveiAd ];
        
        mIAd = nil;
    }
#endif
    [self removeAllChildrenWithCleanup:YES];
    [super onExit];
    

}




//Touches

- (void)selectSpriteForTouch:(CGPoint)touchLocation {
    
    if (unlockedGame == YES){
      
        CCSprite * newSprite = nil;
        for (CCSprite *sprite in movableThumbs) {
            if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
                //Let's make sure it's not sitting in the luggage!
                for (CCSprite *boundingBox in boundingBoxes) {
                    if (! CGRectIntersectsRect(sprite.boundingBox, boundingBox.boundingBox)) {
                        newSprite = sprite;
                      
                        //Shouldn't this be determined from the original position, and not the picked up position
                        selSpriteOriginalPosition = newSprite.position;
                        break;
                    }
                    
                }
                
            }
            
        }
        if (newSprite != selSprite) {
        
            CCTintTo *tintTo = [CCTintTo actionWithDuration:.2 red:200 green:200 blue:200];
            CCTintTo *tintBack = [CCTintTo actionWithDuration:.2 red:oldColor.r green:oldColor.g blue:oldColor.b];
            [selSprite runAction:[CCSequence actions: tintBack, nil]];
            [newSprite runAction:[CCSequence actions: tintTo, nil]];
            selSprite = newSprite;
            
        }
    }
}

- (void)panForTranslation:(CGPoint)translation {
   
     if (unlockedGame == YES){
        if (selSprite) {
         
            CGPoint newPos = ccpAdd(selSprite.position, translation);
            selSprite.position = newPos;
          
            
        } else {

        }
    }
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    //NSLog(@"began in luggage");

    if (touchFlag == false) {
     
        checkMarkParticles = NO;
        CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
       // selSprite = nil;
        [self selectSpriteForTouch:touchLocation];
        
        touchFlag = true;
        
    }
   return TRUE;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
  
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    [self panForTranslation:translation];
    
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

    if (unlockedGame == YES){

        CCTintTo *tintBackTouchEnd = [CCTintTo actionWithDuration:.2 red:oldColor.r green:oldColor.g blue:oldColor.b];
        [selSprite runAction:[CCSequence actions: tintBackTouchEnd, nil]];
        [self matchCheck];
        
    }
    
    touchFlag = false;
    selSprite = nil;
    
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

}

//Game Logic
- (void)matchCheck {

    matches = [[NSMutableArray alloc] init];
   
    for (CCSprite *movableThumb in movableThumbs) {
        
        for (CCSprite *boundingBox in boundingBoxes) {
            
            if (CGRectIntersectsRect(movableThumb.boundingBox, boundingBox.boundingBox)) {
                

                int thumbTag = (int)movableThumb.tag;
                int boundingBoxTag = (int)boundingBox.tag;
                    if (thumbTag == boundingBoxTag){
                       
                            //CCLOG(@"MATCH: %i and %i",  boundingBoxTag, thumbTag);
                            [matches addObject:[NSNumber numberWithInt:1]];
                        
                         if (movableThumb == selSprite && !(movableThumb.opacity == 0)){
                            [movableThumb runAction: [CCMoveTo actionWithDuration:.25 position:ccp((boundingBox.position.x),(boundingBox.position.y))]];
                            [movableThumb runAction:[CCCallFuncN actionWithTarget:self selector:@selector(selectLuggageImage:)]];
                             checkMarkParticles = YES;
                             id FadeOutAction = [CCFadeOut actionWithDuration:.25];
                             [movableThumb runAction:FadeOutAction];

                          //If we find something in there that is not the selected sprite and hasn't already been included in the count
                         
                        if(movableThumb != selSprite && !(movableThumb.opacity == 0)){
                              [movableThumb runAction: [CCMoveTo actionWithDuration:.25 position:ccp((selSpriteOriginalPosition.x),(selSpriteOriginalPosition.y))]];
                             }
                             
                        }
                        
                    }else {
                        if (movableThumb == selSprite){
                            //CCLOG(@"Selected sprites are boundingBox %i and thumb %i",  boundingBoxTag, thumbTag);
                            [self matchGame:NO];
                            
                            [movableThumb runAction: [CCMoveTo actionWithDuration:.25 position:ccp((boundingBox.position.x),(boundingBox.position.y))]];
                            [movableThumb runAction:[CCSequence actions:[CCFadeTo actionWithDuration:.25 opacity:0],[CCCallFuncN actionWithTarget:self selector:@selector(selectLuggageImage:)],[CCDelayTime actionWithDuration:3.5], [CCMoveTo actionWithDuration:.5 position:ccp((selSpriteOriginalPosition.x),(selSpriteOriginalPosition.y))],[CCFadeIn actionWithDuration:.5], nil]];
                            }
                        
                        if(movableThumb != selSprite){
                            [movableThumb runAction: [CCMoveTo actionWithDuration:.25 position:ccp((selSpriteOriginalPosition.x),(selSpriteOriginalPosition.y))]];
                        }
                    }
                
               
            } else {
                
                if (movableThumb == selSprite) {
                    //CCLOG(@"move me back");
                    [movableThumb runAction: [CCMoveTo actionWithDuration:.25 position:ccp((selSpriteOriginalPosition.x),(selSpriteOriginalPosition.y))]];
                }
                
            }
            
        }//boundingBox for
        
        
    }//movableThumbs for
    
    
    //Add a check mark each time there is a new correct object in the luggage
    if (checkMarkParticles == YES) {
        int totalMatches = (int)matches.count;
        [self spawnCheckMark:totalMatches];

    }
}//Match Check

//GAME OVER
- (void)matchGame:(BOOL)won {
  
    if (won == YES){
       // CCLOG (@"All the right items!");
        CGSize winSize = [CCDirector sharedDirector].winSize;
        checkEmitter = [CCParticleExplosion node];
        checkEmitter.position = ccp((winSize.width/2),(winSize.height/2));
        checkEmitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];

        [checkEmitter setLife:.2f];
        [self addChild: checkEmitter];
        
        [_hud showLuggageRestartMenu:YES];
        movableThumbs = nil;
        [_hud hideMidGameMenuAtEnd];

        

        
    }else {
       
        unlockedGame = NO;
        [_hud showLuggageRestartMenu:NO];
        [checkEmitter stopSystem];
        
    }
    
}
- (void) selectLuggageImage:(id)sender{
    //CCLOG(@"select luggage image");
    CCSprite *thumb  = sender;
    int thumbTag = (int)thumb.tag;
    if (thumbTag == 1) {
        //CCLOG(@"thumbtag %i", thumbTag);
        //Play a sound??
        NSString *luggageBackground =  [NSString stringWithFormat:@"animation-luggage-1.png"];
        [luggageBg setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:luggageBackground]];
    }else {
        //CCLOG(@"thumbtag %i", thumbTag);
        //Play a sound??
        NSString *luggageBackground =  [NSString stringWithFormat:@"bad-luggage-%i.png", thumbTag];
        [luggageBg setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:luggageBackground]];
    }
    
    if (matches.count == 0) {
        //CCLOG(@"Match Count is zero");
        [luggageBg stopAllActions];
        [luggageBg runAction:[CCSequence actions:[CCDelayTime actionWithDuration:4],[CCCallFuncN actionWithTarget:self selector:@selector(zeroLuggageImageUnlockGame:)], nil]];
    }
    
    if (matches.count >= 1 && matches.count < 5) {
        [luggageBg stopAllActions];
        //CCLOG(@"Match Count is between one and four");
        [luggageBg runAction:[CCSequence actions:[CCDelayTime actionWithDuration:4],[CCCallFuncN actionWithTarget:self selector:@selector(returnLuggageImageUnlockGame:)], nil]];
    }
    
    if (matches.count == 5) {
    [luggageBg stopAllActions];
        
       // CCLOG(@"YOU WON");
        
        //Fade out the bad ones
        for (CCSprite *movableThumb in movableThumbs) {
            if (!(movableThumb.opacity == 0) && movableThumb.tag != 1){
                id FadeOutAction = [CCFadeOut actionWithDuration:.5];
                
                [movableThumb runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.5], FadeOutAction, nil]];
                

            }
        }
        
        //Close the luggage
        CCAnimation *luggageAnim = [CCAnimation
                                    animationWithSpriteFrames:luggageAnimFrames delay:0.5f];
        CCAnimate *luggageAnimate = [CCAnimate actionWithAnimation:luggageAnim];
        [luggageBg runAction:luggageAnimate];
        
        [self matchGame:YES];
        
        
    }
}

- (void) zeroLuggageImageUnlockGame:(id)sender{
        //CCLOG(@"zero called");
        [luggageBg setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"animation-luggage-0.png"]];
        unlockedGame = YES;
        //CCLOG(@"Unlocking Game %i", unlockedGame);
}

- (void) returnLuggageImageUnlockGame:(id)sender{
        //CCLOG(@"one and four called");
        [luggageBg setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"animation-luggage-1.png"]];
        unlockedGame = YES;
        //CCLOG(@"Unlocking Game %i", unlockedGame);
}


// Create objects!

- (void)spawnCheckMark:(int)totalMatches {
    
    for (CCSprite *circle in circles) {
        int circleTag = (int)circle.tag;
        if (circleTag == totalMatches) {
            CCSprite *check = [CCSprite spriteWithSpriteFrameName:@"check.png"];
            check.position = ccp((circle.position.x),(circle.position.y));
            
            checkEmitter = [CCParticleExplosion node];
            checkEmitter.position = ccp((circle.position.x),(circle.position.y));
            checkEmitter.scale = 2;
            checkEmitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
            
            //set length of particle animation
            [checkEmitter setLife:.8f];
            [self addChild: checkEmitter];
            [_spriteSheetLuggage addChild:check];
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"correct.mp3"];
            
        }
    }
}

- (void)spawnCircles {
   CGSize winSize = [CCDirector sharedDirector].winSize;
    for (int i=1; i < 6; i++) {
        CCSprite *circle = [CCSprite spriteWithSpriteFrameName:@"circle.png"];
        circle.tag = i;
        [circles addObject:circle];
#ifdef FREE
        int circlePositionY = winSize.height - circle.contentSize.height/2 - luggageMargin;
#else
       int circlePositionY = circle.contentSize.height/2 + luggageMargin;
#endif
        
        int circlePositionX = winSize.width/2 - circle.contentSize.width*3 + circle.contentSize.width*i;
        circle.position = ccp(circlePositionX, circlePositionY);
        [_spriteSheetLuggage addChild:circle];
        
    }
    
}

- (void)spawnBoundingBox {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    //Create boundingBox sprite
    CCSprite *matchBox = [CCSprite spriteWithSpriteFrameName:@"boundingBox.gif"];
    [matchBox setTag:1];
    [boundingBoxes addObject:matchBox];
    matchBox.opacity = 0;
    int bgPositionY = luggageBg.position.y;
    matchBox.position = ccp(winSize.width/2, bgPositionY);           
    [_spriteSheetLuggage addChild:matchBox];
               
}

- (void)spawnLuggageThumbs {
    GameData *gameData = [GameDataParser loadData];
    //int selectedLevel = gameData.selectedLevel;
    Levels *selectedLevels = [LevelParser loadLevelsForChapter:gameData.selectedChapter];
  
    for (Level *level in selectedLevels.levels) {
        
        if (level.number == 1) {
            
            //thumb image names provided by XML 
            
            thumbDataString = level.data;
           
            thumbXMLData = [thumbDataString componentsSeparatedByString:@","];
           
        }
    }
    
    //Add items for weather

    NSMutableArray *thumbXMLDataAndWeatherData = [[NSMutableArray alloc] init];
    [thumbXMLDataAndWeatherData addObjectsFromArray:thumbXMLData];
#ifdef FREE
    if (temperature < 40) {
        //CCLOG(@"add mittens");
        [thumbXMLDataAndWeatherData addObject:@"mittens-1"];
    }
    if (weatherNumber > 799 && weatherNumber < 804) {
        //CCLOG(@"Add sunglasses");
        [thumbXMLDataAndWeatherData addObject:@"sunglasses-1"];
    }
    if (weatherNumber > 199 && weatherNumber < 599){
        // CCLOG(@"Add umbrella");
        [thumbXMLDataAndWeatherData addObject:@"umbrella-1"];
    }
#else
    
    BOOL allPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:@"com.biggiebangle.tinytravelersnyc.complete"];
    if (allPurchased) {
        
   
        if (temperature < 40) {
            //CCLOG(@"add mittens");
            [thumbXMLDataAndWeatherData addObject:@"mittens-1"];
        }
        if (weatherNumber > 799 && weatherNumber < 804) {
            //CCLOG(@"Add sunglasses");
            [thumbXMLDataAndWeatherData addObject:@"sunglasses-1"];
        }
        if (weatherNumber > 199 && weatherNumber < 599){
           // CCLOG(@"Add umbrella");
            [thumbXMLDataAndWeatherData addObject:@"umbrella-1"];
        }
    }
#endif
    NSMutableArray *badThumbs = [[NSMutableArray alloc] init];
    NSMutableArray *goodThumbs = [[NSMutableArray alloc] init];
    
        

    //Create thumb sprites

    int badTag = 2;
    for(int i = 0; i < thumbXMLDataAndWeatherData.count; ++i) {
        NSString *imageName = [thumbXMLDataAndWeatherData objectAtIndex:i];
        NSString *image = [NSString stringWithFormat:@"%@.png",imageName];
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:image];
        
        //tag based on the image name final character
        NSString *tagCode = [imageName substringFromIndex: [imageName length] - 1];
        //assign the sprite a tag and add it to the correct category aka array
        if ([tagCode intValue] == 1){
            sprite.tag = 1;
            [goodThumbs addObject:sprite];
            
        }else{
            sprite.tag = badTag;
            [badThumbs addObject:sprite];
            ++badTag;
            
        };
        
    };
  
    
    
    //Shuffle bad and good thumb sprites
    NSUInteger badCount = [badThumbs count];
    for (NSUInteger i = 0; i < badCount; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = badCount - i;
        NSInteger n = (arc4random() % nElements) + i;
        [badThumbs exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    NSUInteger goodCount = [goodThumbs count];
    for (NSUInteger i = 0; i < goodCount; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = goodCount - i;
        NSInteger n = (arc4random() % nElements) + i;
        [goodThumbs exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    //Add a few of the sprites to what will be on the screen
    NSArray *tempArray = [goodThumbs subarrayWithRange:NSMakeRange(0, 5)];
    [movableThumbs addObjectsFromArray:tempArray];
   
    
    tempArray = [badThumbs subarrayWithRange:NSMakeRange(0, 3)];
    [movableThumbs addObjectsFromArray:tempArray];
     
    tempArray = nil;
    
    //Shuffle objects before putting it on the screen
    NSUInteger totalCount = [movableThumbs count];
    for (NSUInteger i = 0; i < totalCount; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = totalCount - i;
        NSInteger n = (arc4random() % nElements) + i;
        [movableThumbs exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    CGSize winSize = [CCDirector sharedDirector].winSize;
    NSArray *yCoordinateArray;
#ifdef FREE
    yCoordinateArray = [NSArray arrayWithObjects:
                        [NSNumber numberWithInt:winSize.height*.3],
                        [NSNumber numberWithInt:winSize.height*.6],
                        [NSNumber numberWithInt:(winSize.height-luggageMargin*7)],
                        [NSNumber numberWithInt:(winSize.height-luggageMargin*13)],
                        [NSNumber numberWithInt:(winSize.height-luggageMargin*13)],
                        [NSNumber numberWithInt:(winSize.height-luggageMargin*7)],
                        [NSNumber numberWithInt:(winSize.height*.6)],
                        [NSNumber numberWithInt:(winSize.height*.3)], nil];

    
#else

    if (!noiAdPurchased) {
        
        
        yCoordinateArray = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:winSize.height*.3],
                            [NSNumber numberWithInt:winSize.height*.55],
                            [NSNumber numberWithInt:(winSize.height-luggageMargin*12)],
                            [NSNumber numberWithInt:(winSize.height-luggageMargin*13)],
                            [NSNumber numberWithInt:(winSize.height-luggageMargin*13)],
                            [NSNumber numberWithInt:(winSize.height-luggageMargin*12)],
                            [NSNumber numberWithInt:(winSize.height*.55)],
                            [NSNumber numberWithInt:(winSize.height*.3)], nil];
    }else {
        yCoordinateArray = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:winSize.height*.3],
                            [NSNumber numberWithInt:winSize.height*.6],
                            [NSNumber numberWithInt:(winSize.height-luggageMargin*7)],
                            [NSNumber numberWithInt:(winSize.height-luggageMargin*13)],
                            [NSNumber numberWithInt:(winSize.height-luggageMargin*13)],
                            [NSNumber numberWithInt:(winSize.height-luggageMargin*7)],
                            [NSNumber numberWithInt:(winSize.height*.6)],
                            [NSNumber numberWithInt:(winSize.height*.3)], nil];
    }
    
#endif

    
    
    NSNumber *xCoord4;
    NSNumber *xCoord5;
#ifdef FREE
    xCoord4 = [NSNumber numberWithInt:winSize.width*.4];
    xCoord5 = [NSNumber numberWithInt:winSize.width*.6];
#else

    if (!noiAdPurchased) {
        xCoord4 = [NSNumber numberWithInt:winSize.width*.3];
        xCoord5 = [NSNumber numberWithInt:winSize.width*.7];
    }else {
        xCoord4 = [NSNumber numberWithInt:winSize.width*.4];
        xCoord5 = [NSNumber numberWithInt:winSize.width*.6];
    }
#endif


    NSArray *xCoordinateArray = [NSArray arrayWithObjects:
                                 [NSNumber numberWithInt:luggageMargin*8],
                                 [NSNumber numberWithInt:luggageMargin*8],
                                 [NSNumber numberWithInt:luggageMargin*8],
                                 xCoord4,
                                 xCoord5,
                                 [NSNumber numberWithInt:(winSize.width-luggageMargin*8)],
                                 [NSNumber numberWithInt:(winSize.width-luggageMargin*8)],
                                 [NSNumber numberWithInt:(winSize.width-luggageMargin*8)], nil];
    
    NSArray *actionWithDurationArray = [NSArray arrayWithObjects:
                                        [NSNumber numberWithInt:1.6],[NSNumber numberWithInt:1],[NSNumber numberWithInt:1.1],[NSNumber numberWithInt:1.5],[NSNumber numberWithInt:1],[NSNumber numberWithInt:1.1],[NSNumber numberWithInt:1.2],[NSNumber numberWithInt:1.1], nil];
    
   /* NSArray *actionWithDurationArray = [NSArray arrayWithObjects:
                                        [NSNumber numberWithInt:1.6],[NSNumber numberWithInt:1],[NSNumber numberWithDouble:1.1],[NSNumber numberWithDouble:1.5],[NSNumber numberWithInt:1],[NSNumber numberWithDouble:1.1],[NSNumber numberWithDouble:1.2],[NSNumber numberWithDouble:1.1], nil];*/
    
    
    
    //Add to screen
     for (CCSprite *sprite in movableThumbs) {
         NSUInteger i = [movableThumbs indexOfObject:sprite];
       
         sprite.position = ccp(winSize.width/2, winSize.height/2);
         sprite.opacity = 0;
         
         [_spriteSheetLuggage addChild:sprite];         
         int spriteX = [xCoordinateArray[i] intValue];
         int spriteY = [yCoordinateArray[i] intValue];        
         id actionTo = [CCMoveTo actionWithDuration: [actionWithDurationArray[i] intValue] position:ccp(spriteX, spriteY)];
         id fadeIn = [CCFadeIn actionWithDuration:.8];
         [sprite runAction:actionTo];
         [sprite runAction:fadeIn];
     
        
        
    }

    
}

@end
