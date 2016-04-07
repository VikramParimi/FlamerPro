//
//  SingleChatMessage.m
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "SingleChatMessage.h"

@implementation SingleChatMessage
@synthesize message,messageID,messageStatus,reciever,sender,mediaType;

-(id)initWithDict:(NSDictionary *)dictData
{
    self=[super init];
    if (self) {
        if (dictData) {
            
            messageID = [dictData objectForKey:@"msgID"];
            message=[dictData objectForKey:@"msg"];
            messageStatus=[dictData objectForKey:@"msgStatus"];
            sender=[dictData objectForKey:@"senderName"];
            reciever=[dictData objectForKey:@"recieverName"];
            mediaType =[dictData objectForKey:@"mediaType"];
        }
    }
    return self;
}

@end
