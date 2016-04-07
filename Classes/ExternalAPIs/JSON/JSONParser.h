//
//  JSONParser.h
//  TopBuy
//
//  Created by Rahul Sharma on 10/04/13.
//  Copyright (c) 2013 Rahul Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONParser : NSObject

- (NSDictionary *)dictionaryWithContentsOfJSONURLString:(NSData*)data;




@end
