
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>

@class Reachability;

@interface Reachability : NSObject {
    
@private
	BOOL _networkStatusNotificationsEnabled;
	    
	NSMutableDictionary *_reachabilityQueries;
}

/*
 An enumeration that defines the return values of the network state
 of the device.
 */
typedef enum {
	NotReachable = 0,
	ReachableViaCarrierDataNetwork,
	ReachableViaWiFiNetwork
} NetworkStatus;


@property BOOL networkStatusNotificationsEnabled;

// A cache of ReachabilityQuery objects, which encapsulate a SCNetworkReachabilityRef, a host or address, and a run loop. The keys are host names or addresses.
@property (nonatomic, assign) NSMutableDictionary *reachabilityQueries;

// This class is intended to be used as a singleton.
+ (Reachability *)sharedReachability;
- (NSUInteger)internetConnectionStatus;

//static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info);
@end

@interface ReachabilityQuery : NSObject
{
@private
	SCNetworkReachabilityRef _reachabilityRef;
	CFMutableArrayRef _runLoops;
	NSString *_hostNameOrAddress;
}
// Keep around each network reachability query object so that we can
// register for updates from those objects.
@property (nonatomic) SCNetworkReachabilityRef reachabilityRef;
//@property (nonatomic, retain) NSString *hostNameOrAddress;
@property (nonatomic) CFMutableArrayRef runLoops;

- (void)scheduleOnRunLoop:(NSRunLoop *)inRunLoop;

@end

