//
//  Words.m
//  dkta
//
//  Created by Catherine Cavanagh on 6/23/14.
//  Copyright 2014 Catherine Cavanagh. All rights reserved.
//

#import "Words.h"



@implementation Words
@synthesize iPad;



- (id)init {
    if ((self = [super init])) {
        
        
    }
    return self;
}

-(void)createWords:(int)pageNumber {

    
    int myInteger = pageNumber;
    NSString *myNewString = [NSString stringWithFormat:@"%i", myInteger];
    NSString *pgNumber = [@"pg" stringByAppendingString:myNewString];
    
    _lineOne = [pgNumber stringByAppendingString:@"A"];
    _lineTwo = [pgNumber stringByAppendingString:@"B"];
    _lineThree = [pgNumber stringByAppendingString:@"C"];
    _lineFour = [pgNumber stringByAppendingString:@"D"];
    
    [self spawnLanguage];
    
    
}
- (void) spawnLanguage {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    int Margin = screenSize.width*.01;
 
    self.iPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
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
    //Centering in Chinese and Spanish
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    CCLayer *layer = [[CCLayer alloc] init];
    
    CCLabelTTF *layerLabelShadow = [CCLabelTTF labelWithString:NSLocalizedString(_lineOne, @"Line One")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    
    
    layerLabelShadow.color = ccc3(0,0,0);
    [layer addChild:layerLabelShadow];
    
    
    CCLabelTTF *layerLabelShadow2 = [CCLabelTTF labelWithString:NSLocalizedString(_lineTwo,@"Line Two")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    
    layerLabelShadow2.color = ccc3(0,0,0);
    [layer addChild:layerLabelShadow2];
    
    
    CCLabelTTF *layerLabelShadow3 = [CCLabelTTF labelWithString:NSLocalizedString(_lineThree,@"Line Three")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    
    layerLabelShadow3.color = ccc3(0,0,0);
    [layer addChild:layerLabelShadow3];
    
    
    CCLabelTTF *layerLabelShadow4 = [CCLabelTTF labelWithString:NSLocalizedString(_lineFour,@"Line Four")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    
    layerLabelShadow4.color = ccc3(0,0,0);
    [layer addChild:layerLabelShadow4];
    
    CCLabelTTF *layerLabel = [CCLabelTTF labelWithString:NSLocalizedString(_lineOne, @"Line One")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];
    

    layerLabel.color = ccc3(255,255,255);
    [layer addChild:layerLabel];

    
    CCLabelTTF *layerLabel2 = [CCLabelTTF labelWithString:NSLocalizedString(_lineTwo,@"Line Two")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];

    layerLabel2.color = ccc3(255,255,255);
    [layer addChild:layerLabel2];
    
    
    CCLabelTTF *layerLabel3 = [CCLabelTTF labelWithString:NSLocalizedString(_lineThree,@"Line Three")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];

    layerLabel3.color = ccc3(255,255,255);
    [layer addChild:layerLabel3];
    
    
    CCLabelTTF *layerLabel4 = [CCLabelTTF labelWithString:NSLocalizedString(_lineFour,@"Line Four")fontName:NSLocalizedString(@"fontName", @"name of font") fontSize:fontSize];

    layerLabel4.color = ccc3(255,255,255);
    [layer addChild:layerLabel4];
    

    
    //Centering for no listen button in everything but English
    if([language  isEqual: @"en"])
    {
        layerLabel.position =  ccp(layerLabel.contentSize.width/2 + Margin*4, screenSize.height - Margin*4);
        layerLabel2.position =  ccp(layerLabel2.contentSize.width/2 + Margin*4, screenSize.height*.9 - Margin*4);
        layerLabel3.position =  ccp(layerLabel3.contentSize.width/2 + Margin*4 , screenSize.height*.8 - Margin*4);
        layerLabel4.position =  ccp(layerLabel4.contentSize.width/2 + Margin*4 , screenSize.height*.7 - Margin*4);
        
        layerLabelShadow.position =  ccp(layerLabel.contentSize.width/2 + Margin*4-shadowDistance, screenSize.height - Margin*4-shadowDistance);
        layerLabelShadow2.position =  ccp(layerLabel2.contentSize.width/2 + Margin*4-shadowDistance, screenSize.height*.9 - Margin*4-shadowDistance);
        layerLabelShadow3.position =  ccp(layerLabel3.contentSize.width/2 + Margin*4-shadowDistance , screenSize.height*.8 - Margin*4-shadowDistance);
        layerLabelShadow4.position =  ccp(layerLabel4.contentSize.width/2 + Margin*4-shadowDistance , screenSize.height*.7 - Margin*4-shadowDistance);
    }else {
        layerLabel.position =  ccp(screenSize.width/2, screenSize.height - Margin*4);
        layerLabel2.position =  ccp(screenSize.width/2, screenSize.height*.9 - Margin*4);
        layerLabel3.position =  ccp(screenSize.width/2 , screenSize.height*.8 - Margin*4);
        layerLabel4.position =  ccp(screenSize.width/2 , screenSize.height*.7 - Margin*4);
        layerLabelShadow.position =  ccp(screenSize.width/2-shadowDistance, screenSize.height - Margin*4-shadowDistance);
        layerLabelShadow2.position =  ccp(screenSize.width/2-shadowDistance, screenSize.height*.9 - Margin*4-shadowDistance);
        layerLabelShadow3.position =  ccp(screenSize.width/2-shadowDistance , screenSize.height*.8 - Margin*4-shadowDistance);
        layerLabelShadow4.position =  ccp(screenSize.width/2-shadowDistance , screenSize.height*.7 - Margin*4-shadowDistance);
        
    }
    
    [self addChild:layer];
}



@end
