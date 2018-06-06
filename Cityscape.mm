//


//
//  Created by Catherine Cavanagh on 2/27/14.
//  Copyright Catherine Cavanagh 2014. All rights reserved.
//

// Import the interfaces
#import "Cityscape.h"
#import "sceneTag.h"
#import "Level.h"
#import "Levels.h"
#import "LevelParser.h"
#import "GameData.h"
#import "GameDataParser.h"
#import "SimpleAudioEngine.h"

// Not included in "cocos2d.h"
#import "CCPhysicsSprite.h"





@implementation Cityscape
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    scene.tag = kSceneCityscape;
	
	// 'layer' is an autorelease object.
	//Cityscape *layer = [Cityscape node];
    
    HUDLayer *hud = [HUDLayer node];
    [scene addChild:hud z:1];
    
    Cityscape *layer = [[Cityscape alloc] initWithHUD:hud];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)initWithHUD:(HUDLayer *)hud
{
	if( (self=[super init])) {
        
         _hud = hud;
        
        // Create our HUD sprite sheet and frame cache
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"HUDSPRITES12.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"HUDSPRITES12.plist"];
        [self addChild:_spriteSheet];
        
        _cityscapeSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"AMAZEME.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"AMAZEME.plist"];
        [self addChild:_cityscapeSpriteSheet];
        
        [self setAccelerometerEnabled:YES];
        
        [_hud spawnMidGameMenu];
        
        n = arc4random() % 3 +1;
        
        _foodItem = @"pizza.png";
        
        pizzaTag = 2;
        allThePizzas = [[NSMutableArray alloc] init];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        GameData *gameData = [GameDataParser loadData];
        gameData.selectedLevel = 1;
        [GameDataParser saveData:gameData];
      
        
        // Create a world
        b2Vec2 gravity = b2Vec2(0.0f, -8.0f);

        _world = new b2World(gravity);
        
        _world->SetAllowSleeping(false);
        
        //b2Vec2 gravity= b2Vec2(0.0f, -8.0f); //normal earth gravity, 9.8 m/s/s straight down!
       // bool doSleep = false;
        
        //_world = new b2World(gravity, doSleep);

        
        
        
        // Create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        
        groundBody = _world->CreateBody(&groundBodyDef);
        b2EdgeShape groundEdge;
        b2FixtureDef boxShapeDef;
        boxShapeDef.shape = &groundEdge;
        
        //wall definitions
        groundEdge.Set(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
        
        groundEdge.Set(b2Vec2(0,0), b2Vec2(0,winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        
        groundEdge.Set(b2Vec2(0, winSize.height/PTM_RATIO),
                       b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        
        groundEdge.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO),
                       b2Vec2(winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
        
        NSString *background = [NSString stringWithFormat:@"timesquare_bak.jpg"];
        
        //Create Large Image
        CCSprite *Bg = [CCSprite spriteWithFile:background];
        
        
        Bg.position = ccp(winSize.width/2 , winSize.height/2);
        [self addChild:Bg];
        
        [self spawnPizzaEater];
        [self spawnFoodMenu];
        
        
        _storeClosed = YES;
        
        
        // Create contact listener
        _contactListener = new MyContactListener();
        _world->SetContactListener(_contactListener);
        
        _motionManager = [[CMMotionManager alloc] init];
        [self startMyMotionDetect];

        
        [self schedule:@selector(tick:)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeStore:)
                                                     name:@"RemoveStore"
                                                   object:nil];
        
         [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
      
       
    }
    
	return self;
}

- (void)onExitTransitionDidStart{
    
    [[[CCDirector sharedDirector]touchDispatcher] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_motionManager stopAccelerometerUpdates];
    
    
}

-(void)onExit{
    foodMenu.enabled=NO;
    [self removeAllChildrenWithCleanup:YES];
    
}

- (void)startMyMotionDetect
{
    
    //NSLog(@"active %d",_motionManager.accelerometerActive);
    
    //NSLog(@"availabilty %d",_motionManager.accelerometerAvailable);
    
    
    
    [_motionManager
     startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMAccelerometerData *data, NSError *error)
     {
         
          b2Vec2 gravity(_motionManager.accelerometerData.acceleration.y * 30, -_motionManager.accelerometerData.acceleration.x * 30);
         _world->SetGravity(gravity);
         
         
     }];
}


- (void)tick:(ccTime) dt {
   
    _world->Step(dt, 10, 10);
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *ballData = (__bridge CCSprite *)b->GetUserData();
            ballData.position = ccp(b->GetPosition().x * PTM_RATIO,
                                    b->GetPosition().y * PTM_RATIO);
            ballData.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
    
    
    //check contacts
    std::vector<b2Body *>toDestroy;
    std::vector<MyContact>::iterator pos;
    for (pos=_contactListener->_contacts.begin();
         pos != _contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            CCSprite *spriteA = (__bridge CCSprite *) bodyA->GetUserData();
            CCSprite *spriteB = (__bridge CCSprite *) bodyB->GetUserData();
            
            //Sprite A = ball, Sprite B = Block
            if (spriteA.tag == 1 && spriteB.tag == 2) {
                
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) {
                    toDestroy.push_back(bodyB);
                     [[SimpleAudioEngine sharedEngine] playEffect:@"eat.mp3"];
                    [Guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%ldtt_anim5.png", (long)n]]];
                }
            }
            
            //Sprite A = block, Sprite B = ball
            else if (spriteA.tag == 2 && spriteB.tag == 1) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                    [[SimpleAudioEngine sharedEngine] playEffect:@"eat.mp3"];
                    [Guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%ldtt_anim5.png", (long)n]]];
                }
            }
        }
    }
    
    std::vector<b2Body *>::iterator pos2;
    for (pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
        b2Body *body = *pos2;
        if (body->GetUserData() != NULL) {
            CCSprite *sprite = (__bridge CCSprite *) body->GetUserData();
            [self removeChild:sprite cleanup:YES];
            [allThePizzas removeObject:sprite];
        }
        _world->DestroyBody(body);
    }
    
}



 - (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {

 return TRUE;
 
 }
 


-(void) addNewSpriteAtPosition:(CGPoint)p
{
    
  
    // Create sprite and add it to the layer
   // _ball = [CCSprite spriteWithFile:@"pizza-100.png" rect:CGRectMake(0, 0, 52, 52)];
    //_ball = [CCSprite spriteWithSpriteFrameName:@"pizza.png"];
    _ball = [CCSprite spriteWithSpriteFrameName:_foodItem];
   // NSLog(@"food item: %@",_foodItem);
    _ball.position = ccp(p.x, p.y);
    [self addChild:_ball];
    _ball.tag = pizzaTag;
    
    [allThePizzas addObject:_ball];
    
    
    // Create ball body and shape
    b2BodyDef ballBodyDef;
    ballBodyDef.type = b2_dynamicBody;
    ballBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    ballBodyDef.userData = (__bridge void*) _ball;
    _body = _world->CreateBody(&ballBodyDef);
    
    b2CircleShape circle;
    circle.m_radius = 26.0/PTM_RATIO;
    
    b2FixtureDef ballShapeDef;
    ballShapeDef.shape = &circle;
    ballShapeDef.density = 1.0f;
    ballShapeDef.friction = 0.2f;
    ballShapeDef.restitution = 0.8f;
    _body->CreateFixture(&ballShapeDef);
    
	//CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);

    
}


-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{

		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
 
    if (allThePizzas.count < 25){
		[self addNewSpriteAtPosition: location];
    }
   
}

/*- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
 // Landscape left values
    b2Vec2 gravity(acceleration.y * 30, -acceleration.x * 30);
    _world->SetGravity(gravity);

}*/

- (void)pizzaTapped {
   // NSLog(@"pizza");
    _foodItem = @"pizza.png";
    [[SimpleAudioEngine sharedEngine] playEffect:@"yay.mp3"];
}
- (void)hotdogTapped {
     //NSLog(@"coffee");
     _foodItem = @"hotdog.png";
     [[SimpleAudioEngine sharedEngine] playEffect:@"yay.mp3"];
}
- (void)bagelTapped {
    // NSLog(@"bagel");
    _foodItem = @"bagel.png";
     [[SimpleAudioEngine sharedEngine] playEffect:@"yay.mp3"];
}

- (void)spawnFoodMenu {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    CCLayerColor *_foodShadowLayer;
    //Add shadow
    
    _foodShadowLayer = [CCLayerColor layerWithColor: ccc4(0,0,0, 100)];
    [_foodShadowLayer setContentSize: CGSizeMake(winSize.width*.1, winSize.height*.6)];
    
    
    _foodShadowLayer.position = ccp(winSize.width * 0.02, winSize.height*.2);
    [self addChild: _foodShadowLayer z:25];
    
    
    //Create Menu
 
    CCMenuItemSprite *pizzaButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pizza.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pizza_dark.png"] target:self selector:@selector(pizzaTapped)];
    CCMenuItemSprite *hotdogButton;
    CCMenuItemSprite *bagelButton;
    
#ifdef FREE
    
    hotdogButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"hotdog.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"hotdog_dark.png"] target:self selector:@selector(hotdogTapped)];
    bagelButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"bagel.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"bagel_dark.png"]target:self selector:@selector(bagelTapped)];
    
#else
    
     allPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:@"com.biggiebangle.tinytravelersnyc.complete"];
    
    if (allPurchased){
        hotdogButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"hotdog.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"hotdog_dark.png"] target:self selector:@selector(hotdogTapped)];
        bagelButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"bagel.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"bagel_dark.png"]target:self selector:@selector(bagelTapped)];
        
    }else {
       hotdogButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"hotdog_dark.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"hotdog_dark.png"] target:self selector:@selector(openStore:)];
        bagelButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"bagel_dark.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"bagel_dark.png"]target:self selector:@selector(openStore:)];
        
    }

#endif
    pizzaButton.scale = .8;
    hotdogButton.scale = .8;
    bagelButton.scale = .8;
    
    
    pizzaButton.position = ccp(winSize.width * 0.05, winSize.height*.5);
    hotdogButton.position = ccp(winSize.width *  0.05, winSize.height*.3);
    bagelButton.position = ccp(winSize.width *  0.045, winSize.height*.1);
    foodMenu = [CCMenu menuWithItems:pizzaButton, hotdogButton, bagelButton, nil];
    foodMenu.position = CGPointZero;
    
    //Add shadow and then animate onto the screen
    [_foodShadowLayer addChild:foodMenu];
}

- (void)spawnPizzaEater {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    pizzaGuyAnimFrames = [NSMutableArray array];
    for (int i=1; i<=4; i++) {
        [pizzaGuyAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"%ldtt_anim%d.png",(long)n,i]]];
    }
    
    
    //Add the body
    NSString *guyBody = [NSString stringWithFormat:@"%ldtt_anim3.png", (long)n];
    Guy = [CCSprite spriteWithSpriteFrameName:guyBody];
    Guy.position = ccp(winSize.width/2, winSize.height*.2);
    Guy.opacity = 0;
    Guy.scale = 2;
    Guy.tag = 15;
    [self addChild:Guy];
    id scaleAction1 = [CCScaleTo actionWithDuration:1 scale:.5];
    id easeAction2 = [CCEaseBounceOut actionWithAction:scaleAction1];
    
    //Animate the Guy
    CCAnimation *pizzaGuyAnim = [CCAnimation
                                 animationWithSpriteFrames:pizzaGuyAnimFrames delay:0.5f];
    CCAnimate *pizzaGuyAnimate = [CCAnimate actionWithAnimation:pizzaGuyAnim];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:pizzaGuyAnimate];
    
    [Guy runAction:[CCSequence actions:[CCFadeIn actionWithDuration:0.25],easeAction2, nil]];
    [Guy runAction:repeat];

    
    //Add the smile
    CCSprite *pizzaEater = [CCSprite spriteWithSpriteFrameName:@"1tt_anim0.png"];
    pizzaEater.position = ccp(winSize.width/2, winSize.height*.2);
    pizzaEater.opacity = 0;
    pizzaEater.tag = 1;
    [self addChild:pizzaEater];

  
    
    // Create pizzaEater body
    b2BodyDef pizzaEaterBodyDef;
   // pizzaEaterBodyDef.type = b2_dynamicBody;
    pizzaEaterBodyDef.type = b2_staticBody;
    pizzaEaterBodyDef.position.Set(winSize.width/2/PTM_RATIO, (pizzaEater.contentSize.height/2 + winSize.height*.2)/PTM_RATIO);
    pizzaEaterBodyDef.userData = (__bridge void*)pizzaEater;
    _pizzaEaterBody = _world->CreateBody(&pizzaEaterBodyDef);
    
    // Create pizzaEater shape
    b2PolygonShape pizzaEaterShape;
   pizzaEaterShape.SetAsBox(pizzaEater.contentSize.width/PTM_RATIO/2,
                         pizzaEater.contentSize.height/PTM_RATIO/2);
    
    // Create shape definition and add to body
    b2FixtureDef pizzaEaterShapeDef;
    pizzaEaterShapeDef.shape = &pizzaEaterShape;
    pizzaEaterShapeDef.density = 10.0f;
    pizzaEaterShapeDef.friction = 0.4f;
    pizzaEaterShapeDef.restitution = 0.1f;
    _pizzaEaterFixture = _pizzaEaterBody->CreateFixture(&pizzaEaterShapeDef);
    
}

- (void)openStore:(id)sender {
    
     NSLog(@"open store called");
    
    if (_storeClosed == YES){
        NSLog(@"store is opened YES");
        _store = [Store node];
        [self addChild:_store ];
        _store.position = ccp(0,0);
        _storeClosed = NO;
    }
    
}


- (void)removeStore:(NSNotification *) notification {
    NSLog(@"exiting notification");
    if ([[notification name] isEqualToString:@"RemoveStore"]){
        NSLog(@"exiting notification received");
        [self removeChild:_store cleanup:YES];
        
        _storeClosed = YES;
        
        allPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:@"com.biggiebangle.tinytravelersnyc.complete"];
        
        if (allPurchased) {
         
                [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[Cityscape scene] ]];
           
        }
    }
}

@end
