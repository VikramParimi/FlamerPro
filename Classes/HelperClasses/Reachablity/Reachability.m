
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <netdb.h>

#import "Reachability.h"
#import <SystemConfiguration/SCNetworkReachability.h>

//static NSString *kLinkLocalAddressKey = @"169.254.0.0";
static NSString *kDefaultRouteKey = @"0.0.0.0";

static Reachability *_sharedReachability;

// A class extension that declares internal methods for this class.
@interface Reachability()
//- (BOOL)isAdHocWiFiNetworkAvailableFlags:(SCNetworkReachabilityFlags *)outFlags;
- (BOOL)isNetworkAvailableFlags:(SCNetworkReachabilityFlags *)outFlags;
- (BOOL)isReachableWithoutRequiringConnection:(SCNetworkReachabilityFlags)flags;
- (void)stopListeningForReachabilityChanges;
@end

@implementation Reachability

@synthesize networkStatusNotificationsEnabled = _networkStatusNotificationsEnabled;
@synthesize reachabilityQueries = _reachabilityQueries;

+ (Reachability *)sharedReachability
{
	@synchronized(self) {
	if (!_sharedReachability) {
		_sharedReachability = [[Reachability alloc] init];
		_sharedReachability.networkStatusNotificationsEnabled = NO;
		_sharedReachability.reachabilityQueries = [[NSMutableDictionary alloc] init];
	}
	}
	return _sharedReachability;
}



- (void) dealloc
{	
    [self stopListeningForReachabilityChanges];
    
	[_sharedReachability.reachabilityQueries release];
	[_sharedReachability release];
	[super dealloc];
}


- (BOOL)isReachableWithoutRequiringConnection:(SCNetworkReachabilityFlags)flags
{
    // kSCNetworkReachabilityFlagsReachable indicates that the specified nodename or address can
	// be reached using the current network configuration.
	BOOL isReachable = flags & kSCNetworkReachabilityFlagsReachable;
	
	BOOL noConnectionRequired = !(flags & kSCNetworkReachabilityFlagsConnectionRequired);
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN)) {
		noConnectionRequired = YES;
	}
	
	return (isReachable && noConnectionRequired) ? YES : NO;
}


// ReachabilityCallback is registered as the callback for network state changes in startListeningForReachabilityChanges.
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNetworkReachabilityChangedNotification" object:nil];
	
	[pool release];
}

// Perform a reachability query for the address 0.0.0.0. If that address is reachable without
// requiring a connection, a network interface is available. We'll have to do more work to
// determine which network interface is available.
- (BOOL)isNetworkAvailableFlags:(SCNetworkReachabilityFlags *)outFlags
{
	ReachabilityQuery *query = [self.reachabilityQueries objectForKey:kDefaultRouteKey];
	SCNetworkReachabilityRef defaultRouteReachability = query.reachabilityRef;
	
    // If a cached reachability query was not found, create one.
    if (!defaultRouteReachability) {
        
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        
        defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
		
		ReachabilityQuery *query = [[[ReachabilityQuery alloc] init] autorelease];
		//query.hostNameOrAddress = kDefaultRouteKey;
		query.reachabilityRef = defaultRouteReachability;
		
		[self.reachabilityQueries setObject:query forKey:kDefaultRouteKey];
    }
	[query scheduleOnRunLoop:[NSRunLoop currentRunLoop]];
	
	SCNetworkReachabilityFlags flags;
	BOOL gotFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	if (!gotFlags) {
        return NO;
    }
    
	BOOL isReachable = [self isReachableWithoutRequiringConnection:flags];
	
	// Callers of this method might want to use the reachability flags, so if an 'out' parameter
	// was passed in, assign the reachability flags to it.
	if (outFlags) {
		*outFlags = flags;
	}
	
	return isReachable;
}

// Be a good citizen and unregister for network state changes when the application terminates.
- (void)stopListeningForReachabilityChanges
{
	// Walk through the cache that holds SCNetworkReachabilityRefs for reachability
	// queries to particular hosts or addresses.
	NSEnumerator *enumerator = [self.reachabilityQueries objectEnumerator];
	ReachabilityQuery *reachabilityQuery;
    
	while (reachabilityQuery = [enumerator nextObject]) {
		
		CFArrayRef runLoops = reachabilityQuery.runLoops;
		NSUInteger runLoopCounter, maxRunLoops = CFArrayGetCount(runLoops);
        
		for (runLoopCounter = 0; runLoopCounter < maxRunLoops; runLoopCounter++) {
			CFRunLoopRef nextRunLoop = (CFRunLoopRef)CFArrayGetValueAtIndex(runLoops, runLoopCounter);
			
			SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityQuery.reachabilityRef, nextRunLoop, kCFRunLoopDefaultMode);
		}
        
        CFArrayRemoveAllValues(reachabilityQuery.runLoops);
	}
}

- (NSUInteger)internetConnectionStatus
{
	
	SCNetworkReachabilityFlags defaultRouteFlags;
	BOOL defaultRouteIsAvailable = [self isNetworkAvailableFlags:&defaultRouteFlags];
	if (defaultRouteIsAvailable) {
        
		if (defaultRouteFlags & kSCNetworkReachabilityFlagsIsDirect) {
            
			// The connection is to an ad-hoc WiFi network, so Internet access is not available.
			return 0;
		}
		else if (defaultRouteFlags & ReachableViaCarrierDataNetwork) {
			return 1;
		}
		else if (defaultRouteFlags & ReachableViaWiFiNetwork)
		{			
		return 2;
		}
	 else
		 return 3;
	}
	
	return 0;
}

@end

@interface ReachabilityQuery ()
- (CFRunLoopRef)startListeningForReachabilityChanges:(SCNetworkReachabilityRef)reachability onRunLoop:(CFRunLoopRef)runLoop;
@end

@implementation ReachabilityQuery

@synthesize reachabilityRef = _reachabilityRef;
@synthesize runLoops = _runLoops;
//@synthesize hostNameOrAddress = _hostNameOrAddress;

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.runLoops = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
	}
	return self;
}

- (void)dealloc
{
	CFRelease(self.runLoops);
	[super dealloc];
}

- (BOOL)isScheduledOnRunLoop:(CFRunLoopRef)runLoop
{
	NSUInteger runLoopCounter, maxRunLoops = CFArrayGetCount(self.runLoops);
	
	for (runLoopCounter = 0; runLoopCounter < maxRunLoops; runLoopCounter++) {
		CFRunLoopRef nextRunLoop = (CFRunLoopRef)CFArrayGetValueAtIndex(self.runLoops, runLoopCounter);
		
		if (nextRunLoop == runLoop) {
			return YES;
		}
	}
	
	return NO;
}

- (void)scheduleOnRunLoop:(NSRunLoop *)inRunLoop
{
	// Only register for network state changes if the client has specifically enabled them.
	if ([[Reachability sharedReachability] networkStatusNotificationsEnabled] == NO) {
		return;
	}
	
	if (!inRunLoop) {
		return;
	}
	
	CFRunLoopRef runLoop = [inRunLoop getCFRunLoop];
	
	
	if (![self isScheduledOnRunLoop:runLoop]) {
        
		CFRunLoopRef notificationRunLoop = [self startListeningForReachabilityChanges:self.reachabilityRef onRunLoop:runLoop];
		if (notificationRunLoop) {
			CFArrayAppendValue(self.runLoops, notificationRunLoop);
		}
	}
}

// Register to receive changes to the 'reachability' query so that we can update the
// user interface when the network state changes.
- (CFRunLoopRef)startListeningForReachabilityChanges:(SCNetworkReachabilityRef)reachability onRunLoop:(CFRunLoopRef)runLoop
{	
	if (!reachability) {
		return NULL;
	}
	
	if (!runLoop) {
		return NULL;
	}
    
	SCNetworkReachabilityContext	context = {0, self, NULL, NULL, NULL};
	SCNetworkReachabilitySetCallback(reachability, ReachabilityCallback, &context);
	SCNetworkReachabilityScheduleWithRunLoop(reachability, runLoop, kCFRunLoopDefaultMode);
	
	return runLoop;
}


@end
