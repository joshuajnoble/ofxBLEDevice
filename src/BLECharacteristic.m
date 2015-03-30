//
//  BLECharacteristic.m
//
//
//  Created by Joshua Noble on 3/29/15.
//
//

#import <Foundation/Foundation.h>
#import "BLECharacteristic.h"

@implementation BLECharacteristic

@synthesize uuid;
@synthesize shouldNotify;

- (void)setId:(NSString *)thisId
{
    uuid = [[NSString alloc]initWithString:thisId];
    //uuid = thisId;
}


@end