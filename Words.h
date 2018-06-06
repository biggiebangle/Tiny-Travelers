//
//  Words.h
//  dkta
//
//  Created by Catherine Cavanagh on 6/23/14.
//  Copyright 2014 Catherine Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface Words : CCNode {
    
    NSString *_lineOne;
    NSString *_lineTwo;
    NSString *_lineThree;
    NSString *_lineFour;
    
 
}


@property (nonatomic, assign) BOOL iPad;
@property (nonatomic, assign) NSString *device;

-(void)createWords:(int)pageNumber;

@end
