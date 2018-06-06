

#import "Scene01.h"
#import "Scene00.h"
#import "Scene02.h"

#import "sceneTag.h"
#import "LevelSelect.h"
#import "GameData.h"
#import "GameDataParser.h"


@implementation Scene01
{
    
   
    CCSprite *_btnLeft;
    CCSprite *_btnRight;
    CCSprite *_btnReadWords;
    
    CCSprite *_traveler1;
    CCSprite *_traveler2;
    CCSprite *_traveler3;
    
    CGPoint _touchPoint;
    UISwipeGestureRecognizer *Swipeleft;
    UISwipeGestureRecognizer *Swiperight;
   
}

#pragma mark -
#pragma mark Scene Setup and Initialize

+(id) scene
{
	
	CCScene *scene = [CCScene node];
    scene.tag = kStoryPage;
	
	HUDLayer *hud = [HUDLayer node];
    [scene addChild:hud z:1];
    
    Scene01 *layer = [[Scene01 alloc] initWithHUD:hud];
	
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
        
        [self setUpMainScene];
        
        _story = [Words node];
        [self addChild:_story];
        [_story createWords:1];
    
        [_hud spawnMidGameMenu];
        
        [self setUpFooter];
        
        
        [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        
	}
	return self;
}

-(void)onEnterTransitionDidFinish{
    
    [super onEnterTransitionDidFinish];
    
    Swipeleft =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleViewsSwipeLeft:)];
    [Swipeleft setDirection: UISwipeGestureRecognizerDirectionLeft];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:Swipeleft];
    Swiperight =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleViewsSwipeRight:)];
    [Swiperight setDirection: UISwipeGestureRecognizerDirectionRight];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:Swiperight];
    
}



- (void)onExitTransitionDidStart{
   
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];

    [[[CCDirector sharedDirector]touchDispatcher] removeDelegate:self];
    
}



- (void)handleViewsSwipeLeft:(UISwipeGestureRecognizer *)gesture {
     if (readText == NO ) {
    


         [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
         [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
         [[SimpleAudioEngine sharedEngine] playEffect:@"pageTurn.mp3"];
         [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1.0 scene:[Scene02 scene] ]];
    
     }
    
}

- (void)handleViewsSwipeRight:(UISwipeGestureRecognizer *)gesture {
    
    if (readText == NO ) {
        

        [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
        [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionMoveInL transitionWithDuration:.5 scene:[Scene00 scene] ]];
    }
    
}



#pragma mark -
#pragma mark Standard Scene Setup


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
            [[SimpleAudioEngine sharedEngine] playEffect:@"pg01.mp3"];

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
#pragma mark Additional Scene Setup (sprites and such)

- (void)setUpMainScene
{
    [self setUpMainCharacters];
  
}

- (void)setUpMainCharacters
{

    _traveler1  = [CCSprite spriteWithSpriteFrameName:@"traveler1_01.png"];
    _traveler1.position = CGPointMake(winSize.width*.2, Margin*1.9+_traveler1.contentSize.height/2);
    
    [self addChild:_traveler1];
     

    
    _traveler2  = [CCSprite spriteWithSpriteFrameName:@"traveler2_01.png"];
    _traveler2.position = CGPointMake(winSize.width*.75, Margin*1.9+_traveler2.contentSize.height/2);
    
     [self addChild:_traveler2];
     

    
    _traveler3  = [CCSprite spriteWithSpriteFrameName:@"traveler3_01.png"];
    _traveler3.position = CGPointMake(winSize.width*.5, Margin*1.9+_traveler3.contentSize.height/2);
    
     [self addChild:_traveler3];
     
    
    [self setUpMainCharactersAnimation];
}

- (void)setUpMainCharactersAnimation
{
   
    
    [self thirdGuy];

    [self schedule: @selector(firstGuy) interval: 15];
    [self schedule: @selector(secondGuy) interval: 20];
    [self schedule: @selector(thirdGuy) interval: 18];
    
}


- (void)firstGuy {
    
    float low_bound = 3;
    float high_bound = 6;
    float duration1 = (((float)arc4random()/0x100000000)*(high_bound-low_bound)+low_bound);
    
    NSMutableArray *texturesTraveler1 = [NSMutableArray arrayWithCapacity:3];
    for (int i = 1; i <= 3; i++)
    {

        [texturesTraveler1 addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"traveler1_0%d.png",i]]];
    }
    
    CCAnimation *blinkAnim1 = [CCAnimation
                               animationWithSpriteFrames:texturesTraveler1 delay:0.25];
    CCAnimate *blink1 = [CCAnimate actionWithAnimation:blinkAnim1];
    CCAction *wait1 = [CCDelayTime actionWithDuration:duration1];

    CCAction *mainCharacter1Animation = [CCSequence actions: blink1, wait1, blink1, blink1, wait1, blink1, blink1, nil];
    [_traveler1 runAction:mainCharacter1Animation];
    
}

- (void)secondGuy {
    
    float low_bound = 3;
    float high_bound = 6;
    float duration1 = (((float)arc4random()/0x100000000)*(high_bound-low_bound)+low_bound);
    
    NSMutableArray *texturesTraveler1 = [NSMutableArray arrayWithCapacity:3];
    for (int i = 1; i <= 3; i++)
    {
        
        [texturesTraveler1 addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"traveler2_0%d.png",i]]];
    }
    
    CCAnimation *blinkAnim1 = [CCAnimation
                               animationWithSpriteFrames:texturesTraveler1 delay:0.25];
    CCAnimate *blink1 = [CCAnimate actionWithAnimation:blinkAnim1];
    CCAction *wait1 = [CCDelayTime actionWithDuration:duration1];
    
    CCAction *mainCharacter1Animation = [CCSequence actions: blink1, wait1, blink1, blink1, wait1, blink1, blink1, nil];
    [_traveler2 runAction:mainCharacter1Animation];
    
}

- (void)thirdGuy {
    
    float low_bound = 3;
    float high_bound = 6;
    float duration1 = (((float)arc4random()/0x100000000)*(high_bound-low_bound)+low_bound);
    
    NSMutableArray *texturesTraveler1 = [NSMutableArray arrayWithCapacity:3];
    for (int i = 1; i <= 3; i++)
    {
        
        [texturesTraveler1 addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"traveler3_0%d.png",i]]];
    }
    
    CCAnimation *blinkAnim1 = [CCAnimation
                               animationWithSpriteFrames:texturesTraveler1 delay:0.25];
    CCAnimate *blink1 = [CCAnimate actionWithAnimation:blinkAnim1];
    CCAction *wait1 = [CCDelayTime actionWithDuration:duration1];
    
    CCAction *mainCharacter1Animation = [CCSequence actions: blink1, wait1, blink1, blink1, wait1, blink1, blink1, nil];
    [_traveler3 runAction:mainCharacter1Animation];
    
}


#pragma mark -
#pragma mark Code For Sound & Ambiance



#pragma mark -
#pragma mark Touch Events

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {



        CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
        

    if (CGRectContainsPoint(_btnRight.boundingBox, touchLocation)) {
    
        
      
            
      // NSLog(@"go forward");
        if (readText == NO) // do not turn page if reading
            {
              //NSLog(@"go forward for real");
                [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
                [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
                [[SimpleAudioEngine sharedEngine] playEffect:@"pageTurn.mp3"];
                 [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1.0 scene:[Scene02 scene] ]];
            }
        }
        else if (CGRectContainsPoint(_btnLeft.boundingBox, touchLocation)) {
        
    
           // NSLog(@"go backwards");

            if (readText == NO)
            {
            // NSLog(@"go backwards for reals");
               [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swiperight];
                [[[CCDirector sharedDirector] view] removeGestureRecognizer:Swipeleft];
                  [[CCDirector sharedDirector] replaceScene:[CCTransitionMoveInL transitionWithDuration:1.0 scene:[Scene00 scene] ]];
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
            

            
            [[SimpleAudioEngine sharedEngine] playEffect:@"shakerpop.mp3"];
            id actionMoveDown = [CCMoveTo actionWithDuration:.25 position:ccp(winSize.width*.2, winSize.height*.4)];
            id actionMoveUpFast = [CCMoveTo actionWithDuration: .25 position:ccp(winSize.width*.2, Margin*1.9+_traveler1.contentSize.height/2)];
            
            [_traveler1 runAction:[CCSequence actions: actionMoveDown, actionMoveUpFast, nil]];
            
            
         
            
        }
        else if (CGRectContainsPoint(_traveler2.boundingBox, touchLocation)) {
            
         
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"shakerpop.mp3"];
            id actionMoveDown = [CCMoveTo actionWithDuration:.25 position:ccp(winSize.width*.75, winSize.height*.4)];
            id actionMoveUpFast = [CCMoveTo actionWithDuration: .25 position:ccp(winSize.width*.75, Margin*1.9+_traveler1.contentSize.height/2)];
            
            [_traveler2 runAction:[CCSequence actions: actionMoveDown, actionMoveUpFast, nil]];
            
            
            
            
            
            
        }
        else if (CGRectContainsPoint(_traveler3.boundingBox, touchLocation)) {
            
   
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"shakerpop.mp3"];
            id actionMoveDown = [CCMoveTo actionWithDuration:.25 position:ccp(winSize.width*.5, winSize.height*.4)];
            id actionMoveUpFast = [CCMoveTo actionWithDuration: .25 position:ccp(winSize.width*.5, Margin*1.9+_traveler1.contentSize.height/2)];
            
            [_traveler3 runAction:[CCSequence actions: actionMoveDown, actionMoveUpFast, nil]];
            
            
            
            
            
            
        }
            
    
  
    
     return TRUE;
}



@end
