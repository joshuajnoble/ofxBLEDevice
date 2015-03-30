//
//  ofxBLECharacteristic.cpp
//  bleDeviceDemo
//
//  Created by Joshua Noble on 3/30/15.
//
//

#include <stdio.h>
#include "ofxBLECharacteristic.h"

ofxBLECharacteristic::ofxBLECharacteristic()
{
    shouldNotify = false;
    UUID = "";
}