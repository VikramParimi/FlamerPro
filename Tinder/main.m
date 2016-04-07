//
//  main.m
//  Tinder
//
//  Created by Rahul Sharma on 24/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Additions_568.h"

#import "TinderAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool
    {
         [UIImage patchImageNamedToSupport568Resources];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([TinderAppDelegate class]));
    }
}
