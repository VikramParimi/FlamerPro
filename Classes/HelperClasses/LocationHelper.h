//
//  LocationHelper.h
//  Tinder
//
//  Created by Elluminati - macbook on 11/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^DidUpdateLocation)(CLLocation *newLocation,CLLocation *oldLocation,NSError *error);

@interface LocationHelper : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    DidUpdateLocation blockDidUpdate;
}
-(id)init;
+(LocationHelper *)sharedObject;

-(void)locationPermissionAlert;

-(void)startLocationUpdating;
-(void)stopLocationUpdating;

-(void)startLocationUpdatingWithBlock:(DidUpdateLocation)block;

@end
