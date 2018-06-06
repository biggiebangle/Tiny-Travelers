#import "Scene08.h"

#import "Scene00.h"
#import "Scene07.h"

#import "sceneTag.h"
#import "LevelSelect.h"
#import "GameData.h"
#import "GameDataParser.h"
//#import "MainMenu.h"
#import "NOscrollMainMenu.h"

@implementation Scene08
{
    CCSprite *_btnUp;
    CCSprite *_btnLeft;
    CCSprite *_btnReadWords;
    
    CGPoint _touchPoint;
    UISwipeGestureRecognizer *Swiperight;
    UISwipeGestureRecognizer *Swipeleft;
    
    CCSprite *_traveler1;
    CCSprite *_traveler2;
    CCSprite *_traveler3;
    
}

#pragma mark -
#pragma mark Scene Setup and Initialize

+(id) scene
{
	
	CCScene *scene = [CCScene node];
    scene.tag = kStoryPage;
	
	HUDLayer *hud = [HUDLayer node];
    [scene addChild:hud z:1];
    
    Scene08 *layer = [[Scene08 alloc] initWithHUD:hud];
	
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


        
        readText = NO;
        
        //Consistent margin for game and device
        winSize = [CCDirector sharedDirector].winSize;
        Margin = winSize.width*.01;

        //Set UP
        
        [self setUpMainCharacters];
        
        _story = [Words node];
        [self addChild:_story];
        [_story createWords:8];

        [_hud spawnMidGameMenu];
        [self setUpFooter];
        

        
        
        [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        
	}
	return self;
}


-(void)onEnterTransitionDidFinish{
    
    [super onEnterTransitionDidFinish];
    [self setUpMainCharactersAnimation];
    Swipeleft =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleViewsSwipeLeft:)];
    [Swipeleft setDirection: UISwipeGestureRecognizerDirectionLeft];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:Swipeleft];
    Swiperight =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleViewsSwipeRight:)];
    [Swiperight setDirection: UISwipeGestureRecognizerDirectionRight];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:Swiperight];
}

- (void)onExitTransitionDidStart{

    [_traveler1 stopAllActions];
    [_traveler2 stopAllActions];
    [_traveler3 stopAllActions];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];

    [[[CCDirector sharedDirector]touchDispatcher] removeDelegate:self];


    
}



- (void)handleViewsSwipeRight:(UISwipeGestureRecognizer *)gesture {
    
    if (readText == NO ) {
        
 
        [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
        [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionMoveInL transitionWithDuration:.5 scene:[Scene07 scene] ]];
    }
    
}

- (void)handleViewsSwipeLeft:(UISwipeGestureRecognizer *)gesture {
    

    
}






#pragma mark -
#pragma mark Standard Scene Setup

- (void)setUpMainCharacters
{
    

    
    _traveler1  = [CCSprite spriteWithSpriteFrameName:@"traveler1_frown.png"];
    _traveler1.position = CGPointMake(winSize.width*.2, winSize.height*.4);
    
    [self addChild:_traveler1];
    

    
    _traveler2  = [CCSprite spriteWithSpriteFrameName:@"traveler2_frown.png"];
    _traveler2.position = CGPointMake(winSize.width*.5, winSize.height*.4);
    
    [self addChild:_traveler2];
    
 
    
    _traveler3  = [CCSprite spriteWithSpriteFrameName:@"traveler3_frown.png"];
    _traveler3.position = CGPointMake(winSize.width*.8, winSize.height*.4);
    
    [self addChild:_traveler3];
    
    [_traveler3 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:10],[CCCallFuncN actionWithTarget:self selector:@selector(spawnParticleHighlight)],nil]];
    
    
    
}

- (void)setUpMainCharactersAnimation
{
    
    id wait = [CCDelayTime actionWithDuration: 4 ];
    id wait2 = [CCDelayTime actionWithDuration:4.5];
    
    

    //Character 1
    

    CCAction *showSmile= [CCCallBlock actionWithBlock:^{
        NSString *smile =  [NSString stringWithFormat:@"traveler1_smile.png"];
        [_traveler1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:smile]];
    }];
    
    
    [_traveler1 runAction:[CCSequence actions: wait, showSmile, nil]];
    
    //Character 2
    
    CCAction *showSmile2= [CCCallBlock actionWithBlock:^{
        NSString *smile2 =  [NSString stringWithFormat:@"traveler2_smile.png"];
        [_traveler2 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:smile2]];
    }];
    
    
    [_traveler2 runAction:[CCSequence actions: wait2, showSmile2, nil]];
    
    //Character 1
    
    
    CCAction *showSmile3= [CCCallBlock actionWithBlock:^{
        NSString *smile3 =  [NSString stringWithFormat:@"traveler3_smile.png"];
        [_traveler3 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:smile3]];
    }];
    
    
    [_traveler1 runAction:[CCSequence actions: wait, showSmile3, nil]];
    

    
    
    
    
}


- (void)readText
{
    
    if (readText == NO)
    {
        CCSprite *disableMenu =  [CCSprite spriteWithSpriteFrameName:@"menu.png"];
        
        id wait = [CCDelayTime actionWithDuration: 0.5 ];
        id wait2 = [CCDelayTime actionWithDuration: 14 ];
        
        CCAction *fadeOut = [CCFadeTo actionWithDuration:.25 opacity:50];
        CCAction *fadeOut2 = [CCFadeTo actionWithDuration:.25 opacity:50];
        CCAction *fadeOut3 = [CCFadeTo actionWithDuration:.25 opacity:50];
        CCAction *fadeIn = [CCFadeTo actionWithDuration:.25 opacity:255];
        CCAction *fadeIn2 = [CCFadeTo actionWithDuration:.25 opacity:255];
        CCAction *fadeIn3 = [CCFadeTo actionWithDuration:.25 opacity:255];
        
        CCAction *playSound = [CCCallBlock actionWithBlock:^{
           
            readText = YES;
            [_hud hideMidGameMenuAtEnd];
            
            disableMenu.position = ccp(winSize.width * 0.07, winSize.height*.1);
            disableMenu.opacity = 50;
            [self addChild:disableMenu];
            [_btnLeft runAction:fadeOut2];
            [_btnUp runAction:fadeOut];
            [_btnReadWords runAction:fadeOut3];
            [[SimpleAudioEngine sharedEngine] playEffect:@"pg08.mp3"];
            
        }];
        
        CCAction *soundStopped = [CCCallBlock actionWithBlock:^{
            
            readText = NO;
            [self removeChild:disableMenu cleanup:YES];
            [_hud spawnMidGameMenu];
            [_btnLeft runAction:fadeIn2];
            [_btnUp runAction:fadeIn];
            [_btnReadWords runAction:fadeIn3];
          
        }];
        
        
        [_background runAction:[CCSequence actions:wait, playSound,wait2,soundStopped, nil] ];
        
        
    }
    
}

- (void)spawnParticleHighlight  {

    CCParticleSystem *emitter_;
    emitter_ = [[CCParticleFlower alloc] initWithTotalParticles:50];
    [self addChild:emitter_];
    
    emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars.png"];
    emitter_.lifeVar = 0;
    emitter_.life = 3;
    emitter_.speed = 50;
    emitter_.speedVar = 0;
    emitter_.emissionRate = 10000;
    emitter_.position = ccp(winSize.width - _btnUp.contentSize.width/2 - Margin*2, _btnUp.contentSize.height/2 + Margin*2);
}

- (void)setUpFooter
{
  
    

    _btnUp = [CCSprite spriteWithSpriteFrameName:@"levelup.png"];
    _btnUp.position = CGPointMake(winSize.width - _btnUp.contentSize.width/2 - Margin*2, _btnUp.contentSize.height/2 + Margin*2);
    
    [self addChild:_btnUp];
    
    
    
    _btnLeft = [CCSprite spriteWithSpriteFrameName:@"back.png"];
    
    _btnLeft.position = CGPointMake(winSize.width - _btnLeft.contentSize.width - _btnLeft.contentSize.width/2 - Margin*4, _btnLeft.contentSize.height/2 + Margin*2);
    
    
    [self addChild:_btnLeft];
    
    //Can't read it in Spanish or Chinese - just yet
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([language  isEqual: @"en"])
    {
        
        _btnReadWords = [CCSprite spriteWithSpriteFrameName:@"listen.png"];
        _btnReadWords.position = CGPointMake(winSize.width- _btnReadWords.contentSize.width/2 - Margin, winSize.height- _btnReadWords.contentSize.height/2 -Margin);
        
        
        [self addChild:_btnReadWords];
    }
    
    
    
}



#pragma mark -
#pragma mark Touch Events

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    

    if (CGRectContainsPoint(_btnLeft.boundingBox, touchLocation)) {
        
      
        
        if (readText == NO)
        {
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionMoveInL transitionWithDuration:.5 scene:[Scene07 scene] ]];
        }
        
    }
    else if (CGRectContainsPoint(_btnUp.boundingBox, touchLocation)) {
        
    
        
        if (readText == NO)
        {
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[NOscrollMainMenu scene] ]];
        }
        
    }
    else if (CGRectContainsPoint(_btnReadWords.boundingBox, touchLocation)) {
        
        //Can't read it in Spanish or Chinese - just yet
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if([language  isEqual: @"en"])
        {
            [self readText];
        }
        
    }
    else if (CGRectContainsPoint(_traveler1.boundingBox, touchLocation)) {
        
       
        
        id actionMoveDown = [CCMoveTo actionWithDuration:.25 position:ccp(winSize.width*.2, winSize.height*.4-3)];
        id actionMoveUpFast = [CCMoveTo actionWithDuration: .25 position:ccp(winSize.width*.2, winSize.height*.4)];
        
         [_traveler1 runAction:[CCSequence actions: actionMoveDown, actionMoveUpFast, nil]];
        
        
        
    }
    else if (CGRectContainsPoint(_traveler2.boundingBox, touchLocation)) {
        
  
        
        id actionMoveDown = [CCMoveTo actionWithDuration:.25 position:ccp(winSize.width*.5, winSize.height*.4-3)];
        id actionMoveUpFast = [CCMoveTo actionWithDuration: .25 position:ccp(winSize.width*.5, winSize.height*.4)];
        [_traveler2 runAction:[CCSequence actions: actionMoveDown, actionMoveUpFast, nil]];
        
        
       
        
    }
    else if (CGRectContainsPoint(_traveler3.boundingBox, touchLocation)) {
        
     
        
        id actionMoveDown = [CCMoveTo actionWithDuration:.25 position:ccp(winSize.width*.8, winSize.height*.4-3)];
        id actionMoveUpFast = [CCMoveTo actionWithDuration: .25 position:ccp(winSize.width*.8, winSize.height*.4)];
        [_traveler3 runAction:[CCSequence actions: actionMoveDown, actionMoveUpFast, nil]];
        
        
        
        
        
    }
    
    
    
    
    return TRUE;
}


#pragma mark -
#pragma mark Game Loop




@end
