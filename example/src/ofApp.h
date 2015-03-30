#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxBLEDeviceApp.h"
#include "ofxBLEDeviceDelegate.h"
#include "ofxBLEDeviceDelegateCpp.h"
#include "BLEDeviceManager.h"

class ofApp : public ofxiOSApp, public ofxBLEDeviceApp {
    
public:
    
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    void didDiscoverBLEDevice(BLEDevice *device);
    void didUpdateDiscoveredBLEDevice(BLEDevice *device);
    void didConnectBLEDevice(BLEDevice *device);
    void didLoadServiceBLEDevice(BLEDevice *device);
    void didDisconnectBLEDevice(BLEDevice *device);
    void receivedData( const char *data);
    
    ofxBLEDeviceDelegate *BLEDeviceImpl;
    
    vector<ofxBLECharacteristic> charas;
    ofxBLECharacteristic rx;
    ofxBLECharacteristic tx;
};


