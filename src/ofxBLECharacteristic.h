//
//  ofxBLECharacteristic.h
//  bleDeviceDemo
//
//  Created by Joshua Noble on 3/29/15.
//
//

#ifndef bleDeviceDemo_ofxBLECharacteristic_h
#define bleDeviceDemo_ofxBLECharacteristic_h

#include <string>

class ofxBLECharacteristic {
    
public:
    bool shouldNotify;
    NSString *UUID;
    
    ofxBLECharacteristic();
    
};



//@interface ofxBLECharacteristic : NSObject<CBPeripheralDelegate>
//{
//}
//
//@property bool *shouldNotify;
//@property std::string *UUID;
//
//- (void)init;

#endif
