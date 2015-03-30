//
//  whatever.m
//  BLE
//
//  Created by Joshua Noble on 8/6/14.
//
//

#import "ofxBLEDeviceDelegate.h"
#import "ofxBLECharacteristic.h"

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

void ofxBLESendData(void * delegate, unsigned char* data, ofxBLECharacteristic characteristic, int length) {
    NSData *nsdata = [NSData dataWithBytes:(void*)data length:length];
    //NSString *myNSString = [NSString stringWithUTF8String:characteristic.UUID.c_str()];
    CBUUID *uuid = [CBUUID UUIDWithString:characteristic.UUID];
    [(id) delegate sendData:nsdata uuid:uuid];
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


- (void)sendData:(NSData*) data uuid:(CBUUID*) uid
{
    [connectedBLEDevice send:data uuid:uid];
}


void ofxBLESetCharacteristics(std::vector<ofxBLECharacteristic>& charas)
{
    
    NSMutableArray *mm = [[NSMutableArray alloc] init];
    
    
    for( int i = 0; i < charas.size(); i++ ) {
        
        //NSString *uuid = [NSString stringWithCString:charas.at(i).UUID.c_str() encoding:[NSString defaultCStringEncoding]];
        BLECharacteristic *b = [[BLECharacteristic alloc] init];
        [b setId:charas.at(i).UUID];
        b.shouldNotify = charas.at(i).shouldNotify;
        
        
        [mm addObject:b];
    }
    [BLEDeviceManager sharedBLEManager].charas = mm;
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
    [BLE setDelegate:self];
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