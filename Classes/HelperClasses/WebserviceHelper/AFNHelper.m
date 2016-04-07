//
//  AFNHelper.m
//  Tinder
//
//  Created by Elluminati - macbook on 04/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "AFNHelper.h"
#import "AFNetworking.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPRequestOperation.h"

#import "JSON.h"

@implementation AFNHelper

@synthesize strReqMethod;

#pragma mark -
#pragma mark - Init

- (id) initWithRequestMethod:(NSString *)method
{
    if ((self = [super init]))
    {
        self.strReqMethod=method;
    }
	return self;
}

#pragma mark -
#pragma mark - Post methods

-(void)getDataFromURL:(NSString *)url withBody:(NSMutableDictionary *)dictBody withBlock:(RequestCompletionBlock)block
{
    if (block)
    {
        dataBlock=[block copy];
    }
}

-(void)getDataFromPath:(NSString *)path withParamData:(NSMutableDictionary *)dictParam withBlock:(RequestCompletionBlock)block
{
    if (block)
    {
        dataBlock=[block copy];
    }
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",API_URL]];
    
    client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    //[client setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [client postPath:[NSString stringWithFormat:@"%@%@",API_URL,path]
          parameters:dictParam
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 DLog(@"response :%@",responseObject);
                 if (dataBlock)
                 {
                     dataBlock(responseObject,nil);
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 DLog(@"Error :%@",error);
                 if (dataBlock)
                 {
                     dataBlock(nil,error);
                 }
             }
     ];
}

#pragma mark -
#pragma mark - Post methods(multipart image)

-(void)getDataFromPath:(NSString *)path withParamDataImage:(NSMutableDictionary *)dictParam andImage:(UIImage *)image withBlock:(RequestCompletionBlock)block
{
    if (block)
    {
        dataBlock=[block copy];
    }
    
    /*
    NSData *imageToUpload = UIImageJPEGRepresentation(image, 0.5);
    
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",API_URL]];
    client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"upload.php" parameters:dictParam constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageToUpload name:@"avatar" fileName:@"avt.jpg" mimeType:@"image/png"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    [client enqueueHTTPRequestOperation:operation];
    */
    
    NSData *imageToUpload = UIImageJPEGRepresentation(image, 1.0);//(uploadedImgView.image);
    if (imageToUpload)
    {
        NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",API_URL]];
        client= [AFHTTPClient clientWithBaseURL:baseURL];
        
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:path parameters:dictParam constructingBodyWithBlock: ^(id <AFMultipartFormData>formData)
        {
            [formData appendPartWithFileData: imageToUpload name:@"file" fileName:@"temp.jpeg" mimeType:@"image/png"];
        }];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
             NSLog(@"response: %@",jsons);
             if (dataBlock)
             {
                 dataBlock(jsons,nil);
             }
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if (dataBlock)
             {
                 dataBlock(nil,error);
             }
             if([operation.response statusCode] == 403)
             {
                 NSLog(@"Upload Failed");
                 return;
             }
             NSLog(@"error: %@", [operation error]);
         }];
        
        [operation start];
    }
}

-(void)callWebserviceWithMethod:(NSString *)method andBody:(NSString *)body
{
    NSString *url=[NSString stringWithFormat:@"%@%@",API_URL,method];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    
    // This is how we set header fields
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Convert your data and set your request's HTTPBody property
    NSData *requestBodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    //NSString* jsonString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end
