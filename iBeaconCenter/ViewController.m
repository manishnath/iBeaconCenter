//
//  ViewController.m
//  ScanBeaconSample
//
//  Created by Manish on 10/10/13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<CLLocationManagerDelegate,CBPeripheralManagerDelegate>{
    BOOL turnAdvertisingOn;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Interaction

-(IBAction)toggleBroadcasting:(UISwitch *)broadcastingSwitch{
    BOOL flag = broadcastingSwitch.on;
    if (flag) {
        [self initiatePeripheralManagerForBeaconBroadcast];
    }
    else{
        [self stopBeaconBroadCast];
    }
}

-(IBAction)toggleRanging:(UISwitch *)rangingSwitch{
    BOOL flag = rangingSwitch.on;
    if (flag) {
        [self startRanging];
    }
    else{
        [self stopRanging];
    }
}


#pragma mark - Beacon Range
-(void)startRanging{
    
    //Check if monitoring is available or not
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Monitoring not available" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (_locationManager!=nil) {
        if(region){
            region.notifyOnEntry = YES;
            region.notifyOnExit = YES;
            region.notifyEntryStateOnDisplay = YES;
            [_locationManager startMonitoringForRegion:region];
            [_locationManager startRangingBeaconsInRegion:region];
            
        }
        else{
            _uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"COM.SELF.ID"];
            if(region){
                region.notifyOnEntry = YES;
                region.notifyOnExit = YES;
                region.notifyEntryStateOnDisplay = YES;
                [_locationManager startMonitoringForRegion:region];
                [_locationManager startRangingBeaconsInRegion:region];
                
            }
        }
    }
    else{
        _uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"COM.SELF.ID"];
        if(region){
            region.notifyOnEntry = YES;
            region.notifyOnExit = YES;
            region.notifyEntryStateOnDisplay = YES;
            [_locationManager startMonitoringForRegion:region];
            [_locationManager startRangingBeaconsInRegion:region];
            
        }
    }
}



-(void)stopRanging{
    [_locationManager stopRangingBeaconsInRegion:region];
    [_locationManager stopMonitoringForRegion:region];
}

#pragma mark - Beacon broadcast

-(void)initiatePeripheralManagerForBeaconBroadcast{
    if (_peripheralManager) {
        [self advertiseBeacon];
        return;
    }
    
    //This starts a check on the update state delegate to see if bluetooth is powered on or not
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    turnAdvertisingOn = YES;
}

-(void)stopBeaconBroadCast{
    if (_peripheralManager) {
        turnAdvertisingOn = NO;
        [_peripheralManager stopAdvertising];
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    NSLog(@"peripheral %@",peripheral);
    
    //Check if the BLE state was on or not
    if (peripheral.state == CBPeripheralManagerStatePoweredOn && turnAdvertisingOn) {
        [self advertiseBeacon];
    }
}

-(void)advertiseBeacon{
    _uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    _power = @(broadcastpower);
    CLBeaconRegion *newregion = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid major:10 minor:5 identifier:@"COM.SELF.ID"];
    NSMutableDictionary *peripheralData = [newregion peripheralDataWithMeasuredPower:_power];
    
    NSLog(@"start advertising %@",peripheralData);
    //Advertise the same beacon region and Range the same beacon region
    [_peripheralManager startAdvertising:peripheralData];
    
}

#pragma mark - set range colors

-(void)setinrangeColor{
    self.view.backgroundColor = [UIColor greenColor];
}

-(void)setoutofrangeColor{
    self.view.backgroundColor = [UIColor redColor];
    
}

-(void)setfarrangeColor{
    self.view.backgroundColor = [UIColor yellowColor];
}



#pragma mark - Location manager beacon region delegate

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    NSLog(@"Enter Region  @",region);
    [_locationManager startRangingBeaconsInRegion:region];
    [self sendLocalNotificationForReqgionConfirmationWithText:@"REGION INSIDE"];
    [self setinrangeColor];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    NSLog(@"Exit Region  %@",region);
    [self sendLocalNotificationForReqgionConfirmationWithText:@"REGION OUTSIDE"];
    [_locationManager stopRangingBeaconsInRegion:region];
    [self setoutofrangeColor];
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    NSLog(@"Monitoring for %@",region);
    //[self sendLocalNotificationForReqgionConfirmationWithText:@"MONITORING STARTED"];
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    if (state == CLRegionStateInside) {
        [_locationManager startRangingBeaconsInRegion:region];
        [self sendLocalNotificationForReqgionConfirmationWithText:@"REGION INSIDE"];
        [self setinrangeColor];
    }
    else{
        //[[BluetoothManager shared] scan];
        [self sendLocalNotificationForReqgionConfirmationWithText:@"REGION OUTSIDE"];
        [_locationManager stopRangingBeaconsInRegion:region];
        [self setoutofrangeColor];
        
    }
    //[_locationManager startRangingBeaconsInRegion:region];
    
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    
    NSArray *unknownBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityUnknown]];
    if([unknownBeacons count]){
        NSLog(@"unknown beacons %@",unknownBeacons);
        [self setoutofrangeColor];
    }
    
    NSArray *immediateBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityImmediate]];
    if([immediateBeacons count]){
        NSLog(@"immediate beacons %@",immediateBeacons);
        [self setinrangeColor];
    }
    
    
    NSArray *nearBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityNear]];
    if([nearBeacons count]){
        NSLog(@"near beacons %@",nearBeacons);
        [self setinrangeColor];
        
    }
    
    
    NSArray *farBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityFar]];
    if([farBeacons count]){
        NSLog(@"far beacons %@",farBeacons);
        [self setfarrangeColor];
    }
    
}

-(void)sendLocalNotificationForReqgionConfirmationWithText:(NSString *)text {
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"%@", nil),
                            text];
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    
    localNotif.applicationIconBadgeNumber = 1;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:text forKey:@"KEY"];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification NS_AVAILABLE_IOS(4_0){
    UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:notification.alertBody message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}


@end
