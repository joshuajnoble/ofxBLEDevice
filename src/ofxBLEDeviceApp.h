//
//  ofxBLEDeviceApp.h
//  BLEDevice
//
//  Created by Joshua Noble on 8/5/14.
//
//

#ifndef BLEDevice_ofxBLEDeviceApp_h
#define BLEDevice_ofxBLEDeviceApp_h

#include "BLEDevice.h"

class ofxBLEDeviceApp
{
public:
    virtual void didDiscoverBLEDevice(BLEDevice *BLEDevice) = 0;
    virtual void didUpdateDiscoveredBLEDevice(BLEDevice *BLEDevice) = 0;
    virtual void didConnectBLEDevice(BLEDevice *BLEDevice) = 0;
    virtual void didLoadServiceBLEDevice(BLEDevice *BLEDevice) = 0;
    virtual void didDisconnectBLEDevice(BLEDevice *BLEDevice) = 0;
    
    virtual void receivedData( const char *data) = 0;
};
#endif
