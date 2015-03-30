#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup()
{
    //BLEDeviceManager = BLEDeviceManager.sharedBLEDeviceManager;
    
    BLEDeviceImpl = [[ofxBLEDeviceDelegate alloc] init];
    [BLEDeviceImpl setApplication:this];
    
    vector<ofxBLECharacteristic> charas;
    
    ofxBLECharacteristic tx;
    tx.UUID = "713D0003-503E-4C75-BA94-3148F18D941E";
    tx.shouldNotify = false;
    
    charas.push_back(tx);
    
    ofxBLECharacteristic rx;
    rx.UUID = "713D0002-503E-4C75-BA94-3148F18D941E";
    rx.shouldNotify = true;
    
    charas.push_back(rx);
    
    ofxBLESetCharacteristics(charas);
}

//--------------------------------------------------------------
void ofApp::update(){

}

//--------------------------------------------------------------
void ofApp::draw(){
	
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    unsigned char data[3];
    data[0] = '1';
    data[1] = '2';
    data[2] = '3';
    ofxBLESendData(BLEDeviceImpl, &data[0], 3);
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}

//--------------------------------------------------------------
void ofApp::didDiscoverBLEDevice(BLEDevice *device)
{
    cout << " didDiscoverBLEDevice " << endl;
    std::string deviceName([device.name UTF8String]);
    if(deviceName == "SimpleChat") {
        ofxBLEConnectDevice(device);
    }
}

void ofApp::didUpdateDiscoveredBLEDevice(BLEDevice *device)
{
    cout << " didUpdateDiscoveredBLEDevice " << endl;
}

void ofApp::didConnectBLEDevice(BLEDevice *device)
{
    cout << " didConnectBLEDevice " << endl;
}

void ofApp::didLoadServiceBLEDevice(BLEDevice *device)
{
    cout << " didLoadServiceBLEDevice " << endl;
}

void ofApp::didDisconnectBLEDevice(BLEDevice *device)
{
    cout << " didDisconnectBLEDevice " << endl;
}

void ofApp::receivedData( const char *data)
{
    cout << " got some data! " << endl;
}
