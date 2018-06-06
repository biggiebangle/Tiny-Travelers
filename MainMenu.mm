//
//  MainMenu.m

#import "MainMenu.h"  

#import "SimpleAudioEngine.h"
#import "LevelSelect.h"
#import "Luggage.h"
#import "Cityscape.h"
#import "Scene00.h"


#import "AppDelegate.h"




@implementation MainMenu


+(CCScene *) scene
{
	
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenu *layer = [MainMenu node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void)onSelectChapter:(CCMenuItemImage *)sender {
    
     if (_storeClosed == YES){
    
       //CCLOG(@"writing the selected stage to GameData.xml as %i", sender.tag);

        [gameData setSelectedChapter:(int)sender.tag];
        [GameDataParser saveData:gameData];
        if(sender.tag == 2 || sender.tag == 4)
        {
        [self playSound];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[LevelSelect scene] ]];
        }else if (sender.tag == 1)
        {
        [self playSound];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[Luggage scene] ]];
        }else if (sender.tag == 3)
        {
            [self playSound];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[Cityscape scene] ]];
        }else if (sender.tag == 5)
        {
//#ifdef FREE
            [self playSound];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[Scene00 scene] ]];

/*#else
            if (allPurchased ){
                [self playSound];
                [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[Scene00 scene] ]];
                
            }else {
                [self openStore:sender];
                
            }
#endif*/
            
     
        }
     }
}

- (void) onExitTransitionDidStart {
    //[self removeChild:layer1 cleanup:YES];
    // [self removeChild:scroller cleanup:YES];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    

}

-(void) onExit {


}

- (void)playSound {
      //[[SimpleAudioEngine sharedEngine] playEffect:@"pageTurn.mp3"];
}

- (CCLayer*)layerWithChapterName:(NSString*)chapterName
                   chapterNumber:(int)chapterNumber {
    
    CCLayer *layer = [[CCLayer alloc] init];
    

    CCMenuItemSprite *image;
    NSString *imageName;
#ifdef FREE
     imageName = [NSString stringWithFormat: @"%dGame.png", chapterNumber];
#else
    if (chapterNumber <5 || allPurchased ){
        imageName = [NSString stringWithFormat: @"%dGame.png", chapterNumber];
        
    }else {
        imageName = [NSString stringWithFormat: @"%dGame_dark.png", chapterNumber];
        
    }
#endif

    
    image = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:imageName] selectedSprite:[CCSprite spriteWithSpriteFrameName:imageName] target:self selector:@selector(onSelectChapter:)];
    
    image.tag = chapterNumber;
    CCMenu *menu = [CCMenu menuWithItems: image, nil];
    [menu alignItemsVertically];
    menu.position = ccp(screenSize.width / 2 , screenSize.height*.56);
    [layer addChild: menu];
    
    
    return layer;
}


- (void)musicTapped:(id)sender {

    
 /*   CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
    if (toggleItem.selectedItem == _musicOff) {
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        [gameData setMusic:0];

    } else if (toggleItem.selectedItem == _musicOn) {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"quietLarkspur.mp3"];
        [gameData setMusic:1];
       
    }
    [GameDataParser saveData:gameData];*/
  
}
- (void)openStore:(id)sender {
    
    /*

    if (_storeClosed == YES){
        _store = [Store node];
        [self addChild:_store ];
        _store.position = ccp(0,0);
        _storeClosed = NO;
    }*/
    
}

                                      
/*- (void)storeClosing:(NSNotification *) notification {

    if ([[notification name] isEqualToString:@"StoreClosing"]){

    [self removeChild:_store cleanup:YES];
    _storeClosed = YES;
        
    allPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:@"com.biggiebangle.tinytravelersnyc.complete"];

        if (allPurchased) {
            if(_storyPurchased == NO){
                _storyPurchased = YES;
                [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenu scene] ]];
            }
        }
       }
 }*/


    
    


/*- (void)spawnMusicAndStoreMenu {
    
    _musicOn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"music-on.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"music-on-selected.gif"]];
    _musicOff = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"music-off.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"music-off-selected.gif"]];

    _storeButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"store.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"store-selected.png"] target:self selector:@selector(openStore:)];
    
    _storeButton.position = ccp(screenSize.width - _storeButton.contentSize.width - menuMargin*2,0);
    toggleMusicButton.position = ccp(menuMargin + _musicOn.contentSize.height/2, menuMargin + _musicOn.contentSize.height/2);
    

    if (gameData.music == 0) {
        toggleMusicButton = [CCMenuItemToggle itemWithTarget:self
                                                    selector:@selector(musicTapped:) items:_musicOff, _musicOn, nil];
        
    }else {
        toggleMusicButton = [CCMenuItemToggle itemWithTarget:self
                                                    selector:@selector(musicTapped:) items:_musicOn, _musicOff, nil];
    }
    
#ifdef FREE
 toggleMusicMenu = [CCMenu menuWithItems:toggleMusicButton, nil];
#else
    toggleMusicMenu = [CCMenu menuWithItems:toggleMusicButton, _storeButton, nil];
#endif
    
    toggleMusicMenu.position = ccp(menuMargin + _musicOn.contentSize.height/2, menuMargin + _musicOn.contentSize.height/2);
    [self addChild:toggleMusicMenu];
}
- (void)spawnArrow {
    CCSprite *arrowhead = [CCSprite spriteWithSpriteFrameName:@"arrow.png"];
    
    arrowhead.opacity = 80;
    arrowhead.position = ccp(screenSize.width/2,screenSize.height*.56);
    arrowhead.scaleX = .95;
    
    [self addChild:arrowhead];
}*/
- (id)init {
    
    if( (self=[super init])) {
        
       
        screenSize = [CCDirector sharedDirector].winSize;
        
        NSMutableArray *layers = [NSMutableArray new];
    
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"MENU25.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"MENU25.plist"];
        [self addChild:_spriteSheet];
        
        //Consistent margin for game and device
        NSString *menuItem = [NSString stringWithFormat: @"1Game.png"];
        
        CCMenuItemSprite *image = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:menuItem] selectedSprite:[CCSprite spriteWithSpriteFrameName:menuItem]];
        
        double myDouble = image.contentSize.height*.03125;
        menuMargin = (int)myDouble;
        
        SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
        gameData = [GameDataParser loadData];
        if (sae.isBackgroundMusicPlaying == NO && gameData.music == 1) {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"quietLarkspur.mp3"];
        }
        
       // _background = [Background node];
       // [self addChild:_background];
       // [_background createCity];
        

 
        //_weather = [Weather node];
        //[self addChild:_weather];
#ifdef TTLUGGAGE
#else
       // [self spawnArrow];
#endif

       // allPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:@"com.biggiebangle.tinytravelersnyc.complete"];
        
        _storeClosed = YES;
        if (allPurchased){
           _storyPurchased = YES;
        }else {
            _storyPurchased = NO;
        }

       // [self spawnMusicAndStoreMenu];
        
#ifdef TTLUGGAGE
        CCLayer *layer1 = [self layerWithChapterName:@"luggage" chapterNumber:1];
        [layers addObject:layer1];
#else
        CCLayer *layer1 = [self layerWithChapterName:@"luggage" chapterNumber:1];
        [layers addObject:layer1];
        CCLayer *layer2 = [self layerWithChapterName:@"match" chapterNumber:2];
        [layers addObject:layer2];
        CCLayer *layer3 = [self layerWithChapterName:@"cityscape" chapterNumber:3];
        [layers addObject:layer3];
        CCLayer *layer4 = [self layerWithChapterName:@"puzzle" chapterNumber:4];
        [layers addObject:layer4];
        CCLayer *layer5 = [self layerWithChapterName:@"story" chapterNumber:5];
        [layers addObject:layer5];

#endif

        
       
        
       scroller = [[CCScrollLayer alloc] initWithLayers:layers
                                                            widthOffset:210];
    
        [scroller selectPage:(gameData.selectedChapter -1)];
        
       [self addChild:scroller];
    

      /*  [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(storeClosing:)
                                                     name:@"StoreClosing"
                                                   object:nil];*/

        
      
        
    }
    return self;
}


@end
