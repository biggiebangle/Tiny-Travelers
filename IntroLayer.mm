//
//  IntroLayer.m
//  dkta
//
//  Created by Catherine Cavanagh on 8/10/13.
//  Copyright Catherine Cavanagh 2013. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "TinyTravelerIntro.h"
#import "GameData.h"
#import "GameDataParser.h"
#import "WeatherData.h"
#import "WeatherDataParser.h"
#import "SimpleAudioEngine.h"

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}
#ifdef TTLUGGAGE
#else
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it

    //CCLOG(@"connection response");
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
     //CCLOG(@"connection data %@", data);
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
   // CCLOG(@"connection data %@", _responseData);
    _receivedXMLString = [[NSString alloc] initWithData:_responseData
                                           encoding:NSASCIIStringEncoding];
   // CCLOG( @"From connectionDidFinishLoading: %@", _receivedXMLString );
    
    WeatherData *weatherData = [WeatherDataParser loadData:_responseData];
    
    GameData *gameData = [GameDataParser loadData];
    gameData.weatherNumber = weatherData.weatherNumber;
    gameData.windSpeed = weatherData.windSpeed;
    gameData.cloudCover = weatherData.cloudCover;
    gameData.temperature = weatherData.temperature;
    [GameDataParser saveData:gameData];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[TinyTravelerIntro scene] ]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    GameData *gameData = [GameDataParser loadData];
    gameData.weatherNumber = 800;
    gameData.windSpeed = 0;
    gameData.cloudCover = 0;
    gameData.temperature = 64;
    [GameDataParser saveData:gameData];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[TinyTravelerIntro scene] ]];
}
#endif

-(id) init
{
	if( (self=[super init])) {
       
#ifdef TTLUGGAGE
        GameData *gameData = [GameDataParser loadData];
        gameData.weatherNumber = 800;
        gameData.windSpeed = 0;
        gameData.cloudCover = 0;
        gameData.temperature = 64;
        [GameDataParser saveData:gameData];
#else
        // Create the request.
       //NSURL *url = [NSURL URLWithString:@""];

        NSURL *url = [NSURL URLWithString:@"http://api.openweathermap.org/data/2.5/find?q=New%20York%20City,%20US&units=imperial&mode=xml"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        //Setting a time out
        request.timeoutInterval = 15.0;
        
        // Create url connection and fire request
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSLog(@"%@", conn);
#endif
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background;
		
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
			background = [CCSprite spriteWithFile:@"Default.png"];
			background.rotation = 90;
		} else {
			background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
		}
        if ([UIScreen mainScreen].bounds.size.height == 568.0) {
            background = [CCSprite spriteWithFile:@"Default-568h@2x.png"];
            background.rotation = 90;
        }
		background.position = ccp(size.width/2, size.height/2);
		
		[self addChild: background];
        
       SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
        if (sae != nil) {
            [sae preloadBackgroundMusic:@"quietLarkspur.mp3"];
            if(sae.willPlayBackgroundMusic){
                sae.backgroundMusicVolume = 0.5f;
            }
        }
        
       
	}
	
	return self;
}

//viewDidAppear
-(void) onEnter
{
#ifdef TTLUGGAGE
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[TinyTravelerIntro scene] ]];
#else
#endif
    [super onEnter];
    
}
@end
