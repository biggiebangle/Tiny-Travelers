//
//  Store.m
//  dkta
//
//  Created by Catherine Cavanagh on 3/14/14.
//  Copyright 2014 Catherine Cavanagh. All rights reserved.
//

#import "Store.h"
#import "SimpleAudioEngine.h"
#import "TTIAPHelper.h"
#import <StoreKit/StoreKit.h>


@interface Store () {
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
}
@end

@implementation Store
@synthesize iPad, device;

#pragma mark Scene Setup and Initialize
- (id)init {
    CCLOG(@"INIT");
    if( (self=[super init])) {
        
       
        screenSize = [CCDirector sharedDirector].winSize;
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
      
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"MENU25.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"MENU25.plist"];
        [self addChild:_spriteSheet];
        
        _spriteSheetStore = [CCSpriteBatchNode batchNodeWithFile:@"store2.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"store2.plist"];
        [self addChild:_spriteSheetStore];
        
        //Arrays for Collision Detection
        boundingBoxes = [[NSMutableArray alloc] init];
        movableThumbs = [[NSMutableArray alloc] init];
        answers =       [[NSMutableArray alloc] init];
        
        //Consistent margin for game and device
        NSString *menuItem = [NSString stringWithFormat: @"1Game.png"];
        CCSprite *image = [CCSprite spriteWithSpriteFrameName:menuItem];
        
        double myDouble = image.contentSize.height*.03125;
        menuMargin = (int)myDouble;
        
        self.iPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        
        if (self.iPad) {
            self.device = @"iPad";
        }
        else {
            self.device = @"iPhone";
        }
        
        _background = [Background node];
        _background.scale = .75;
        _background.position = ccp(screenSize.width/8, screenSize.height);
        [self addChild:_background];
        [_background createBackgroundWithNoise];
        id moveAction = [CCMoveTo actionWithDuration:1 position:ccp(screenSize.width/8, screenSize.height/8)];
        id easeAction = [CCEaseBounceOut actionWithAction:moveAction];
        [_background runAction:easeAction];
        
        //Add x out image
        _exitButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"exit.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"exit-selected.png"] target:self selector:@selector(closeStore)];
        _exitButton.scale = 2;
        _exitMenu = [CCMenu menuWithItems:_exitButton, nil];
        _exitMenu.position = ccp(screenSize.width - _exitButton.contentSize.width/8, screenSize.height - _exitButton.contentSize.height/8);
       
        
      
        emitter_ = [[CCParticleFlower alloc] initWithTotalParticles:50];
        [_background addChild:emitter_ z:99];
        
        emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars.png"];
        emitter_.lifeVar = 0;
        emitter_.life = 6;
        emitter_.speed = 50;
        emitter_.speedVar = 0;
        emitter_.emissionRate = 30000;
        emitter_.position = ccp(screenSize.width - _exitButton.contentSize.width/8, screenSize.height - _exitButton.contentSize.height/8);
        
        [_background addChild:_exitMenu z:100];
        
        //Add Restore
        CCMenuItemFont *_restoreButton = [CCMenuItemFont itemWithString:NSLocalizedString(@"restore", @"restore") target:self selector:@selector(restoreTapped:)];
        
        [_restoreButton setFontSize:22];
        [_restoreButton setFontName:NSLocalizedString(@"fontName", @"name of font")];

        _restoreMenu = [CCMenu menuWithItems:_restoreButton, nil];

        _restoreMenu.position = ccp(screenSize.width*.85,screenSize.height*.1);

       
        _restoreMenu.opacity = 0;
        
        [_background addChild:_restoreMenu];
        
        [_restoreMenu runAction:[CCFadeIn actionWithDuration:1]];
        

        
        purchaseItem = [self layerWithPurchaseNameDefault];
        [_background addChild:purchaseItem];

       
        

        //Add the purchase items
        [[TTIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {

            if (success) {
                CCLOG(@"ADDING PRODUCT");
                _products = products;
                for (SKProduct *product in _products) {
                    
                    [_background removeChildByTag:88 cleanup:YES];
                   
                    CCLOG(@"product title %@", product.localizedTitle);
                    purchaseItem = [self layerWithPurchaseName:product.localizedTitle idx:(int)[_products indexOfObject:product]purchaseIdentifier:product.productIdentifier purchasePrice:product.price locale:product.priceLocale];
                    [_background addChild:purchaseItem];
                }
            }
            else {
                int fontSize;
                if (self.iPad) {
                    fontSize = 50;
                }
                else {
                    fontSize = 18;
                }
                
                CCLabelTTF *layerLabel = [CCLabelTTF labelWithString:NSLocalizedString(@"unable", @"not connected")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
                layerLabel.color = ccc3(255,255,255);
                layerLabel.position = ccp(screenSize.width/2, 0+menuMargin*10);
                //layerLabel.tag = 88;
                [_background addChild:layerLabel];
              
               
            }

            
        }];
        
        //Childgate
        childGateON = true;
        numberOfGates = 0;




        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];


        
    }
    return self;
}


#pragma mark Access Apple Store

- (void)restoreTapped:(id)sender {
    [[TTIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (CCLayer*)layerWithPurchaseNameDefault{
    
    CCLayer *layer = [[CCLayer alloc] init];
    layer.tag = 88;
    
    int fontSize;
    int buyFontSize;
    if (self.iPad) {
        fontSize = 50;
        buyFontSize = 60;
        
    }
    else {
        
        fontSize = 18;
        buyFontSize = 24;
    }
    
    CCLabelTTF *layerLabel = [CCLabelTTF labelWithString:NSLocalizedString(@"appTitle", @"appTitle") fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    layerLabel.color = ccc3(255,255,255);
    
    
    
    NSString *imageName = [NSString stringWithFormat: @"%dInAppPurchase.png", 1];
    
    CCSprite *image = [CCSprite spriteWithSpriteFrameName:imageName];

    
    layerLabel.position =  ccp( screenSize.width*.5 , screenSize.height *.6 - image.contentSize.height/2 - menuMargin );

    image.position = ccp(screenSize.width*.5 , screenSize.height*.6);
     
    [layer addChild: image];

    [layer addChild:layerLabel];

    
    return layer;
}




- (CCLayer*)layerWithPurchaseName:(NSString *)purchaseName
                                     idx:(int)idx
                      purchaseIdentifier:(NSString *)purchaseIdentifier
                           purchasePrice:(NSNumber *)purchasePrice
                                  locale:(NSLocale *)locale{
    CCLOG(@"creating layer %i", idx);
    CCLayer *layer = [[CCLayer alloc] init];
    layer.tag = idx;
    
    int fontSize;
    int buyFontSize;
    if (self.iPad) {
        fontSize = 50;
        buyFontSize = 60;
        
    }
    else {
        
        fontSize = 18;
        buyFontSize = 24;
    }
    
    CCLabelTTF *layerLabel = [CCLabelTTF labelWithString:NSLocalizedString(@"appTitle", @"appTitle")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    layerLabel.color = ccc3(255,255,255);
    
    [_priceFormatter setLocale:locale];
    CCLabelTTF *layerPrice = [CCLabelTTF labelWithString:[_priceFormatter stringFromNumber:purchasePrice] fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    layerPrice.color = ccc3(255,255,255);
    
    
    //NSString *imageName = [NSString stringWithFormat: @"%dInAppPurchase.png", idx+1];
    NSString *imageName = [NSString stringWithFormat: @"%dInAppPurchase.png", 1];
    
    CCSprite *imageSprite = [CCSprite spriteWithSpriteFrameName:imageName];
    NSString *checkMarkName = [NSString stringWithFormat: @"check.png"];
    CCSprite *checkMark = [CCSprite spriteWithSpriteFrameName:checkMarkName];
    
    imageButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:imageName] selectedSprite:[CCSprite spriteWithSpriteFrameName:imageName] target:self selector:@selector(onSelectPurchase:)];
    imageMenu = [CCMenu menuWithItems:imageButton, nil];
    imageButton.tag = idx;
    imageMenu.tag = 105;
    
    CCMenuItemFont *buyButton = [CCMenuItemFont itemWithString:NSLocalizedString(@"buy", @"buy") target:self selector:@selector(onSelectPurchase:)];
    [buyButton setFontSize:buyFontSize];
    [buyButton setFontName:NSLocalizedString(@"fontName", @"name of font") ];
    
    
    buyMenu = [CCMenu menuWithItems:buyButton, nil];
    buyButton.tag = idx;
    buyMenu.tag = 107;
    
    
    layerLabel.position =  ccp( screenSize.width*.5 , screenSize.height *.6 - imageSprite.contentSize.height/2 - menuMargin );
    layerPrice.position =  ccp( screenSize.width*.5 , screenSize.height *.6 - imageSprite.contentSize.height/2 - menuMargin*5);
    
    if ([[TTIAPHelper sharedInstance] productPurchased:purchaseIdentifier]) {

        imageSprite.position = ccp(screenSize.width*.5 , screenSize.height*.6);
        checkMark.position = ccp(screenSize.width*.5 , screenSize.height *.6 - imageSprite.contentSize.height/2 - menuMargin*9);
        [_background addChild: imageSprite];
        [_background addChild:checkMark];
    }
    else {
       
        imageMenu.position = ccp(screenSize.width*.5 , screenSize.height*.6);
        buyMenu.position = ccp(screenSize.width*.5 , screenSize.height *.6 - imageSprite.contentSize.height/2 - menuMargin*9);
        [_background addChild: imageMenu];
        [_background addChild:buyMenu];

    }
    
    [layer addChild:layerLabel];
    [layer addChild:layerPrice];
    
    return layer;
}


- (void)productPurchased:(NSNotification *)notification {
    CCLOG(@"Is this where it happens?");
    //[_background removeChildByTag:88 cleanup:YES];
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        
        
        
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            
            [_background removeChildByTag:107 cleanup:YES];
            [_background removeChildByTag:105 cleanup:YES];
            
            
            purchaseItem = [self layerWithPurchaseName:product.localizedTitle idx:(int)[_products indexOfObject:product]purchaseIdentifier:product.productIdentifier purchasePrice:product.price locale:product.priceLocale];
            [_background addChild:purchaseItem];
            
            *stop = YES;
            
        }
    }];
    
}




#pragma mark -
#pragma mark Switch
- (void)onSelectPurchase:(CCMenuItemImage *)sender {
    
    if (childGateON == false) {
        CCLOG(@"here");
        SKProduct *product = _products[sender.tag];
        CCLOG(@"here!!");
        [[TTIAPHelper sharedInstance] buyProduct:product];
    }else if (childGateON == true && numberOfGates == 0){
        
        numberOfGates++;

        [self addGate];
        
        }

}

#pragma mark -
#pragma mark Touch Events
-(void)selectSpriteForTouch:(CGPoint)touchLocation {
    

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
            

            selSprite = newSprite;
            
        }

}

- (void)panForTranslation:(CGPoint)translation {
    

        if (selSprite) {
            
            CGPoint newPos = ccpAdd(selSprite.position, translation);
            selSprite.position = newPos;
            
            
        } else {
            
        }

}
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {

    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self selectSpriteForTouch:touchLocation];
    
    
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
    
  //  NSLog(@"current tag %i", selSprite.tag);
       // NSLog(@"current index %i", currentProblemIndex);
        [self matchCheck];
    
        selSprite = nil;
    
    
}


//Game Logic
- (void)matchCheck {
    

    
    for (CCSprite *movableThumb in movableThumbs) {
        
        for (CCSprite *boundingBox in boundingBoxes) {
            
            if (CGRectIntersectsRect(movableThumb.boundingBox, boundingBox.boundingBox)) {
                
                
                int thumbTag = (int)movableThumb.tag;
                int boundingBoxTag = (int)boundingBox.tag;
                if (thumbTag == boundingBoxTag){

                        
                        //CCLOG(@"MATCH: %i and %i",  boundingBoxTag, thumbTag);
                        
                        [movableThumb runAction: [CCMoveTo actionWithDuration:.25 position:ccp((boundingBox.position.x),(boundingBox.position.y))]];
                        [self closeGateKeepStore];
                        
                        
                    }else {
                        
                        [self closeStoreViaGate];
                        
                    }
            }
        }//boundingBox for
        
        
    }//movableThumbs for

}



#pragma mark Parental Gate


- (void)addGate {
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"whoa1.mp3"];
    
    [_background removeChild:emitter_ cleanup:YES];
    
    //background Layer
    _shadowLayer = [CCLayerColor layerWithColor: ccc4(0,0,0, 200)];
    
    [_shadowLayer setTouchPriority:(kCCMenuHandlerPriority-1)];
    
    [_restoreMenu setTouchPriority:kCCMenuHandlerPriority+1];

    
    [_shadowLayer setContentSize: CGSizeMake(screenSize.width, screenSize.height)];
    _shadowLayer.position = ccp(-screenSize.width, 0);
    //_shadowLayer.position = ccp(0, 0);
    [self addChild: _shadowLayer z:400];
    
    //Add x out image
    CCMenuItem *_exitGateButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"exit.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"exit-selected.png"] target:self selector:@selector(closeStoreViaGate)];
    _exitGateButton.scale = 2;
    CCMenu *_exitGateMenu = [CCMenu menuWithItems:_exitGateButton, nil];
    _exitGateMenu.position = ccp(screenSize.width - (_exitGateButton.contentSize.width + menuMargin), screenSize.height - (_exitGateButton.contentSize.height + menuMargin));

    
    [_shadowLayer addChild:_exitGateMenu z:200];
    
    NSString *stopHandName = [NSString stringWithFormat: @"stopHandGate.png"];
    CCSprite *stopHand = [CCSprite spriteWithSpriteFrameName:stopHandName];
    stopHand.position = ccp(screenSize.width*.4 , screenSize.height *.8);
    [_shadowLayer addChild:stopHand];
    
    NSString *parentandChildName = [NSString stringWithFormat: @"parentandChildGate.png"];
    CCSprite *parentandChild = [CCSprite spriteWithSpriteFrameName:parentandChildName];
    parentandChild.position = ccp(screenSize.width*.6 , screenSize.height *.8);
    [_shadowLayer addChild:parentandChild];
    
    int fontSize;
    if (self.iPad) {
        fontSize = 50;
    }
    else {
        fontSize = 18;
    }
    
    //Ask your parents.
    CCLabelTTF *parentGateLabel = [CCLabelTTF labelWithString:NSLocalizedString(@"parent", @"parents") fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    parentGateLabel.color = ccc3(255,255,255);
    parentGateLabel.position = ccp(screenSize.width/2, screenSize.height*.7);
    [_shadowLayer addChild:parentGateLabel];
    
    //To continue...
    CCLabelTTF *continueLabel = [CCLabelTTF labelWithString:NSLocalizedString(@"continue", @"continue") fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    continueLabel.color = ccc3(255,255,255);
    continueLabel.position = ccp(screenSize.width/2, screenSize.height*.5);

    [_shadowLayer addChild:continueLabel];
    
    //Math problem
    
    [self returnMathProblems];
    
    NSLog(@"Current Math problem: %@ + %@ = %@", currentMathProblem[@"first"], currentMathProblem[@"second"], currentMathProblem[@"answer"]);
    
    CCLabelTTF *firstLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", currentMathProblem[@"first"]] fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    firstLabel.color = ccc3(255,255,255);
    firstLabel.position = ccp(screenSize.width*.4, screenSize.height*.4);
    [_shadowLayer addChild:firstLabel];
    
    CCLabelTTF *plusLabel = [CCLabelTTF labelWithString:@"+" fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    plusLabel.color = ccc3(255,255,255);
    plusLabel.position = ccp(screenSize.width*.45, screenSize.height*.4);
    [_shadowLayer addChild:plusLabel];
    
    CCLabelTTF *secondLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", currentMathProblem[@"second"]] fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    secondLabel.color = ccc3(255,255,255);
    secondLabel.position = ccp(screenSize.width*.5, screenSize.height*.4);
    [_shadowLayer addChild:secondLabel];
    
    CCLabelTTF *equalLabel = [CCLabelTTF labelWithString:@"=" fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    equalLabel.color = ccc3(255,255,255);
    equalLabel.position = ccp(screenSize.width*.55, screenSize.height*.4);
    [_shadowLayer addChild:equalLabel];
    

    
    //Math text field
    [self spawnBoundingBox];
    
    //Answers
    [self spawnMathThumbs];
    
    
    
     [_shadowLayer runAction: [CCMoveTo actionWithDuration:.5 position:ccp(0,0)]];
}



- (void)spawnBoundingBox {
    
    
    //Create boundingBox sprite

    CCSprite *matchBox = [CCSprite spriteWithSpriteFrameName:@"_mathBackground.gif"];
    [matchBox setTag:currentProblemIndex];
    [boundingBoxes addObject:matchBox];
    matchBox.position = ccp(screenSize.width*.65, screenSize.height*.4);
    [_shadowLayer addChild:matchBox];
    
}

- (void)spawnMathThumbs {

    //Create thumb sprites
    int fontSize;
    if (self.iPad) {
        fontSize = 50;
    }
    else {
        fontSize = 18;
    }
   
    for(int i = 0; i < answers.count; ++i) {
        
        id currentAnswer = [answers objectAtIndex:i];

        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"_mathBackground.gif"];
    
        CCLabelTTF *mathAnswerLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", currentAnswer] fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
        mathAnswerLabel.color = ccc3(0,0,0);
        mathAnswerLabel.position = ccp(sprite.contentSize.height/2,sprite.contentSize.width/2);
        [sprite addChild:mathAnswerLabel];
        sprite.tag = i;
        [movableThumbs addObject:sprite];

    };
    
    

    
    //Shuffle objects before putting it on the screen
    NSUInteger totalCount = [movableThumbs count];
    for (NSUInteger i = 0; i < totalCount; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = totalCount - i;
        NSInteger n = (arc4random() % nElements) + i;
        [movableThumbs exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    

    
    NSArray *xCoordinateArray = [NSArray arrayWithObjects:
                                 [NSNumber numberWithInt:screenSize.width*.2],
                                 [NSNumber numberWithInt:screenSize.width*.4],
                                 [NSNumber numberWithInt:screenSize.width*.6],
                                 [NSNumber numberWithInt:screenSize.width*.8],nil];
    
    NSArray *actionWithDurationArray = [NSArray arrayWithObjects:
                                        [NSNumber numberWithInt:1.6],[NSNumber numberWithInt:1],[NSNumber numberWithInt:1.1],[NSNumber numberWithInt:1.5], nil];

    
    
    
    //Add to screen
    for (CCSprite *sprite in movableThumbs) {
        NSUInteger i = [movableThumbs indexOfObject:sprite];
        
        sprite.position = ccp(screenSize.width/2, screenSize.height/2);
        sprite.opacity = 0;
        
        [_shadowLayer addChild:sprite];
        int spriteX = [xCoordinateArray[i] intValue];

        id actionTo = [CCMoveTo actionWithDuration: [actionWithDurationArray[i] intValue] position:ccp(spriteX, screenSize.height*.2)];
        id fadeIn = [CCFadeIn actionWithDuration:.8];
        [sprite runAction:actionTo];
        [sprite runAction:fadeIn];
        
        
        
    }
    
    
}




-(void)returnMathProblems {
    problem0 = @{
                 @"first" : [NSNumber numberWithInt:11],
                 @"second" : [NSNumber numberWithInt:12],
                 @"answer" : [NSNumber numberWithInt:23],
                 };
    problem1 = @{
                 @"first" : [NSNumber numberWithInt:42],
                 @"second" : [NSNumber numberWithInt:8],
                 @"answer" : [NSNumber numberWithInt:50],
                 };
    problem2 = @{
                 @"first" : [NSNumber numberWithInt:23],
                 @"second" : [NSNumber numberWithInt:23],
                 @"answer" : [NSNumber numberWithInt:46],
                 };
    problem3 = @{
                 @"first" : [NSNumber numberWithInt:72],
                 @"second" : [NSNumber numberWithInt:12],
                 @"answer" : [NSNumber numberWithInt:84],
                 };

    [answers addObject:[NSNumber numberWithInt:23]];
    [answers addObject:[NSNumber numberWithInt:50]];
    [answers addObject:[NSNumber numberWithInt:46]];
    [answers addObject:[NSNumber numberWithInt:84]];
 
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:problem0,problem1,problem2,problem3, nil];
    
    NSUInteger arrayCount = [array count ];
    //NSLog(@"arrayCount %i", arrayCount);
    currentProblemIndex = ((arc4random() % arrayCount));
    currentMathProblem = [array objectAtIndex:currentProblemIndex];
    //NSLog(@"current index %i", currentProblemIndex );
    
}

#pragma mark -
#pragma mark Exit

- (void)onEnter {
    NSLog(@"entering");
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:kCCMenuHandlerPriority swallowsTouches:YES];
    [super onEnter];
    
}

- (void)onExit{
    NSLog(@"exiting");
    imageMenu.enabled = NO;
    buyMenu.enabled = NO;
//    [_background removeChild:imageMenu cleanup:YES];
//    [_background removeChild:buyMenu cleanup:YES];
//    [_background removeChild:purchaseItem cleanup:YES];
//    [self removeChild:_background cleanup:YES];
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeAllChildrenWithCleanup:YES];
    
    
}

-(void)closeStore {
    //NO GATE!
    [_background removeChild:emitter_ cleanup:YES];
    NSLog(@"store closed, no gate");
    id moveAction = [CCMoveTo actionWithDuration:1 position:ccp(0, -screenSize.height)];
    [self runAction: [CCSequence actions:moveAction,[CCCallFuncN actionWithTarget:self selector:@selector(removeStore)], nil]];
    
}

-(void)closeStoreViaGate {
    
 
    [_shadowLayer setTouchPriority:0];
    id moveActionShadow = [CCMoveTo actionWithDuration:.5 position:ccp(-screenSize.width, 0)];
    id moveAction = [CCMoveTo actionWithDuration:1 position:ccp(0, -screenSize.height)];
    [_shadowLayer runAction: moveActionShadow];
    [self runAction: [CCSequence actions:moveAction,[CCCallFuncN actionWithTarget:self selector:@selector(removeStore)], nil]];
    
}



-(void)closeGateKeepStore {

    [_shadowLayer setTouchPriority:0];
   
    childGateON = false;
    id moveAction = [CCMoveTo actionWithDuration:.5 position:ccp(0, -screenSize.height)];
    [_shadowLayer runAction: [CCSequence actions:moveAction,[CCCallFuncN actionWithTarget:self selector:@selector(removeGate)], nil]];
    
}


- (void)removeGate{

    [_shadowLayer removeAllChildrenWithCleanup:YES];
    [_shadowLayer removeFromParentAndCleanup:YES];

    

    
}

- (void)removeStore {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveStore" object:self];
}





@end
