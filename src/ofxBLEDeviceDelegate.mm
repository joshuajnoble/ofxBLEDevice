//
//  whatever.m
//  BLE
//
//  Created by Joshua Noble on 8/6/14.
//
//

#import "ofxBLEDeviceDelegate.h"

@implementation ofxBLEDeviceDelegate

@synthesize connectedBLEDevice;

- (id) init
{
    deviceManager = [BLEDeviceManager sharedBLEManager];
    deviceManager.delegate = self;
    return self;
}


bool ofxBLEIsScanning()
{
    return [[BLEDeviceManager sharedBLEManager] isScanning];
}

void ofxBLEStartScan()
{
    return [[BLEDeviceManager sharedBLEManager] startScan];
}

void ofxBLEStopScan()
{
    return [[BLEDeviceManager sharedBLEManager] stopScan];
}

void ofxBLEConnectDevice(BLEDevice *BLE)
{
    return [[BLEDeviceManager sharedBLEManager] connectBLEDevice:BLE];
}

void ofxBLEDisconnectDevice(BLEDevice *BLE)
{
    [[BLEDeviceManager sharedBLEManager] disconnectBLEDevice:BLE];
}

void ofxBLELoadedServiceDevice(BLEDevice *BLE)
{
    [[BLEDeviceManager sharedBLEManager] loadedServiceBLEDevice:BLE];
}

void ofxBLESendData(void * delegate, unsigned char* data, int length) {
    NSData *nsdata = [NSData dataWithBytes:(void*)data length:length];
    return [(id) delegate sendData:nsdata];
}

std::string ofxBLEGetName( BLEDevice *BLE)
{
    std::string name([BLE.name UTF8String]);
    return name;
}


- (void)setApplication:(ofxBLEDeviceApp *)app
{
    application = app;
}


- (void)sendData:(NSData*) data
{
    [connectedBLEDevice send:data];
}

- (void)didReceive:(NSData *)data
{
    NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    const char *cString = [newStr UTF8String];
    application->receivedData(cString);
}

- (void)didDiscoverBLEDevice:(BLEDevice*)BLE
{
    application->didDiscoverBLEDevice(BLE);
}

- (void)didUpdateDiscoveredBLE:(BLEDevice*)BLE
{
    application->didUpdateDiscoveredBLEDevice(BLE);
}

- (void)didConnectBLEDevice:(BLEDevice*)BLE
{
    [BLEDevice setDelegate:self];
    connectedBLEDevice= BLE;
    application->didConnectBLEDevice(BLE);
}

- (void)didLoadServiceBLEDevice:(BLEDevice*)BLE
{
    application->didLoadServiceBLEDevice(BLE);
}

- (void)didDisconnectBLEDevice:(BLEDevice*)BLE
{
    application->didDisconnectBLEDevice(BLE);
}

@end