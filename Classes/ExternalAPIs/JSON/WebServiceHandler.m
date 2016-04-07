//
//  WebServiceHandler.m
//  HairToDo
//
//  Created by Sahil Khanna on 11/2/11.
//  Copyright 2011 3Embed. All rights reserved.
//

#import "WebServiceHandler.h"
#import "JSONParser.h"
#import "AFNetworking.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

enum serviceType
{
    MatchedProfile = 1,
    SendMessage = 2,
    GetMessage = 3,
    BlockUSer =4,
    UnBlockUser
};

@implementation WebServiceHandler

@synthesize requestType;
@synthesize delegate;

#pragma mark -
#pragma mark Connection Delegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    id result;
    timeOut = nil;
	JSONParser *parser = [[JSONParser alloc] init];
    
    NSString *strRespone= [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    DLog(@"strRespone = %@",strRespone);
    
    if (self.requestType== eParseKey)
    {
		result = [parser dictionaryWithContentsOfJSONURLString:responseData];
	}
	if ([result count]==0)
    {
		[target performSelectorOnMainThread:selector withObject:nil waitUntilDone:YES];
	}
	else
    {
        if ([[result objectForKey:@"errFlag"] intValue]==0 && [[result objectForKey:@"errNum"] intValue] == 18)
        {
           
        }
        else
        {
            [target performSelectorOnMainThread:selector withObject:[NSDictionary dictionaryWithObject:result forKey:@"ItemsList"] waitUntilDone:YES];
        }
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    timeOut = nil;
	
	[target performSelectorOnMainThread:selector withObject:[NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"Error"] waitUntilDone:NO];
}

#pragma mark -
#pragma mark - Other Methods

- (void)placeWebserviceRequestWithString:(NSMutableURLRequest *)string Target:(id)_target Selector:(SEL)_selector
{
	urlConnection = [[NSURLConnection alloc] initWithRequest:string delegate:self];
	timeOut = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(cancelDownload) userInfo:nil repeats:NO];
	responseData = [[NSMutableData alloc] init];
	target = _target;
	selector = _selector;
}

- (void) cancelDownload
{
	if (timeOut == nil)
    {
		return;
	}
	else
    {
		[urlConnection cancel];
		[target performSelectorOnMainThread:selector withObject:[NSDictionary dictionaryWithObject:@"Connection Timed-out" forKey:@"Error"] waitUntilDone:NO];
		timeOut = nil;
	}
}

- (void)webserviceRequestAndResponse:(NSString *)stringMessage serviceType:(int)service facebookId:(NSString *)fId
{
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",API_URL]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
   
    NSString *strUUID=[[UserDefaultHelper sharedObject] uuid];
    NSDictionary *parameters = nil;
    NSString *serviceString = nil;
    switch (service)
    {
        case MatchedProfile:
        {
            serviceString = METHOD_GETPROFILEMATCHES;
            NSString *strTime=[[NSUserDefaults standardUserDefaults] objectForKey:@"JOINED"];
            if(strTime==nil)
            {
                strTime=@"";
            }
            parameters = @{PARAM_ENT_SESS_TOKEN:[[UserDefaultHelper sharedObject] facebookToken], PARAM_ENT_DEV_ID:strUUID,PARAM_ENT_DATETIME:strTime};
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
             NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
            
            [[NSUserDefaults standardUserDefaults]setObject:timeStamp forKey:@"JOINED"];
            break;
        }
        case SendMessage:
        {
            serviceString = METHOD_SENDMESSAGE;
            parameters = @{PARAM_ENT_SESS_TOKEN:[[UserDefaultHelper sharedObject] facebookToken], PARAM_ENT_DEV_ID:strUUID,PARAM_ENT_USER_FBID:fId,PARAM_ENT_MEDIA_CHUNK:stringMessage};
            
            break;
        }
        case GetMessage:
        {
            serviceString = METHOD_GETCHATHISTORY;
            parameters = @{PARAM_ENT_SESS_TOKEN:[[UserDefaultHelper sharedObject] facebookToken], PARAM_ENT_DEV_ID:strUUID,PARAM_ENT_USER_FBID:fId,PARAM_ENT_CHAT_PAGE:@"1"};
            
            break;
        }
        case BlockUSer:
        {
            serviceString = METHOD_BLOCKUSER;
            parameters = @{PARAM_ENT_USER_FBID:[User currentUser].fbid,PARAM_ENT_USER_BLOCK_FBID:fId,PARAM_ENT_FLAG:@"4"};
            break;
        }
        case UnBlockUser:
        {
            serviceString = METHOD_BLOCKUSER;
            parameters = @{PARAM_ENT_USER_FBID:[User currentUser].fbid,PARAM_ENT_USER_BLOCK_FBID:fId,PARAM_ENT_FLAG:@"3"};
            break;
        }
        default:
            break;
    }
    [client postPath:[NSString stringWithFormat:@"%@%@",API_URL,serviceString]
          parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 DLog(@"response :%@",responseObject);
                 if ([delegate respondsToSelector:@selector(getServiceResponseDelegate:serviceType:error:)]) {
                      [delegate getServiceResponseDelegate:responseObject serviceType:service error:nil];
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 DLog(@"Error :%@",error);
                 [delegate getServiceResponseDelegate:nil serviceType:service error:error];
             }
     ];
}

@end
