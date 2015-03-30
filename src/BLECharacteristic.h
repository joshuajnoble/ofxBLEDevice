//
//  BLECharacteristic.h
//  bleDeviceDemo
//
//  Created by Joshua Noble on 3/29/15.
//
//

#ifndef bleDeviceDemo_BLECharacteristic_h
#define bleDeviceDemo_BLECharacteristic_h

#import <Foundation/Foundation.h>

@interface BLECharacteristic : NSObject

@property NSString *uuid;
@property bool shouldNotify;

@end


#endif
