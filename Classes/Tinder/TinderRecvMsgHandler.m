//
//  TinderRecvMsgHandler.m
//  Flamer Pro
//
//  Created by Caroll on 3/28/16.
//  Copyright © 2016 AppDupe. All rights reserved.
//

#import "TinderRecvMsgHandler.h"
#import "AllConstants.h"
#import "EBTinderClient.h"

#import "XmppCommunicationHandler.h"
#import "SingleChatMessage.h"
#import "EBTinderClient.h"

@implementation TinderRecvMsgHandler

+ (instancetype)sharedClient
{
    static id shared = nil;
    if (!shared){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[self alloc] init];            
        });
    }
    return shared;
}

-(id)init
{
    self = [super init];
    self.bStart = NO;
    return self;
}

- (void) startReceivingMsgs
{
    self.bStart = YES;
    [self startOneOffTimer:nil];
}

- (void) stopReceivingMsgs
{
    self.bStart = NO;
}

// timer example functions.
- (NSDictionary *)userInfo {
    return @{ @"StartDate" : [NSDate date] };
}

- (void)targetMethod:(NSTimer*)theTimer {
    
    [[EBTinderClient sharedClient] receiveMessage: (RecieveMessageBlock)^(NSArray* dict, BOOL success){
        
        if (success && (dict != nil))
        {
            for (SingleChatMessage* msg in dict)
            {
              [[XmppCommunicationHandler sharedInstance] saveSingleChatMessage:msg.reciever Sender:msg.sender Message:msg.message MessageID:msg.messageID MediaType:@"W"];
            }
            
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_TINDER_UPDATE_MESSAGE_COUNTER object:dict userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveMessage" object:nil];
            if (self.bStart)
                [self startOneOffTimer:nil];
        }
    }];
    
  //  NSDate *startDate = [[theTimer userInfo] objectForKey:@"StartDate"];
  //  NSLog(@"Timer started on %@", startDate);
}

- (void)invocationMethod:(NSDate *)date {
    NSLog(@"Invocation for timer started on %@", date);
}

- (IBAction)startOneOffTimer:sender {
    
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(targetMethod:)
                                   userInfo:[self userInfo]
                                    repeats:NO];
}


- (IBAction)startRepeatingTimer:sender {
    
    // Cancel a preexisting timer.
    [self.repeatingTimer invalidate];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self selector:@selector(targetMethod:)
                                                    userInfo:[self userInfo] repeats:YES];
    self.repeatingTimer = timer;
}

- (IBAction)createUnregisteredTimer:sender {
    
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:@selector(invocationMethod:)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:self];
    [invocation setSelector:@selector(invocationMethod:)];
    NSDate *startDate = [NSDate date];
    [invocation setArgument:&startDate atIndex:2];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 invocation:invocation repeats:YES];
    self.unregisteredTimer = timer;
}

- (IBAction)startUnregisteredTimer:sender {
    
    if (self.unregisteredTimer != nil) {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:self.unregisteredTimer forMode:NSDefaultRunLoopMode];
    }
}

- (IBAction)startFireDateTimer:sender {
    
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:fireDate
                                              interval:0.5
                                                target:self
                                              selector:@selector(countedTimerFireMethod:)
                                              userInfo:[self userInfo]
                                               repeats:YES];
    
    self.timerCount = 1;
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (IBAction)stopRepeatingTimer:sender {
    [self.repeatingTimer invalidate];
    self.repeatingTimer = nil;
}

- (IBAction)stopUnregisteredTimer:sender {
    [self.unregisteredTimer invalidate];
    self.unregisteredTimer = nil;
}

- (void)countedTimerFireMethod:(NSTimer*)theTimer {
    
    NSDate *startDate = [[theTimer userInfo] objectForKey:@"StartDate"];
    NSLog(@"Timer started on %@; fire count %d", startDate, self.timerCount);
    
    self.timerCount++;
    if (self.timerCount > 3) {
        [theTimer invalidate];
    }
}

@end
