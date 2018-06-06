//
//  LevelSelectMG.m
//  

#import "LevelSelect.h"
#import "Level.h"
#import "Levels.h"
#import "LevelParser.h"

#import "NOscrollMainMenu.h"
#import "MatchingGame.h"
#import "Puzzle.h"

#import "TTIAPHelper.h"

//#import "Chapter.h"
//#import "Chapters.h"
//#import "ChapterParser.h"

@implementation LevelSelect
@synthesize iPad, device;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LevelSelect *layer = [LevelSelect node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) onPlay: (CCMenuItemImage*) sender {
   NSLog(@"onPlay");
 // the selected level is determined by the tag in the menu item 
    int selectedLevel = (int)sender.tag;
    
 // store the selected level in GameData

    gameData.selectedLevel = selectedLevel;
    [GameDataParser saveData:gameData];
    
    int GameChapter = gameData.selectedChapter;
    
    if (GameChapter == 2)   {
    
        // load the game scene based on selected Chapter
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MatchingGame scene] ]];
    }
    else if(GameChapter == 4)   {
            
        // load the game scene based on selected Chapter
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[Puzzle scene] ]];
    }
}

- (void)onLevelUp: (id) sender {
    /* 
     This is where you choose where clicking 'level up' sends you.
     */
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[NOscrollMainMenu scene] ]];
}

- (void)addLevelUpAndStoreButton {
    
    CCMenuItemImage *goLevelUp = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"levelup.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"levelup-selected.gif"] target:self selector:@selector(onLevelUp:)];
     CCMenuItemImage * storeButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"store.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"store-selected.png"] target:self selector:@selector(openStore:)];
    
     CCMenu *levelUp = [CCMenu menuWithItems: goLevelUp, nil];
    
     CCMenu *store = [CCMenu menuWithItems: storeButton, nil];
    

    
    
    
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if (self.iPad) {

        // Add menu image to menu
        // position menu in the bottom left of the screen (0,0 starts bottom left)
        levelUp.position = ccp(64, 64);
        store.position = ccp(screenSize.width - 64, 64);
        
        // Add menu to this scene
       
    }
    else {


        // position menu in the bottom left of the screen (0,0 starts bottom left)
        levelUp.position = ccp(32, 32);
        store.position = ccp(screenSize.width - 32, 32);

    }
    [self addChild: levelUp];
#ifdef FREE
#else
    [self addChild: store];
#endif
}

- (void)onExitTransitionDidStart{
    
    [[[CCDirector sharedDirector]touchDispatcher] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}
-(void)onExit{
    
    [self removeAllChildrenWithCleanup:YES];

}



- (void)openStore:(id)sender {
    if (_storeClosed == YES){
        _store = [Store node];
        [self addChild:_store];
        _store.position = ccp(0,0);
        _storeClosed = NO;
    }    
}

- (void)removeStore:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"RemoveStore"]){
        
        [self removeChild:_store cleanup:YES];
        _storeClosed = YES;
       // [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[LevelSelect scene] ]];
    }
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
      NSLog (@"Touch detected in Level Select");
    return TRUE;
    
}

- (id)init {
    
    if( (self=[super init])) {
        
        _background = [Background node];
        [self addChild:_background z:-5];
        [_background createCity];
       
        
        // Create our HUD sprite sheet and frame cache
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"MENU25.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"MENU25.plist"];
        [self addChild:_spriteSheet];
        
        
        
       self.iPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
       
        if (self.iPad) {
            self.device = @"iPad";
        }
        else {
            self.device = @"iPhone";
        }

        
     // read in selected chapter number:
        gameData = [GameDataParser loadData];
        
     // Read in selected chapter levels
        CCMenu *levelMenu = [CCMenu menuWithItems: nil]; 
        NSMutableArray *overlay = [NSMutableArray new];
        
        Levels *selectedLevels = [LevelParser loadLevelsForChapter:gameData.selectedChapter];
        
     
        


        
 
     // Create a button for every level
        NSUInteger count = 0;
        for (Level *level in selectedLevels.levels) {
            count++;
           // CCLOG(@"Level is %i ", count);
            
/*#ifdef FREE
           
                
                CCSprite *normal =   [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@-Normal.png", level.name]];
                CCSprite *selected =   [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@-Selected.png", level.name]];
                
                CCMenuItemImage *item = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:selected target:self selector:@selector(onPlay:)];
                
                [item setTag:level.number]; // note the number in a tag for later usage
                [item setIsEnabled:level.unlocked];  // ensure locked levels are inaccessible
                
                [levelMenu addChild:item];
                
                
                if (!level.unlocked) {
                    
                    NSString *overlayImage = [NSString stringWithFormat:@"Locked.png"];
                    CCSprite *overlaySprite = [CCSprite spriteWithSpriteFrameName:overlayImage];
                    [overlaySprite setTag:level.number];
                    [overlay addObject:overlaySprite];
                }
                else if(level.stars == true) {
                    
                    
                    NSString *overlayImage = [NSString stringWithFormat:@"trophy.png"];
                    CCSprite *overlaySprite = [CCSprite spriteWithSpriteFrameName:overlayImage];
                    [overlaySprite setTag:level.number];
                    [overlay addObject:overlaySprite];
                }

            
        }
        
#else*/
        
        BOOL allPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:@"com.biggiebangle.tinytravelersnyc.complete"];
        if (count <6 || allPurchased){
                
                CCSprite *normal =   [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@-Normal.png", level.name]];
                CCSprite *selected =   [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@-Selected.png", level.name]];
                
                CCMenuItemImage *item = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:selected target:self selector:@selector(onPlay:)];
                
                [item setTag:level.number]; // note the number in a tag for later usage
                [item setIsEnabled:level.unlocked];  // ensure locked levels are inaccessible
                
                [levelMenu addChild:item];
                
                
                if (!level.unlocked) {
                    
                    NSString *overlayImage = [NSString stringWithFormat:@"Locked.png"];
                    CCSprite *overlaySprite = [CCSprite spriteWithSpriteFrameName:overlayImage];
                    [overlaySprite setTag:level.number];
                    [overlay addObject:overlaySprite];
                }
                else if(level.stars == true) {
                    
                    
                    NSString *overlayImage = [NSString stringWithFormat:@"trophy.png"];
                    CCSprite *overlaySprite = [CCSprite spriteWithSpriteFrameName:overlayImage];
                    [overlaySprite setTag:level.number];
                    [overlay addObject:overlaySprite];
                }
            }
            else{
                
                CCSprite *unpaid =   [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"unpaid.png"]];
                CCSprite *unpaid2 =   [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"unpaid.png"]];
                CCMenuItemImage *item = [CCMenuItemSprite itemWithNormalSprite:unpaid selectedSprite:unpaid2 target:self selector:@selector(openStore:)];
                [item setTag:level.number]; // note the number in a tag for later usage
                [item setIsEnabled:level.unlocked];  // ensure locked levels are inaccessible
                [levelMenu addChild:item];
                
                
            }
            
        }
//#endif
            
  
        



        [levelMenu alignItemsInColumns:
          [NSNumber numberWithInt:5],
         [NSNumber numberWithInt:5],
         [NSNumber numberWithInt:5],
          nil];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
     // Move the whole menu up by a small percentage so it doesn't overlap the levelUp button
        levelMenu.position = ccp(winSize.width / 2 , winSize.height / 2);
        CGPoint newPosition = levelMenu.position;
        newPosition.y = newPosition.y + (newPosition.y / 10);
        [levelMenu setPosition:newPosition];
        
        [self addChild:levelMenu z:-3];

     // Create layers for star/padlock overlays
        CCLayer *overlays = [[CCLayer alloc] init];
        
        for (CCMenuItem *item in levelMenu.children) {
 
         // set position of overlay sprites
         
            for (CCSprite *overlaySprite in overlay) {
                if (overlaySprite.tag == item.tag) {
                    [overlaySprite setAnchorPoint:item.anchorPoint];
                    [overlaySprite setPosition:item.position];
                    [overlays addChild:overlaySprite];
                }
            }
        }
        
     // Put the overlay layers on the screen at the same position as the levelMenu
        
        [overlays setAnchorPoint:levelMenu.anchorPoint];
        [overlays setPosition:levelMenu.position];
        [self addChild:overlays];
        //[overlays release];

        
        
     // Add level up button and store
        
        [self addLevelUpAndStoreButton];
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeStore:)
                                                 name:@"RemoveStore"
                                               object:nil];
    
        _storeClosed = YES;
    
     [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    return self;
}



@end
