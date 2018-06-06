//
//  IntroLayer.h
//  dkta
//
//  Created by Catherine Cavanagh on 8/10/13.
//  Copyright Catherine Cavanagh 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface IntroLayer : CCLayer <NSURLConnectionDelegate>
{
     NSMutableData *_responseData;
    NSString *_receivedXMLString;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
