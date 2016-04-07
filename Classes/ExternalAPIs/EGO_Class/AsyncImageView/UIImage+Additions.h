//
//  UIImage+Additions.h
//  PyaarIO
//
//  Created by Sanskar on 17/11/14.
//  Copyright (c) 2014 Doubbletap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (RoundedCorner)
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
@end

@interface UIImage (Alpha)
- (BOOL)hasAlpha;
- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
@end


@interface UIImage(Resize)

- (UIImage*) scaleToSize:(CGSize)size;
- (UIImage*)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage*) grayscaleImage;

- (UIImage*)croppedImage:(CGRect)bounds;
- (UIImage*)thumbnailImage:(NSInteger)thumbnailSize
         transparentBorder:(NSUInteger)borderSize
              cornerRadius:(NSUInteger)cornerRadius
      interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage*)resizedImage:(CGSize)newSize
    interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage*)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                 bounds:(CGSize)bounds
                   interpolationQuality:(CGInterpolationQuality)quality;

@end