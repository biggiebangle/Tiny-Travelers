//
//  GameDataParser.m
//

#import "WeatherDataParser.h"
#import "WeatherData.h"
#import "GDataXMLNode.h"

@implementation WeatherDataParser


- (id)DataforXMLParser:(NSData*)xmlData{
    return xmlData;
}

+ (WeatherData *)loadData:(NSMutableData*)xmlData {
   
    /***************************************************************************
     This loadData method is used to load data from the xml file
     specified in the dataFilePath method above.
     
     MODIFY the list of variables below which will be used to create
     and return an instance of TemplateData at the end of this method.
     ***************************************************************************/
    
    int weatherNumber;
    int windSpeed;
    int cloudCover;
    int temperature;

    NSError *error;
    NSString *_receivedXMLString = [[NSString alloc] initWithData:xmlData
                                               encoding:NSASCIIStringEncoding];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:_receivedXMLString options:0 error:&error];
    //if (doc == nil) { return nil; NSLog(@"xml file is empty!");}
    
    //!!!!!!
     //NSLog(@"Loading %@", _receivedXMLString);
    //!!!!!
    
    /***************************************************************************
     This next line will usually have the most customisation applied because
     it will be a direct reflection of what you want out of the XML file.
     ***************************************************************************/

    NSArray *dataWeatherArray = [doc nodesForXPath:@"//weather" error:nil];
    NSArray *dataWindArray = [doc nodesForXPath:@"//speed" error:nil];
    NSArray *dataCloudArray = [doc nodesForXPath:@"//clouds" error:nil];
    NSArray *temperatureArray = [doc nodesForXPath:@"//temperature" error:nil];

    
    /***************************************************************************
     We use dataArray to populate variables created at the start of this
     method. For each variable you will need to:
     1. Create an array based on the elements in the xml
     2. Assign the variable a value based on data in elements in the xml
     ***************************************************************************/
    
	

  

    for (GDataXMLElement *element in dataWeatherArray) {
        
      
        weatherNumber = [[(GDataXMLElement *) [element attributeForName:@"number"] stringValue] intValue];
        NSLog(@"weather code %i", weatherNumber);

        
    }
    for (GDataXMLElement *element in dataWindArray) {
        
        
        windSpeed = [[(GDataXMLElement *) [element attributeForName:@"value"] stringValue] intValue];
        NSString  *speedName = [(GDataXMLElement *) [element attributeForName:@"name"] stringValue];
        NSLog(@"wind speed %i", windSpeed);
        NSLog(@"wind name %@", speedName);
        
        
    }
    
    for (GDataXMLElement *element in dataCloudArray) {
        
        
        cloudCover = [[(GDataXMLElement *) [element attributeForName:@"value"] stringValue] intValue];
        NSString  *cloudName = [(GDataXMLElement *) [element attributeForName:@"name"] stringValue];
        NSLog(@"cloud cover %i", cloudCover);
        NSLog(@"cloud name %@", cloudName);
        
        
    }
    for (GDataXMLElement *element in temperatureArray) {
        
        
        temperature = [[(GDataXMLElement *) [element attributeForName:@"value"] stringValue] intValue];
        NSLog(@"temp %i", temperature);
        
        
    }
    
    /***************************************************************************
     Now the variables are populated from xml data we create an instance of
     TemplateData to pass back to whatever called this method.
     
     The initWithExampleInt:exampleBool:exampleString will need to be replaced
     with whatever method you have updaed in the TemplateData class.
     ***************************************************************************/
    

    WeatherData *Data = [[WeatherData alloc] initWithWeatherNumber:weatherNumber windSpeed:windSpeed cloudCover:cloudCover temperature:temperature];
    
    // [doc release];
    // [xmlData release];
    return Data;
    //[Data release];
}



@end