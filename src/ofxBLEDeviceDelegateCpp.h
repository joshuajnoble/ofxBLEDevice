//
//  ofxBLEuinoDelegateCpp.h
//  BLEuino
//
//  Created by Joshua Noble on 8/6/14.
//
//

#ifndef BLEuino_ofxBLEuinoDelegateCpp_h
#define BLEuino_ofxBLEuinoDelegateCpp_h

bool ofxBLEisScanning();
void ofxBLEStartScan();

void ofxBLEStopScan();
void ofxBLEConnectDevice(BLEDevice *device);

void ofxBLEDisconnectDevice(BLEDevice *device);
void ofxBLELoadedServiceDevice(BLEDevice *device);

void ofxBLESendData(void * delegate, unsigned char *data, int length);

std::string ofxBLEGetName( BLEDevice *device);

#endif
