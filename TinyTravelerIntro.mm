

#import "TinyTravelerIntro.h"

#import "SimpleAudioEngine.h"

#import "NOscrollMainMenu.h"

#import "Background.h"

#import "AppDelegate.h"




@implementation TinyTravelerIntro
@synthesize iPad, device;

+(CCScene *) scene
{
	
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TinyTravelerIntro *layer = [TinyTravelerIntro node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)init {
    
    if( (self=[super init])) {
        
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        // Create our sprite sheets and frame cache
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"StoryTextTraveler3.plist"];
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"StoryTextTraveler3.pvr.ccz"];
        [self addChild:_spriteSheet];
        
        _spriteSheetHUD = [CCSpriteBatchNode batchNodeWithFile:@"HUDSPRITES12.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"HUDSPRITES12.plist"];
        [self addChild:_spriteSheetHUD];

        
        //Consistent margin for game and device
        NSString *traveler = [NSString stringWithFormat: @"traveler1_01.png"];
        CCMenuItemSprite *image = [CCSprite spriteWithSpriteFrameName:traveler];
        
        double myDouble = image.contentSize.height*.03125;
        Margin = (int)myDouble;
        
        SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
        gameData = [GameDataParser loadData];
        if (sae.isBackgroundMusicPlaying == NO && gameData.music == 1) {

            [[SimpleAudioEngine sharedEngine]
             playBackgroundMusic:@"quietLarkspur.mp3"];
        }
        
        self.iPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        
        if (self.iPad) {
            self.device = @"iPad";
        }
        else {
            self.device = @"iPhone";
        }
        
        _background = [Background node];
        [self addChild:_background];
        [_background createCity];

        [self spawnMusicNextMenu];
        
        [self spawnMainScene];
        
        [self spawnLanguage];
        
    }
    return self;
}

- (void)spawnMainScene
{
    [self spawnMainCharacters];
    
}

- (void)spawnMainCharacters
{
    int t1y =screenSize.width*.25;
    int t2y =screenSize.width*.75;
    int t3y =screenSize.width*.5;
   
   
    _traveler1  = [CCSprite spriteWithSpriteFrameName:@"traveler1_01.png"];
    int start = screenSize.height + _traveler1.contentSize.height/2;
    int finish = _traveler1.contentSize.height/2;
    _traveler1.position = CGPointMake(t1y, start);
    
    [self addChild:_traveler1];
    
    
    
    _traveler2  = [CCSprite spriteWithSpriteFrameName:@"traveler2_01.png"];
    _traveler2.position = CGPointMake(t2y,start);
    
    [self addChild:_traveler2];
    
    
    
    _traveler3  = [CCSprite spriteWithSpriteFrameName:@"traveler3_01.png"];
    _traveler3.position = CGPointMake(t3y, start);
    
    [self addChild:_traveler3];
    
    [_traveler1 runAction:[CCMoveTo actionWithDuration:1 position:ccp(t1y,finish)]];
    [_traveler2 runAction:[CCMoveTo actionWithDuration:1.5 position:ccp(t2y,finish)]];
    [_traveler3 runAction:[CCMoveTo actionWithDuration:1.75 position:ccp(t3y,finish)]];
    

    
   
    
    
    [self spawnMainCharactersAnimation];
}

- (void)spawnMainCharactersAnimation
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

- (void)spawnMusicNextMenu {
    
    _musicOn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"music-on.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"music-on-selected.gif"]];
    _musicOff = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"music-off.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"music-off-selected.gif"]];
    
    _nextButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"next.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"next-selected.gif"] target:self selector:@selector(nextTapped)];
    
    _nextButton.position = ccp(screenSize.width - _nextButton.contentSize.width - Margin*2,0);
 
    
    if (gameData.music == 0) {
        toggleMusicButton = [CCMenuItemToggle itemWithTarget:self
                                                    selector:@selector(musicTapped:) items:_musicOff, _musicOn, nil];
        
    }else {
        toggleMusicButton = [CCMenuItemToggle itemWithTarget:self
                                                    selector:@selector(musicTapped:) items:_musicOn, _musicOff, nil];
    }
    

    toggleMusicMenu = [CCMenu menuWithItems:toggleMusicButton, _nextButton, nil];

    
    toggleMusicMenu.position = ccp(Margin + _musicOn.contentSize.height/2, Margin + _musicOn.contentSize.height/2);
    [self addChild:toggleMusicMenu z:5];
    
   [toggleMusicMenu runAction:[CCSequence actions:[CCDelayTime actionWithDuration:12],[CCCallFuncN actionWithTarget:self selector:@selector(spawnParticleHighlight)],[CCDelayTime actionWithDuration:10],[CCCallFuncN actionWithTarget:self selector:@selector(nextTapped)], nil]];
    
}

-(void)nextTapped {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[NOscrollMainMenu scene] ]];
}

- (void)musicTapped:(id)sender {
   
    
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

- (void)spawnParticleHighlight  {
    
    CCParticleSystem *emitter_;
    emitter_ = [[CCParticleFlower alloc] initWithTotalParticles:50];
    [self addChild:emitter_ z:4];
    
    emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars.png"];
    emitter_.lifeVar = 0;
    emitter_.life = 3;
    emitter_.speed = 50;
    emitter_.speedVar = 0;
    emitter_.emissionRate = 10000;
    emitter_.position = ccp(screenSize.width - _nextButton.contentSize.width/2 - Margin, Margin + _musicOn.contentSize.height/2);
}
- (void) spawnLanguage {
    int fontSize;
    int shadowDistance;
    if (self.iPad) {
        fontSize = 38;
        shadowDistance = 3;
    }
    else {
        fontSize = 18;
        shadowDistance = 1;
    }
    CCLayer *layer = [[CCLayer alloc] init];

    CCLabelTTF *layerLabelShadow = [CCLabelTTF labelWithString:NSLocalizedString(@"IntroLine1", @"IntroLine1")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    layerLabelShadow.position =  ccp( screenSize.width / 2 -shadowDistance , screenSize.height*.9 -shadowDistance );
    layerLabelShadow.color = ccc3(0,0,0);
    [layer addChild:layerLabelShadow];
    
    
    
    
    CCLabelTTF *layerLabelShadow2 = [CCLabelTTF labelWithString:NSLocalizedString(@"IntroLine2", @"IntroLine2")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    layerLabelShadow2.position =  ccp( screenSize.width / 2-shadowDistance , screenSize.height*.8-shadowDistance  );
    layerLabelShadow2.color = ccc3(0,0,0);
    [layer addChild:layerLabelShadow2];
    
    
    
    
    CCLabelTTF *layerLabelShadow3 = [CCLabelTTF labelWithString:NSLocalizedString(@"IntroLine3", @"IntroLine3")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    layerLabelShadow3.position =  ccp( screenSize.width / 2-shadowDistance , screenSize.height*.7-shadowDistance );
    layerLabelShadow3.color = ccc3(0,0,0);
    [layer addChild:layerLabelShadow3];
    
    
    CCLabelTTF *layerLabel = [CCLabelTTF labelWithString:NSLocalizedString(@"IntroLine1", @"IntroLine1")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    layerLabel.position =  ccp( screenSize.width / 2, screenSize.height*.9 );
    layerLabel.color = ccc3(255,255,255);
    [layer addChild:layerLabel];
    

    
    
    CCLabelTTF *layerLabel2 = [CCLabelTTF labelWithString:NSLocalizedString(@"IntroLine2", @"IntroLine2")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    layerLabel2.position =  ccp( screenSize.width / 2 , screenSize.height*.8  );
    layerLabel2.color = ccc3(255,255,255);
    [layer addChild:layerLabel2];
    

    
    
    CCLabelTTF *layerLabel3 = [CCLabelTTF labelWithString:NSLocalizedString(@"IntroLine3", @"IntroLine3")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    layerLabel3.position =  ccp( screenSize.width / 2 , screenSize.height*.7 );
    layerLabel3.color = ccc3(255,255,255);
    [layer addChild:layerLabel3];
    
    [self addChild:layer];
}
- (void) onExitTransitionDidStart {
    [[[CCDirector sharedDirector]touchDispatcher] removeDelegate:self];

}
- (void) onExit {
    [self removeAllChildrenWithCleanup:YES];
    
}
@end