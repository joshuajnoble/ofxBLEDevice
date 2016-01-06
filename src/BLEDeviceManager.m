/*
 Copyright (c) 2013 OpenSourceRF.com.  All right reserved.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include <objc/message.h>

#import "BLEDeviceManager.h"
#import "BLEDevice.h"

static CBUUID *service_uuid;

@interface BLEDeviceManager()
{
    NSTimer *rangeTimer;
    int rangeTimerCount;
    bool didUpdateDiscoveredDeviceFlag;
    void (^cancelBlock)(void);
    bool isScanning;
}
@end

@implementation BLEDeviceManager

@synthesize delegate;
@synthesize devices;
@synthesize central;
@synthesize charas;

+ (BLEDeviceManager *)sharedBLEManager
{
    static BLEDeviceManager *bleManager;
    if (! bleManager) {
        bleManager = [[BLEDeviceManager alloc] init];
    }
    return bleManager;
}

- (id)init
{
    NSLog(@"init");
    
    self = [super init];
    
    if (self) {
        //service_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2220")];

        //service_uuid = [CBUUID UUIDWithString:(@"c97433f0-be8f-4dc8-b6f0-5343e6100eb4")];
        
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            service_uuid = [CBUUID UUIDWithString:(@RBL_SERVICE_UUID)];
//        });
        CBUUID * myid = [CBUUID UUIDWithString:(@RFDUINO_SERVICE)];//CBUUID * myid = [CBUUID UUIDWithString:(@RBL_SERVICE_UUID)];
        service_uuid = myid;
        
        devices = [[NSMutableArray alloc] init];
        
        self.central = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return self;
}

- (bool)isBluetoothLESupported
{
    if ([self.central state] == CBCentralManagerStatePoweredOn)
        return YES;
    
    NSString *message;
    
    switch ([central state])
    {
        case CBCentralManagerStateUnsupported:
            message = @"This hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            message = @"This app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            message = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStateUnknown:
            // fall through
        default:
            message = @"Bluetooth state is unknown.";
            
    }

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth LE Support"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

#endif

    return NO;
}

- (void)setCharacteristics:(NSArray *)cs
{
    charas = cs;
}

- (void)startRangeTimer
{
    rangeTimerCount = 0;
    
    rangeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(rangeTick:)
                                                userInfo:nil
                                                 repeats:YES];
    
}

- (void)stopRangeTimer
{
    [rangeTimer invalidate];
}

- (void) rangeTick:(NSTimer*)timer
{
    bool update = false;

    rangeTimerCount++;
    if ((rangeTimerCount % 60) == 0) {
        // NSLog(@"restarting scanning");
        
        [self.central stopScan];
        
        NSDictionary *options = nil;
        options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                              forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
        CBUUID * myid = [CBUUID UUIDWithString:(@RFDUINO_SERVICE)];//CBUUID * myid = [CBUUID UUIDWithString:(@RBL_SERVICE_UUID)];
        //[central scanForPeripheralsWithServices:[NSArray arrayWithObject:service_uuid] options:options];
        [self.central scanForPeripheralsWithServices:[NSArray arrayWithObject:myid] options:options];
    }
    
    
    NSDate *date = [NSDate date];
    for (BLEDevice *device in devices) {
        if (!device.outOfRange
            && device.lastAdvertisement != NULL
            && [date timeIntervalSinceDate:device.lastAdvertisement] > 2)
        {
            device.outOfRange = true;
            update = true;
        }
    }
    
    if (update) {
        if (didUpdateDiscoveredDeviceFlag) {
            [delegate didUpdateDiscoveredBLEDevice:nil];
        }
    }
}

#pragma mark - CentralManagerDelegate methods

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didConnectPeripheral");

    BLEDevice *device = [self deviceForPeripheral:peripheral];
    if (device) {
        [device connected];
        [delegate didConnectBLEDevice:device];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didDisconnectPeripheral");

    void (^block)(void) = ^{
        if ([delegate respondsToSelector:@selector(didDisconnectDevice:)]) {
            BLEDevice *device = [self deviceForPeripheral:peripheral];
            if (device) {
                [delegate didDisconnectBLEDevice:device];
            }
        }
    };
    
    if (error.code) {
        cancelBlock = block;

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Peripheral Disconnected with Error"
                                                        message:error.description
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
#endif
        
    }
    else
        block();
    
    if (peripheral) {
        [peripheral setDelegate:nil];
        peripheral = nil;
    }
}

- (BLEDevice *)deviceForPeripheral:(CBPeripheral *)peripheral
{
    for (BLEDevice *device in devices) {
        if ([peripheral isEqual:device.peripheral]) {
            return device;
        }
    }
    return nil;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    /*NSLog(@"didDiscoverPeripheral");

    NSString *uuid = NULL;
    if (peripheral.UUID) {
        // only returned if you have connected to the device before
        uuid = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, peripheral.UUID);
    } else {
        uuid = @"";
    }*/
    
    NSUUID *identifierForVendor = peripheral.identifier;
    NSString *uuid = [identifierForVendor UUIDString];
    
    bool added = false;

    BLEDevice *device = [self deviceForPeripheral:peripheral];
    if (! device) {
        device = [[BLEDevice alloc] init];
        
        device.bleDeviceManager = self;

        device.name = peripheral.name;
        device.UUID = uuid;
        
        device.peripheral = peripheral;
        
        NSString *advertData = [advertisementData valueForKeyPath:@"kCBAdvDataLocalName"];
        device.advertisementData = advertData;
        
        added = true;
        
        [devices addObject:device];
    }
    
    
//    id manufacturerData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
//    if (manufacturerData) {
//        const uint8_t *bytes = [manufacturerData bytes];
//        int len = [manufacturerData length];
//        // skip manufacturer uuid
//        NSData *data = [NSData dataWithBytes:bytes+2 length:len-2];
//        device.advertisementData = data;
//    }
    
    device.characteristics = charas;
    device.advertisementRSSI = RSSI;
    device.advertisementPackets++;
    device.lastAdvertisement = [NSDate date];
    device.outOfRange = false;
    
    if (added) {
        [delegate didDiscoverBLEDevice:device];
    } else {
        if (didUpdateDiscoveredDeviceFlag) {
            [delegate didUpdateDiscoveredBLEDevice:device];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral");

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connect Failed"
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

#endif

}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)aCentral
{
    NSLog(@"central manager state = %d", [central state]);
    
    if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
    }
    
    bool success = [self isBluetoothLESupported];
    if (success) {
        [self startScan];
    }
}

#pragma mark - UIAlertViewDelegate methods

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex
{
    if (buttonIndex == 0) {
        cancelBlock();
    }
}

#endif

#pragma mark - Rfduino methods

- (bool)isScanning
{
    return isScanning;
}

- (void)startScan
{
    NSLog(@"startScan");
    
    isScanning = true;

    NSDictionary *options = nil;
    
    didUpdateDiscoveredDeviceFlag = [delegate respondsToSelector:@selector(didUpdateDiscoveredBLEDevice:)];
    
    if (didUpdateDiscoveredDeviceFlag) {
        options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
        forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    }

    [devices removeAllObjects];
    
    if (self.central.state != CBCentralManagerStatePoweredOn)
    {
        NSLog(@"CoreBluetooth not correctly initialized !");
       // NSLog(@"State = %d (%s)\r\n", self.central.state, [self centralManagerStateToString:self.central.state]);
    }
    
    [NSTimer scheduledTimerWithTimeInterval:(float)60 target:self selector:@selector(rangeTick:) userInfo:nil repeats:NO];
    
    CBUUID * myid = [CBUUID UUIDWithString:(@RFDUINO_CHARACTERISTIC)];//CBUUID * myid = [CBUUID UUIDWithString:(@RBL_SERVICE_UUID)];
//    [self.central scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@RBL_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];

        [self.central scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@RFDUINO_CHARACTERISTIC]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    if (didUpdateDiscoveredDeviceFlag) {
        [self startRangeTimer];
    }
}

- (void)stopScan
{
    NSLog(@"stopScan");
    
    if (didUpdateDiscoveredDeviceFlag) {
        [self stopRangeTimer];
    }
    
    [self.central stopScan];
    
    isScanning = false;
}

- (void)connectBLEDevice:(BLEDevice *)device
{
    NSLog(@"connect ble");
    
    [self.central connectPeripheral:[device peripheral] options:nil];
}

- (void)disconnectBLEDevice:(BLEDevice *)device
{
    NSLog(@"ble mnaager disconnectPeripheral");
    
    [self.central cancelPeripheralConnection:device.peripheral];
}

- (void)loadedServiceBLEDevice:(id)device
{
    if ([delegate respondsToSelector:@selector(didLoadServiceDevice:)]) {
        [delegate didLoadServiceBLEDevice:device];
    }
}

@end
