//
//  ofxBLEDeviceAppImpl.h
//  BLEDevice
//
//  Created by Joshua Noble on 8/5/14.
//
//

#pragma once

#import <Foundation/Foundation.h>
#import "BLEDeviceManagerDelegate.h"
#import "BLEDeviceManager.h"
#import "ofxBLEDeviceApp.h"
#import "ofxBLECharacteristic.h"
#import <string>
#import <vector>

@class BLEDeviceManager;
@class BLEDevice;


@interface ofxBLEDeviceDelegate : UIResponder<BLEDeviceManagerDelegate, BLEDeviceDelegate>
{
    ofxBLEDeviceApp *application;
    
@public
    BLEDeviceManager *deviceManager;
}

@property(strong, nonatomic) BLEDevice *connectedBLEDevice;

- (id) init;

- (void)setApplication:(ofxBLEDeviceApp *)app;
- (void)didDiscoverBLEDevice:(BLEDevice *)device;
- (void)didUpdateDiscoveredBLEDevice:(BLEDevice *)device;
- (void)didConnectBLEDevice:(BLEDevice *)device;
- (void)didLoadServiceBLEDevice:(BLEDevice *)device;
- (void)didDisconnectBLEDevice:(BLEDevice *)device;
//- (void)setCharacteristics:(std::vector<ofxBLECharacteristic>&)charas;
- (void)sendData:(NSData*) data;

@end

