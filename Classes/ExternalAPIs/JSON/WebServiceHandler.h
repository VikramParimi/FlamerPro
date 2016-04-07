//
//  WebServiceHandler.h
//  HairToDo
//
//  Created by Sahil Khanna on 11/2/11.
//  Copyright 2011 3Embed. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol sendMessageDelegate <NSObject>
- (void) getServiceResponseDelegate :(NSDictionary *)responseDict serviceType:(int)type error:(NSError *)error;
@end

enum RequestType
{
    eParseKey = 1,
    eGetUpdatePrefrences
};

@interface WebServiceHandler : NSObject
{
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
	id target;
	SEL selector;
	NSTimer *timeOut;
}

@property(nonatomic,assign)id <sendMessageDelegate>delegate;
- (void)placeWebserviceRequestWithString:(NSMutableURLRequest *)string Target:(id)_target Selector:(SEL)_selector;
- (void)webserviceRequestAndResponse:(NSString *)stringMessage serviceType :(int)service facebookId:(NSString *)fId;
@property (nonatomic, assign)int requestType;

@end