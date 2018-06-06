//
//  Words.m
//  dkta
//
//  Created by Catherine Cavanagh on 12/23/13.
//  Copyright 2013 Catherine Cavanagh. All rights reserved.
//

#import "Background.h"
#import "GameData.h"
#import "GameDataParser.h"


@implementation Background
@synthesize iPad;



- (id)init {
    if ((self = [super init])) {
        
        winSize = [CCDirector sharedDirector].winSize;
        
    }
    return self;
}

-(void)createCity {
    

    [self createBackground];
    
    self.iPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    int y;
    if (self.iPad) {
        
        y = 1024;
    }
    else {
        
        y = 512;
    }
    

    
    CCSprite *citybackground = [CCSprite spriteWithFile:@"citybackgroundJ.png" rect:CGRectMake(0, 0, winSize.width, y )];
    citybackground.position = ccp(winSize.width/2,0);
    citybackground.opacity = 99;
    ccTexParams params2 = { GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE};

    [[citybackground texture] setTexParameters:&params2];
    
    [self addChild:citybackground];


    
}


-(void)createBackgroundWithNoise {
    
    [self createBackground];

    
}

-(void)createBackground {
    
    
    [_background removeFromParentAndCleanup:YES];
    
    ccColor4F bgColor = [self randomBrightColor];
    
    _background = [self spriteWithColor:bgColor textureWidth:winSize.width textureHeight:winSize.height];
    _background.position = ccp(winSize.width/2, winSize.height/2);
    ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE};
    [_background.texture setTexParameters:&tp];
    
    [self addChild:_background z:-1];
    
    
}

- (ccColor4F)randomBrightColor {
    
    while (true) {
        //float requiredDarknessR = 153;
        //float requiredDarknessG = 0;
        CGFloat requiredBrightnessG = 50;
        
        
        ccColor4B randomColor =
        ccc4(arc4random() % 255,
             arc4random() % 255,
             255,
             255);
        if (randomColor.r < randomColor.g && randomColor.g > requiredBrightnessG) {
            return ccc4FFromccc4B(randomColor);
        }
    }
    
}

-(CCSprite *)spriteWithColor:(ccColor4F)bgColor textureWidth:(GLfloat)textureWidth textureHeight:(GLfloat)textureHeight {
    
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureWidth height:textureHeight];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:bgColor.r g:bgColor.g b:bgColor.b a:bgColor.a];
    
    self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
    
    CC_NODE_DRAW_SETUP();
    
    // 3: Draw into the texture
    CGFloat gradientAlpha = 0.7f;
    CGPoint vertices[4];
    ccColor4F colors[4];
    int nVertices = 0;
    
    vertices[nVertices] = CGPointMake(0, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0 };
    vertices[nVertices] = CGPointMake(textureWidth, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    vertices[nVertices] = CGPointMake(0, textureHeight);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    vertices[nVertices] = CGPointMake(textureWidth, textureHeight);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position  | kCCVertexAttribFlag_Color);
    
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, 0, colors);
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
    
    // 3: Draw into the texture
    
    CCSprite *noise = [CCSprite spriteWithFile:@"noise1.png" rect:CGRectMake(0, 0, winSize.width, winSize.height)];
    
    noise.position = ccp(winSize.width/2,winSize.height/2);
    ccTexParams params = { GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [noise setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
    //[background setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ONE}];
    [[noise texture] setTexParameters:&params];
    
    [self addChild:noise];
    
    // 4: Call CCRenderTexture:end
    [rt end];
    
    // 5: Create a new Sprite from the texture
    return [CCSprite spriteWithTexture:rt.sprite.texture];
    
}

- (void) onExit {
    [self removeAllChildrenWithCleanup:YES];
    
}

@end
