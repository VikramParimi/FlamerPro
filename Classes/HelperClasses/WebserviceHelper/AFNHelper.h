//
//  AFNHelper.h
//  Tinder
//
//  Created by Elluminati - macbook on 04/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONParser.h"
#import "AFHTTPClient.h"

typedef void (^RequestCompletionBlock)(id response, NSError *error);

@interface AFNHelper : NSObject<NSURLConnectionDelegate>
{
    NSMutableData *webData;
    
    NSMutableData *_responseData;
    
    //for ASIRequest
    AFHTTPClient *client;
    
    NSString *strReqMethod;
    //blocks
    RequestCompletionBlock dataBlock;
}
@property(nonatomic,copy)NSString *strReqMethod;

- (id) initWithRequestMethod:(NSString *)method;

-(void)getDataFromURL:(NSString *)url withBody:(NSMutableDictionary *)dictBody withBlock:(RequestCompletionBlock)block;

-(void)getDataFromPath:(NSString *)path withParamData:(NSMutableDictionary *)dictParam withBlock:(RequestCompletionBlock)block;

-(void)getDataFromPath:(NSString *)path withParamDataImage:(NSMutableDictionary *)dictParam andImage:(UIImage *)image withBlock:(RequestCompletionBlock)block;

-(void)callWebserviceWithMethod:(NSString *)method andBody:(NSString *)body;

@end
