//
//  SingleChatMessage.h
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleChatMessage : NSObject

@property(nonatomic,copy) NSString *message;
@property(nonatomic,copy) NSString *messageID;
@property(nonatomic,copy) NSString *messageStatus;
@property(nonatomic,copy) NSString *reciever;
@property(nonatomic,copy) NSString *sender;
@property(nonatomic,copy) NSString *mediaType;

-(id)initWithDict:(NSDictionary *)dictData;
@end
