//
//  TinderRecvMsgHandler.h
//  Flamer Pro
//
//  Created by Caroll on 3/28/16.
//  Copyright © 2016 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TinderRecvMsgHandler : NSObject


+ (instancetype)sharedClient;

// The repeating timer is a weak property.
@property (weak) NSTimer *repeatingTimer;
@property (strong) NSTimer *unregisteredTimer;
@property NSUInteger timerCount;
@property BOOL bStart;

- (IBAction)startOneOffTimer:sender;

- (IBAction)startRepeatingTimer:sender;
- (IBAction)stopRepeatingTimer:sender;

- (IBAction)createUnregisteredTimer:sender;
- (IBAction)startUnregisteredTimer:sender;
- (IBAction)stopUnregisteredTimer:sender;

- (IBAction)startFireDateTimer:sender;

- (void)targetMethod:(NSTimer*)theTimer;
- (void)invocationMethod:(NSDate *)date;
- (void)countedTimerFireMethod:(NSTimer*)theTimer;

- (NSDictionary *)userInfo;

@end
