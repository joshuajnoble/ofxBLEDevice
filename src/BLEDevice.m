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

#import "BLEDevice.h"
#import "BLEDeviceManager.h"

static const int max_data = 12;

// default NULL (NULL = previous fixed RFduino uuid)
NSString *customUUID = @RFDUINO_CHARACTERISTIC;
NSString *customTX_UUID = @RFDUINO_TX;
NSString *customRX_UUID = @RFDUINO_RX;

static CBUUID *service_uuid;
static CBUUID *send_uuid;
static CBUUID *receive_uuid;
static CBUUID *disconnect_uuid;

char data(NSData *data)
{
    return (char)dataByte(data);
}

uint8_t dataByte(NSData *data)
{
    uint8_t *p = (uint8_t*)[data bytes];
    NSUInteger len = [data length];
    return (len ? *p : 0);
}

int dataInt(NSData *data)
{
    uint8_t *p = (uint8_t*)[data bytes];
    NSUInteger len = [data length];
    return (sizeof(int) <= len ? *(int*)p : 0);
}

float dataFloat(NSData *data)
{
    uint8_t *p = (uint8_t*)[data bytes];
    NSUInteger len = [data length];
    return (sizeof(float) <= len ? *(float*)p : 0);
}

// increment the 16-bit uuid inside a 128-bit uuid
static void incrementUuid16(CBUUID *uuid, unsigned char amount)
{
    NSData *data = uuid.data;
    unsigned char *bytes = (unsigned char *)[data bytes];
    unsigned char result = bytes[3] + amount;
    if (result < bytes[3])
        bytes[2]++;
    bytes[3] += amount;
}

@interface BLEDevice()
{
    CBCharacteristic *send_characteristic;
    CBCharacteristic *disconnect_characteristic;
    bool loadedService;
}
@end

@implementation BLEDevice

@synthesize delegate;
@synthesize bleDeviceManager;
@synthesize peripheral;

@synthesize name;
@synthesize UUID;
@synthesize advertisementData;
@synthesize advertisementRSSI;
@synthesize advertisementPackets;
@synthesize outOfRange;

@synthesize characteristics;

- (id)init
{
    NSLog(@"BLEDevice init");
    
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)connected
{
    NSLog(@"BLEDevice connected");
    
    service_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2220")];
    receive_uuid = [CBUUID UUIDWithString:(customRX_UUID ? customRX_UUID : @"2221")];
    if (customUUID)
        incrementUuid16(receive_uuid, 1);
    send_uuid = [CBUUID UUIDWithString:(customTX_UUID ? customTX_UUID : @"2222")];
    if (customUUID)
        incrementUuid16(send_uuid, 2);
    disconnect_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2223")];
    if (customUUID)
        incrementUuid16(disconnect_uuid, 3);
    peripheral.delegate = self;
    
    [peripheral discoverServices:[NSArray arrayWithObject:service_uuid]];
}

#pragma mark - CBPeripheralDelegate methods

- (void)peripheral:(CBPeripheral *)_peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"didDiscoverServices");
    
    for (CBService *service in peripheral.services) {
        CBUUID *tservice_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2220")];
        if ([service.UUID isEqual:tservice_uuid])
        {

//            CBUUID *treceive_uuid = [CBUUID UUIDWithString:(customRX_UUID ? customRX_UUID : @"2221")];
//            CBUUID *tsend_uuid = [CBUUID UUIDWithString:(customTX_UUID ? customTX_UUID : @"2222")];
//            CBUUID *tdisconnect_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2223")];
         
            NSMutableArray *uuids  = [[NSMutableArray alloc] init];
            
            for( BLECharacteristic *chara in characteristics)
            {
                NSString *s = chara.uuid;
                CBUUID *uuid = [CBUUID UUIDWithString: (chara.uuid)];

                [uuids addObject:uuid];
            }
            
            
            //NSArray *characteristics = [NSArray arrayWithObjects:treceive_uuid, tsend_uuid, tdisconnect_uuid, nil];
            [peripheral discoverCharacteristics:uuids forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)_peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"didDiscoverCharacteristicsForService");
    for (CBService *service in peripheral.services) {
        CBUUID *tservice_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2220")];
        if ([service.UUID isEqual:tservice_uuid]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                
                CBUUID *treceive_uuid = [CBUUID UUIDWithString:(customTX_UUID ? customTX_UUID : @"2221")];
                CBUUID *tsend_uuid = [CBUUID UUIDWithString:(customRX_UUID ? customRX_UUID : @"2222")];
                CBUUID *tdisconnect_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2223")];
                
                
                for( BLECharacteristic *chara in characteristics)
                {
                    CBUUID *uuid = [CBUUID UUIDWithString:(chara.uuid)];
                    if ([characteristic.UUID isEqual:uuid]) {
                        [peripheral setNotifyValue:chara.shouldNotify forCharacteristic:characteristic];
                    }
                }
                
//                if ([characteristic.UUID isEqual:treceive_uuid]) {
//                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//                } else if ([characteristic.UUID isEqual:tsend_uuid]) {
//                    send_characteristic = characteristic;
//                } else if ([characteristic.UUID isEqual:tdisconnect_uuid]) {
//                    disconnect_characteristic = characteristic;
//                }
            }
            
            loadedService = true;
            [bleDeviceManager loadedServiceBLEDevice:self];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didUpdateValueForCharacteristic");
    CBUUID *treceive_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2221")];
    if ([characteristic.UUID isEqual:treceive_uuid]) {
        SEL didReceive = @selector(didReceive:);
        if ([delegate respondsToSelector:didReceive]) {
            [delegate didReceive:characteristic.value];
        }
    }
}

#pragma mark - BLEDevice methods

- (void)send:(NSData *)data uuid:(CBUUID*) uid
{
    if (! loadedService) {
        @throw [NSException exceptionWithName:@"sendData" reason:@"please wait for ready callback" userInfo:nil];
    }
    
    if ([data length] > max_data) {
        @throw [NSException exceptionWithName:@"sendData" reason:@"max data size exceeded" userInfo:nil];
    }
    
    for (CBService *service in peripheral.services) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            
            if([characteristic.UUID isEqual:uid]) {
                [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            }
        }
    }
}

- (void)disconnect
{
    NSLog(@"rfduino disconnect");
    
    if (loadedService) {
        NSLog(@"writing to disconnect characteristic");
        // fix for iOS SDK 7.0 - at least one byte must now be transferred
        uint8_t flag = 1;
        NSData *data = [NSData dataWithBytes:(void*)&flag length:1];
        [peripheral writeValue:data forCharacteristic:disconnect_characteristic type:CBCharacteristicWriteWithoutResponse];
    }
    
    [bleDeviceManager disconnectBLEDevice:self];
}

@end
