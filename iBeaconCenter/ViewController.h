//
//  ViewController.h
//  ScanBeaconSample
//
//  Created by Manish on 10/10/13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

static int broadcastpower = -59;

@interface ViewController : UIViewController{
    CLLocationManager *_locationManager;
    NSUUID *_uuid;
    NSNumber *_power;
    
    CBPeripheralManager *_peripheralManager;
    
}
@property (strong,readwrite) CLBeaconRegion *region;
-(IBAction)toggleRanging:(UISwitch *)rangingSwitch;
-(IBAction)toggleBroadcasting:(UISwitch *)broadcastingSwitch;
@end
