//
//  HUDLayer.mm
//  matchingGame
//
//  Created by Catherine Cavanagh on 9/1/13.
//  Copyright (c) 2013 Catherine Cavanagh. All rights reserved.
//

#import "HUDLayer.h"
#import "Puzzle.h"
#import "MatchingGame.h"
#import "Cityscape.h"
//#import "MainMenu.h"
#import "NOscrollMainMenu.h"
#import "Luggage.h"
#import "Scene00.h"
#import "Store.h"
#import "SimpleAudioEngine.h"
#import "sceneTag.h"
#import "Level.h"
#import "Levels.h"
#import "LevelParser.h"
#import "LevelSelect.h"
#import "GameData.h"
#import "GameDataParser.h"

@implementation HUDLayer

- (id)init {
    
    if( (self=[super init])) {

        winSize = [CCDirector sharedDirector].winSize;
        
    }
    return self;
}

#pragma mark -
#pragma mark Buttons

- (void)musicTapped:(id)sender {
    
    GameData *gameData = [GameDataParser loadData];
    
    CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
    if (toggleItem.selectedItem == _musicOff) {
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        [gameData setMusic:0];
        
    } else if (toggleItem.selectedItem == _musicOn) {
    
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"quietLarkspur.mp3"];
        [gameData setMusic:1];
        
    }
    [GameDataParser saveData:gameData];
    
}


- (void)restartTapped:(id)sender {

    midGameMenu.enabled = NO;
    endMenu.enabled = NO;
    
    int currentSceneTag = (int)[[CCDirector sharedDirector] runningScene].tag;
    if (currentSceneTag == kScenePuzzle) {
        CCScene *scene = [Puzzle scene];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:scene]];        
    } else if (currentSceneTag == kSceneMatch) {
       CCScene *scene = [MatchingGame scene];
       [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:scene]];
    }else if (currentSceneTag == kSceneLuggage) {
        CCScene *scene = [Luggage scene];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:scene]];
    }else if (currentSceneTag == kSceneCityscape) {
        CCScene *scene = [Cityscape scene];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:scene]];
    }else if (currentSceneTag == kSceneStory || currentSceneTag == kStoryPage) {
        CCScene *scene = [Scene00 scene];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:scene]];
    }
    
}

- (void)levelUpTapped:(id)sender {
    
    midGameMenu.enabled = NO;
    endMenu.enabled = NO;
    
    int currentSceneTag = (int)[[CCDirector sharedDirector] runningScene].tag;
    if (currentSceneTag == kSceneLuggage || currentSceneTag == kSceneCityscape || currentSceneTag == kSceneStory || currentSceneTag == kStoryPage) {
        CCScene *scene = [NOscrollMainMenu scene];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.25 scene:scene]];
    }else{
        // Go back to level menu
        CCScene *scene = [LevelSelect scene];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:scene]];
    }
    [[CCDirector sharedDirector] purgeCachedData];
    
}

- (void)nextTapped:(id)sender {
    
    midGameMenu.enabled = NO;
    endMenu.enabled = NO;

    //find out what level we are at in GameData
     GameData *gameData = [GameDataParser loadData];
#ifdef FREE
    //the new level is the current level and then add one
     int newLevel = gameData.selectedLevel + 1;
     
     Levels *selectedLevels = [LevelParser loadLevelsForChapter:gameData.selectedChapter];
     
    
     for (Level *level in selectedLevels.levels) {
    
         if (newLevel == level.number){
         
             gameData.selectedLevel = newLevel;
             [GameDataParser saveData:gameData];
         
            }
     }
     
     NSArray * allLevels = [selectedLevels levels];
     //NSLog(@"Count : %d", [allLevels count]);
    // NSLog(@"New Level : %d", newLevel);

    if (newLevel <= [allLevels count]) {
        
        int currentSceneTag = (int)[[CCDirector sharedDirector] runningScene].tag;
        if (currentSceneTag == kScenePuzzle) {
            
            CCScene *scene = [Puzzle scene];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:scene]];
            
        } else if (currentSceneTag == kSceneMatch) {
            
            CCScene *scene = [MatchingGame scene];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:scene]];
        }
    }
#else

    BOOL allPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:@"com.biggiebangle.tinytravelersnyc.complete"];
    
    if(gameData.selectedLevel<5 || allPurchased){
        //the new level is the current level and then add one
        int newLevel = gameData.selectedLevel + 1;
        
        Levels *selectedLevels = [LevelParser loadLevelsForChapter:gameData.selectedChapter];
        
        
        for (Level *level in selectedLevels.levels) {
            
            if (newLevel == level.number){
                
                gameData.selectedLevel = newLevel;
                [GameDataParser saveData:gameData];
                
            }
        }
        
        NSArray * allLevels = [selectedLevels levels];
         //But if its the last level, no need to reload
         if (newLevel <= [allLevels count]) {
       
             int currentSceneTag = (int)[[CCDirector sharedDirector] runningScene].tag;
             if (currentSceneTag == kScenePuzzle) {
                
                 CCScene *scene = [Puzzle scene];
                 [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:scene]];
                 
             } else if (currentSceneTag == kSceneMatch) {
                 
                 CCScene *scene = [MatchingGame scene];
                 [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:scene]];
             }
         }
    }else {
       
        _openStore++;
        [self openStore];
    }
#endif
}

- (void)backTapped:(id)sender {
    
    //find out what level we are at in GameData
    GameData *gameData = [GameDataParser loadData];
    //the new level is the current level and then add one
    int newLevel = gameData.selectedLevel - 1;
    
    Levels *selectedLevels = [LevelParser loadLevelsForChapter:gameData.selectedChapter];
    
    
    for (Level *level in selectedLevels.levels) {
        //Lets make sure the next level exists first
        if (newLevel == level.number){
            
            gameData.selectedLevel = newLevel;
            [GameDataParser saveData:gameData];
            
        }
    }
    
 
    //NSLog(@"Count : %d", [allLevels count]);
    // NSLog(@"New Level : %d", newLevel);
    
    //But if its the last level, no need to reload
    if (newLevel >= 0) {
        
        int currentSceneTag = (int)[[CCDirector sharedDirector] runningScene].tag;
        if (currentSceneTag == kScenePuzzle) {
            
            CCScene *scene = [Puzzle scene];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:scene]];
            
        } else if (currentSceneTag == kSceneMatch) {
            
            CCScene *scene = [MatchingGame scene];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:scene]];
        }
    }
    
}


- (void)continueGameTapped:(id)sender {
    
    midGameMenu.enabled = NO;
    endMenu.enabled = NO;
    
    [_shadowLayer runAction: [CCSequence actions:[CCFadeTo actionWithDuration:1.5 opacity:0], [CCCallFuncN actionWithTarget:self selector:@selector(removeShadowLayerUnlockGame)],nil]];
    [continueButton runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.5 scale:.1],[CCFadeTo actionWithDuration:.5 opacity:0], nil]];
    [endButton runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.5 scale:.1], [CCFadeTo actionWithDuration:.5 opacity:0],nil]];
    [restartButton runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.5 scale:.1], [CCFadeTo actionWithDuration:.5 opacity:0],nil]];
    [frown runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.5 scale:.1], [CCFadeTo actionWithDuration:.5 opacity:0],nil]];
  
  
}

#pragma mark -
#pragma mark MidGame Functionality

- (void)spawnMidGameMenu {
    _show = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu-selected.gif"]];
    _hide = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu-selected.gif"]];
    CCMenuItemToggle *toggleItem = [CCMenuItemToggle itemWithTarget:self
                                                           selector:@selector(showHideMidGameMenuTapped:) items:_hide, _show, nil];
    toggleMenu = [CCMenu menuWithItems:toggleItem, nil];
    toggleMenu.position = ccp(winSize.width * 0.07, winSize.height*.1);
    [self addChild:toggleMenu z:20];
    
    
}



- (void)showHideMidGameMenuTapped:(id)sender {
    
    CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
    if (toggleItem.selectedItem == _show) {
        [self showMidGameMenu];
    } else if (toggleItem.selectedItem == _hide) {
        [self hideMidGameMenu];
    }
    
}



- (void)showMidGameMenu {
    
    if(_sideShadowLayer){

        [_sideShadowLayer removeChild:midGameMenu cleanup:YES];
        [self removeChild:_sideShadowLayer cleanup:YES];
    }
    
    //Check to see if music is on or off to make sure the right button is showing
    GameData *gameDataForMusic = [GameDataParser loadData];


    
    //Add shadow
    
    _sideShadowLayer = [CCLayerColor layerWithColor: ccc4(0,0,0, 100)];
    [_sideShadowLayer setContentSize: CGSizeMake(winSize.width, winSize.height*.20)];
    _sideShadowLayer.position = ccp(-winSize.width, 0);
    [self addChild: _sideShadowLayer z:19];
    
    
    //Create Menu
   
    endButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"levelup.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"levelup-selected.gif"] target:self selector:@selector(levelUpTapped:)];
    restartButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"tryagain.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"tryagain-selected.gif"] target:self selector:@selector(restartTapped:)];
    _musicOn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"music-on.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"music-on-selected.gif"]];
    _musicOff = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"music-off.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"music-off-selected.gif"]];
    
    
    if (gameDataForMusic.music == 0) {

        toggleMusicButton = [CCMenuItemToggle itemWithTarget:self
                                                    selector:@selector(musicTapped:) items:_musicOff, _musicOn, nil];
        
    }else {
        //CCLOG(@"here???");
        toggleMusicButton = [CCMenuItemToggle itemWithTarget:self
                                                    selector:@selector(musicTapped:) items:_musicOn, _musicOff, nil];
    }
     
    restartButton.position = ccp(winSize.width * 0.3, winSize.height*.1);
    endButton.position = ccp(winSize.width * 0.5, winSize.height*.1);
    toggleMusicButton.position = ccp(winSize.width * 0.7, winSize.height*.1);
    midGameMenu = [CCMenu menuWithItems:endButton, restartButton, toggleMusicButton, nil];
    midGameMenu.position = CGPointZero;
    
    //Add shadow and then animate onto the screen
    [_sideShadowLayer addChild:midGameMenu];
    [_sideShadowLayer runAction: [CCMoveTo actionWithDuration:.5 position:ccp(0,0)]];

   
}

-(void)showNothing {
    
}

- (void)hideMidGameMenu {
    
      //animate off the screen to left, then remove shadowlayer once animation is complete


  
    [_sideShadowLayer runAction: [CCSequence actions:[CCMoveTo actionWithDuration:.5 position:ccp(-winSize.width ,0)],[CCCallFuncN actionWithTarget:self selector:@selector(removeMidGameMenu)], nil]];
    
    
    
}


- (void)hideMidGameMenuAtEnd {
    
    //animate down, then remove shadowlayer once animation is complete


        [_sideShadowLayer runAction: [CCSequence actions:[CCMoveTo actionWithDuration:.5 position:ccp(0 ,-winSize.height)],[CCCallFuncN actionWithTarget:self selector:@selector(removeMidGameMenu)], nil]];
    
        [toggleMenu runAction: [CCSequence actions:[CCFadeTo actionWithDuration:1 opacity:0],[CCCallFuncN actionWithTarget:self selector:@selector(removeMidGameMenuToggle)], nil]];
    
}

-(void)removeMidGameMenu {
    NSLog(@"remove mid game menu");
    
    midGameMenu.enabled = NO;
    [self removeChild:midGameMenu cleanup:YES];
    [self removeChild: _sideShadowLayer cleanup:YES];
 
    
}

-(void)removeMidGameMenuToggle {
    [self removeChild:toggleMenu cleanup:YES];
}
#pragma mark -
#pragma mark EndGame Functionality

- (void)showRestartMenu:(BOOL)won {
    
    // read in selected chapter number
    GameData *gameData = [GameDataParser loadData];
    // read in levels
    Levels *selectedLevels = [LevelParser loadLevelsForChapter:gameData.selectedChapter];
    
    [self spawnShadowLayer];
    

    endButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"levelup.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"levelup-selected.gif"] target:self selector:@selector(levelUpTapped:)];
    
    restartButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"tryagain.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"tryagain-selected.gif"] target:self selector:@selector(restartTapped:)];
    
    
    restartButton.scale = 0.1;
    endButton.scale = 0.1;
    
       
    if (won == YES ){
        
        [self spawnHappyFace];
        
        if (gameData.selectedLevel != 15){
            
            continueButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"next.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"next-selected.gif"] target:self selector:@selector(nextTapped:)];
            continueButton.scale = 0.1;
            restartButton.position = ccp(winSize.width * 0.3, winSize.height*.2);
            endButton.position = ccp(winSize.width * 0.5, winSize.height*.2);
            continueButton.position = ccp(winSize.width * 0.7, winSize.height*.2);
            
           
            endMenu = [CCMenu menuWithItems:endButton,restartButton,continueButton, nil];
            
            [continueButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2] ,[CCScaleTo actionWithDuration:0.5 scale:1.0],[CCCallFuncN actionWithTarget:self selector:@selector(createParticleHighlight)], nil]];
            
        
        }
        else {

            restartButton.position = ccp(winSize.width * 0.4, winSize.height*.2);
            endButton.position = ccp(winSize.width * 0.6, winSize.height*.2);
            endMenu = [CCMenu menuWithItems:endButton,restartButton, nil];
            
            
        }

       
        for (Level *level in selectedLevels.levels) {
           
         
            if(level.number ==  gameData.selectedLevel) {
                
                CCLayer *layer = [[CCLayer alloc] init];
                NSString *levelDescription = level.description;
                
                CCLabelTTF *layerLabelShadow = [CCLabelTTF labelWithString:NSLocalizedString(levelDescription, levelDescription)fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:35];
                layerLabelShadow.position =  ccp( winSize.width / 2 - 3 , winSize.height / 2 - 27 );
                layerLabelShadow.rotation = -6.0f;
                layerLabelShadow.color = ccc3(0,0,0);
                layerLabelShadow.opacity = 0;
                layerLabelShadow.scale = 2;
                [layer addChild:layerLabelShadow];
               
                
                CCLabelTTF *layerLabel = [CCLabelTTF labelWithString:NSLocalizedString(levelDescription, levelDescription)fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:35];
                layerLabel.position =  ccp( winSize.width / 2 , winSize.height / 2 - 30 );
                layerLabel.rotation = -6.0f;
                layerLabel.color = ccc3(255,255,255);
                layerLabel.opacity = 0;
                layerLabel.scale = 2;
                [layer addChild:layerLabel];
                
                [self addChild:layer];
                
                id scaleAction = [CCScaleTo actionWithDuration:2 scale:1];
                id easeAction1 = [CCEaseBounceOut actionWithAction:scaleAction];

                [layerLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.25] ,[CCFadeIn actionWithDuration:0.25],easeAction1, nil]];
                
                id scaleAction2 = [CCScaleTo actionWithDuration:2 scale:1];
                id easeAction2 = [CCEaseBounceOut actionWithAction:scaleAction2];
                
                [layerLabelShadow runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.25] ,[CCFadeIn actionWithDuration:0.25],easeAction2, nil]];

 
            }
            
        }
    }
 
    else {

        [self spawnSadFace];
        
        restartButton.position = ccp(winSize.width * 0.4, winSize.height*.4);
        endButton.position = ccp(winSize.width * 0.6, winSize.height*.4);
        endMenu = [CCMenu menuWithItems:endButton, restartButton, nil];
 
    }
    endMenu.position = CGPointZero;
    endMenu.scale = 0.1;
    [_shadowLayer addChild:endMenu z:10];
    [endButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2] ,[CCScaleTo actionWithDuration:0.5 scale:1.0], nil]];
    [restartButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2] ,[CCScaleTo actionWithDuration:0.5 scale:1.0], nil]];
    [endMenu runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2] ,[CCScaleTo actionWithDuration:0.5 scale:1.0], nil]];
    
    
}

- (void)createParticleHighlight  {
    CCParticleSystem *emitter_;
    emitter_ = [[CCParticleFlower alloc] initWithTotalParticles:50];
    [_shadowLayer addChild:emitter_ z:9];
    
    emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars.png"];
    emitter_.lifeVar = 0;
    emitter_.life = 3;
    emitter_.speed = 50;
    emitter_.speedVar = 0;
    emitter_.emissionRate = 10000;
    emitter_.position = ccp(winSize.width * 0.7, winSize.height*.2);
}


- (void)showLuggageRestartMenu:(BOOL)won {
    
    [self spawnShadowLayer];
    
    
    if (won == NO){
        //CCLOG(@"NO - show sad face, no menu");
        [self spawnSadFace];
        
         [_shadowLayer runAction: [CCSequence actions:[CCDelayTime actionWithDuration:3], [CCFadeTo actionWithDuration:2 opacity:0],[CCCallFuncN actionWithTarget:self selector:@selector(removeShadowLayer)],nil]];
        
        id scaleAction = [CCScaleTo actionWithDuration:.50 scale:1];
        id easeAction = [CCEaseBounceOut actionWithAction:scaleAction];
        [frown runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2] ,[CCFadeOut actionWithDuration:0.25], easeAction, nil]];
        
     
        
    }
    else {
        //CCLOG(@"YES - show happy face and menu menu");
        [self spawnHappyFaceDance];
        
       
        endButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"levelup.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"levelup-selected.gif"] target:self selector:@selector(levelUpTapped:)];
        
        restartButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"tryagain.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"tryagain-selected.gif"] target:self selector:@selector(restartTapped:)];
        
        
        restartButton.scale = 0.1;
        endButton.scale = 0.1;
        
        
       
        
        restartButton.position = ccp(winSize.width * 0.4, winSize.height*.45);
        endButton.position = ccp(winSize.width * 0.6, winSize.height*.45);
        endMenu = [CCMenu menuWithItems:endButton, restartButton, nil];
        
        endMenu.position = CGPointZero;
        endMenu.scale = 0.1;
        [_shadowLayer addChild:endMenu z:10];
        
        [endButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2] ,[CCScaleTo actionWithDuration:0.5 scale:1.0], nil]];
        [restartButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2] ,[CCScaleTo actionWithDuration:0.5 scale:1.0], nil]];
        [endMenu runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2] ,[CCScaleTo actionWithDuration:0.5 scale:1.0], nil]];
        
    }
   
    
    
}



- (void)spawnHappyFace {
    

    [[SimpleAudioEngine sharedEngine] playEffect:@"yay.mp3"];
    
    //Add the smile
    CCSprite *smile = [CCSprite spriteWithSpriteFrameName:@"smileyFace.png"];
    smile.position = ccp(winSize.width/2, winSize.height*.7);
    smile.opacity = 0;
    smile.scale = 2;
    [_shadowLayer addChild:smile];
    id scaleAction = [CCScaleTo actionWithDuration:2 scale:1];
    id easeAction1 = [CCEaseBounceOut actionWithAction:scaleAction];
    
    [smile runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.25] ,[CCFadeIn actionWithDuration:0.25],easeAction1, nil]];
    
}

- (void)spawnHappyFaceDance {
    

    [[SimpleAudioEngine sharedEngine] playEffect:@"yay.mp3"];
    
    //Add the smile
    smileDance = [CCSprite spriteWithSpriteFrameName:@"smileyFace.png"];
    smileDance.position = ccp(winSize.width/2, winSize.height*.7);
    smileDance.opacity = 0;
    smileDance.scale = 2;
    [self addChild:smileDance];
    
    id scaleAction = [CCScaleTo actionWithDuration:1 scale:1];
    id easeAction1 = [CCEaseBounceOut actionWithAction:scaleAction];
    
    CCJumpTo *jump1 = [CCJumpTo actionWithDuration:1.5 position:ccp(winSize.width*.1,winSize.height*.2) height:winSize.height*.6 jumps:1];
    CCEaseOut *squeze1 = [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:.1 scaleX:1 scaleY:.8] rate:2];
    CCEaseIn *expand1 = [CCEaseIn actionWithAction:[CCScaleTo actionWithDuration:.1 scaleX:1 scaleY:1] rate:2];
    
    CCJumpTo *jump2 = [CCJumpTo actionWithDuration:1.5 position:ccp(winSize.width*.5,winSize.height*.2) height:winSize.height*.4 jumps:1];
    CCEaseOut *squeze2 = [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:.1 scaleX:1 scaleY:.8] rate:2];
    CCEaseIn *expand2 = [CCEaseIn actionWithAction:[CCScaleTo actionWithDuration:.1 scaleX:1 scaleY:1] rate:2];
    
    CCJumpTo *jump3 = [CCJumpTo actionWithDuration:1.5 position:ccp(winSize.width*.8,winSize.height*.2) height:winSize.height*.6 jumps:1];
    CCEaseOut *squeze3 = [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:.1 scaleX:1 scaleY:.8] rate:2];
    CCEaseIn *expand3 = [CCEaseIn actionWithAction:[CCScaleTo actionWithDuration:.1 scaleX:1 scaleY:1] rate:2];
    
    CCJumpTo *jump4 = [CCJumpTo actionWithDuration:2 position:ccp(winSize.width*.5,winSize.height*.2) height:winSize.height*.8 jumps:1];
    CCEaseOut *squeze4 = [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:.1 scaleX:1 scaleY:.8] rate:2];
    CCEaseIn *expand4 = [CCEaseIn actionWithAction:[CCScaleTo actionWithDuration:.1 scaleX:1 scaleY:1] rate:2];
    
    CCMoveTo *finalMove = [CCMoveTo actionWithDuration:.25 position:ccp(winSize.width/2, winSize.height*.7)];
    

    
    [smileDance runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.25] ,[CCFadeIn actionWithDuration:0.25],easeAction1,jump1, squeze1, expand1, jump2, squeze2, expand2, jump3, squeze3, expand3, jump4, squeze4, expand4, finalMove, nil]];
    
}


- (void)spawnSadFace {
   
    [[SimpleAudioEngine sharedEngine] playEffect:@"awwAgain.mp3"];
    
    frown = [CCSprite spriteWithSpriteFrameName:@"frownyFace.png"];
    frown.position = ccp(winSize.width/2, winSize.height*.7);
    frown.opacity = 0;
    frown.scale = .75;
    [_shadowLayer addChild:frown];
    id scaleAction = [CCScaleTo actionWithDuration:.50 scale:1];
    id easeAction = [CCEaseBounceOut actionWithAction:scaleAction];
    [frown runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.25] ,[CCFadeIn actionWithDuration:0.25], easeAction, nil]];
    
}

- (void)spawnShadowLayer {
   
    _shadowLayer = [CCLayerColor layerWithColor: ccc4(0,0,0, 0)];
    [_shadowLayer setContentSize: CGSizeMake(winSize.width, winSize.height)];
    _shadowLayer.position = ccp(0, 0);
    [self addChild: _shadowLayer];
    [_shadowLayer runAction: [CCSequence actions:[CCDelayTime actionWithDuration:.5] ,[CCFadeTo actionWithDuration:1.5 opacity:100], nil]];
    
}




-(void)removeShadowLayer {
     CCLOG(@"Shadow Removed!");
    [self removeChild: _shadowLayer];
  
    
    
}

-(void)removeShadowLayerUnlockGame {
    
    [self removeChild: _shadowLayer];
    ///Add unlock to Level Data
    GameData *gameData = [GameDataParser loadData];
    Levels *selectedLevels = [LevelParser loadLevelsForChapter:gameData.selectedChapter];
    for (Level *level in selectedLevels.levels) {
        
        level.unlocked = YES;
        //CCLOG(@"unlocking Level %i", level.unlocked);
        
        
    }
    
    // store the selected level data aka the unlock in Levels xml
    [LevelParser saveData:selectedLevels forChapter:gameData.selectedChapter];

    
    
    
    
}

- (void)openStore {
   // NSLog (@"Store open!");
    if (_openStore == 1){
        // NSLog (@"store equals one");
        _store = [Store node];
        [self addChild:_store ];
        _store.position = ccp(0,0);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeStore:)
                                                     name:@"RemoveStore"
                                                   object:nil];
        
    }
    
    
    
    
}




- (void)removeStore:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"RemoveStore"]){
        NSLog (@"Successfully received the test notification!");
        
        [self removeChild:_store cleanup:YES];
        _openStore=0;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        endMenu.enabled=YES;
        
    }
}

@end
