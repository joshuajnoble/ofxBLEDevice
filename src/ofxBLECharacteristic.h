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
    std::string UUID;
};

#endif
