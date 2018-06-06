
#import "Scene06.h"

#import "Scene00.h"
#import "Scene05.h"
#import "Scene07.h"

#import "sceneTag.h"
#import "LevelSelect.h"
#import "GameData.h"
#import "GameDataParser.h"

@implementation Scene06
{
    CCSprite *_btnLeft;
    CCSprite *_btnRight;
    CCSprite *_btnReadWords;
    
    CGPoint _touchPoint;
    UISwipeGestureRecognizer *Swipeleft;
    UISwipeGestureRecognizer *Swiperight;
    
    CCSprite *_libery;
    CCSprite *_museum;
    
}

#pragma mark -
#pragma mark Scene Setup and Initialize

+(id) scene
{
	
	CCScene *scene = [CCScene node];
    scene.tag = kStoryPage;
	
	HUDLayer *hud = [HUDLayer node];
    [scene addChild:hud z:1];
    
    Scene06 *layer = [[Scene06 alloc] initWithHUD:hud];
	
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
        
        
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"HUDSPRITES12.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"HUDSPRITES12.plist"];
        [self addChild:_spriteSheet];
        
        readText = NO;
        
        //Consistent margin for game and device
        
        winSize = [CCDirector sharedDirector].winSize;
        Margin = winSize.width*.01;
        // CCLOG(@"luggage margin: %i ",  luggageMargin);
        
        
        
        
        //Set UP
        [self setUpMainScene];
        
        _story = [Words node];
        [self addChild:_story];
        [_story createWords:6];
        
        [_hud spawnMidGameMenu];
        [self setUpFooter];
        
        
        [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        
	}
	return self;
}

-(void)onEnterTransitionDidFinish{
     
    
    //Set UP
    [super onEnterTransitionDidFinish];
    id wait = [CCDelayTime actionWithDuration: 1 ];
    id wait2 = [CCDelayTime actionWithDuration: 1.5];
    id fadeIn = [CCFadeTo actionWithDuration:.25 opacity:255];
    
 
    
    
    //Liberty
    
    [_libery runAction:[CCSequence actions:wait,fadeIn, [CCCallFuncN actionWithTarget:self selector:@selector(playPopSound)], nil]];
    
    //museum

    
    [_museum runAction:[CCSequence actions:wait2,fadeIn, [CCCallFuncN actionWithTarget:self selector:@selector(playPopSound)], nil]];
    
    Swipeleft =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleViewsSwipeLeft:)];
    [Swipeleft setDirection: UISwipeGestureRecognizerDirectionLeft];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:Swipeleft];
    Swiperight =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleViewsSwipeRight:)];
    [Swiperight setDirection: UISwipeGestureRecognizerDirectionRight];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:Swiperight];
    
}

- (void)onExitTransitionDidStart{


    [_museum stopAllActions];
    [_libery stopAllActions];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
  
    [[[CCDirector sharedDirector]touchDispatcher] removeDelegate:self];
    
    
}



- (void)handleViewsSwipeLeft:(UISwipeGestureRecognizer *)gesture {
    if (readText == NO ) {
        
     
        [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
        [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
        [[SimpleAudioEngine sharedEngine] playEffect:@"pageTurn.mp3"];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:2.0 scene:[Scene07 scene] ]];
    }
    
}

- (void)handleViewsSwipeRight:(UISwipeGestureRecognizer *)gesture {
    
    if (readText == NO ) {
        
      
        [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
        [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionMoveInL transitionWithDuration:.5 scene:[Scene05 scene] ]];
    }
    
}

#pragma mark -
#pragma mark Audio

-(void)playPopSound {
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"shakerpop.mp3"];
    
}




#pragma mark -
#pragma mark Standard Scene Setup

- (void)setUpMainScene {

    //Liberty
    _libery  = [CCSprite spriteWithSpriteFrameName:@"liberty.png"];
    _libery.position = CGPointMake(winSize.width*.25,winSize.height*.45);
    _libery.opacity=0;
    
    [self addChild:_libery];
    
    //museum
    
    _museum  = [CCSprite spriteWithSpriteFrameName:@"museums.png"];
    _museum.position = CGPointMake(winSize.width*.7,winSize.height*.45);
    _museum.opacity=0;
    
    
    [self addChild:_museum];
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
            
            [_btnLeft runAction:fadeOut];
            [_btnRight runAction:fadeOut2];
            [_btnReadWords runAction:fadeOut3];
            [[SimpleAudioEngine sharedEngine] playEffect:@"pg06.mp3"];
            
        }];
        
        CCAction *soundStopped = [CCCallBlock actionWithBlock:^{
            
            readText = NO;
            [self removeChild:disableMenu cleanup:YES];
            [_hud spawnMidGameMenu];
            [_btnLeft runAction:fadeIn];
            [_btnRight runAction:fadeIn2];
            [_btnReadWords runAction:fadeIn3];
        }];
        
        
        [_background runAction:[CCSequence actions:wait, playSound,wait2,soundStopped, nil] ];
        
        
    }
    
}
- (void)setUpFooter
{

    _btnRight = [CCSprite spriteWithSpriteFrameName:@"next.png"];
    
    _btnRight.position = CGPointMake(winSize.width - _btnRight.contentSize.width/2 - Margin*2, _btnRight.contentSize.height/2 + Margin*2);
    
    
    [self addChild:_btnRight];
    
    
    
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
    
    
    if (CGRectContainsPoint(_btnRight.boundingBox, touchLocation)) {
        
        
     
        
        
        if (readText == NO) // do not turn page if reading
        {
            
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
            [[SimpleAudioEngine sharedEngine] playEffect:@"pageTurn.mp3"];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:2.0 scene:[Scene07 scene] ]];
        }
    }
    else if (CGRectContainsPoint(_btnLeft.boundingBox, touchLocation)) {
        
       
        
        if (readText == NO)
        {
            
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionMoveInL transitionWithDuration:.5 scene:[Scene05 scene] ]];
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
    else if (CGRectContainsPoint(_libery.boundingBox, touchLocation))
    {
       
        
        CCAction *sequence = [CCSequence actions:[CCRotateBy actionWithDuration:.25 angle:20], [CCRotateBy actionWithDuration:.25 angle:-40],[CCRotateTo actionWithDuration:.25 angle:0], nil];
        [_libery runAction:sequence];
        
        [self playPopSound];
    }
    else if (CGRectContainsPoint(_museum.boundingBox, touchLocation))
    {
       
        CCAction *sequence = [CCSequence actions:[CCRotateBy actionWithDuration:.25 angle:20], [CCRotateBy actionWithDuration:.25 angle:-40],[CCRotateTo actionWithDuration:.25 angle:0], nil];
        [_museum runAction:sequence];
        
        [self playPopSound];
    }
    
    
    
    
    return TRUE;
}


#pragma mark -
#pragma mark Game Loop




@end
