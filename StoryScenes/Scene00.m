
#import "Scene00.h"
#import "Scene01.h"


#import "sceneTag.h"
#import "LevelSelect.h"
#import "GameData.h"
#import "GameDataParser.h"





@implementation Scene00
{
    UISwipeGestureRecognizer * Swipeleft;
    UISwipeGestureRecognizer * Swiperight;
    CCSprite *bookTitle;
  
}

#pragma mark -
#pragma mark Scene Setup and Initialize

+(id) scene
{
	
	CCScene *scene = [CCScene node];
    scene.tag = kSceneStory;
	
	HUDLayer *hud = [HUDLayer node];
    [scene addChild:hud z:1];
    
    Scene00 *layer = [[Scene00 alloc] initWithHUD:hud];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)initWithHUD:(HUDLayer *)hud
{
	if( (self=[super init])) {
        
        _hud = hud;
        
        _background = [Background node];
        [self addChild:_background];
        [_background createCity];
        
        //Add unlock to Level Data and make sure we only have one level
        
        GameData *gameData = [GameDataParser loadData];
        gameData.selectedLevel = 1;
        [GameDataParser saveData:gameData];
        

        // Create our sprite sheets and frame cache
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"StoryObjects9.plist"];
        _spriteSheetObjects = [CCSpriteBatchNode batchNodeWithFile:@"StoryObjects9.pvr.ccz"];
        [self addChild:_spriteSheetObjects];
        

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"StoryTextTraveler3.plist"];
        _spriteSheetTextandTravelers = [CCSpriteBatchNode batchNodeWithFile:@"StoryTextTraveler3.pvr.ccz"];
        [self addChild:_spriteSheetTextandTravelers];
        
        
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"HUDSPRITES12.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"HUDSPRITES12.plist"];
        [self addChild:_spriteSheet];
        

        

        
        
        //Consistent margin for game and device
        CGSize winSize = [CCDirector sharedDirector].winSize;
        Margin = winSize.width*.01;
        
        
        [self setUpBookTitle];
    
        [_hud spawnMidGameMenu];

        
        [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        
	}
	return self;
}

-(void)onEnterTransitionDidFinish{
    
    [super onEnterTransitionDidFinish];
    Swiperight =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleViewsSwipeRight:)];
    [Swiperight setDirection: UISwipeGestureRecognizerDirectionRight];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:Swiperight];
    Swipeleft =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleViewsSwipeLeft:)];
    [Swipeleft setDirection: UISwipeGestureRecognizerDirectionLeft];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:Swipeleft];


}

- (void)onExitTransitionDidStart{
    [bookTitle stopAllActions];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
    [[[CCDirector sharedDirector]touchDispatcher] removeDelegate:self];

}


- (void)handleViewsSwipeLeft:(UISwipeGestureRecognizer *)gesture {
    

    
   [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
   [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
   [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:2.0 scene:[Scene01 scene] ]];

}

- (void)handleViewsSwipeRight:(UISwipeGestureRecognizer *)gesture {
    

    
}




#pragma mark -
#pragma mark Additional Scene Setup (sprites and such)

- (void)setUpBookTitle
{
    

    bookTitle = [CCSprite spriteWithSpriteFrameName:@"title_text.png"];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    bookTitle.position = CGPointMake(winSize.width/2,winSize.height+200);
    [self addChild:bookTitle];
    
     id actionMoveDown = [CCMoveTo actionWithDuration: 1.5 position:ccp(winSize.width/2, winSize.height*.75)];
     id actionMoveUp = [CCMoveTo actionWithDuration:.25 position:ccp(winSize.width/2, winSize.height*.75+3)];
     id actionMoveDownFast = [CCMoveTo actionWithDuration: .25 position:ccp(winSize.width/2, winSize.height*.75)];
    
    id wait = [CCDelayTime actionWithDuration: 1.5];
    

    
    CCAction *turnPage = [CCCallBlock actionWithBlock:^{
        
        [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
        [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1.0 scene:[Scene01 scene] ]];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"shakerpop.mp3"];
    }];
    

    [bookTitle runAction:[CCSequence actions: actionMoveDown,  actionMoveUp, actionMoveDownFast, wait, turnPage, nil]];
}




#pragma mark -
#pragma mark Touch Events

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    

    return TRUE;
}





@end
