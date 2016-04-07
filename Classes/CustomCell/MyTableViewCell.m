//
//  MyTableViewCell.m
//  test
//
//  Created by Vinay Raja on 27/11/13.
//  Copyright (c) 2013 Vinay Raja. All rights reserved.
//

#import "MyTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "RoundedImageView.h"

@interface MyTableViewCell ()
{
    
}

@end

@implementation MyTableViewCell
@synthesize  roundImageView;
@synthesize lblName;
//@synthesize myImage;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Initialization code
        CGFloat k90DegreesClockwiseAngle = (CGFloat) (90 * M_PI / 180.0);
        
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, k90DegreesClockwiseAngle);

        roundImageView = [[RoundedImageView alloc] initWithFrame:CGRectMake(0, 10, 59, 60)];
        //roundImageView.contentMode = UIViewContentModeCenter;
        //roundImageView.clipsToBounds = YES;
        //[roundImageView.layer setCornerRadius:8];
       
        self.selectionStyle = UITableViewCellSelectionStyleNone;
//        
//        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//        
//        CGRect maskBounds = CGRectMake(0, 0, 70, 70);
//        CGPathRef maskPath = CGPathCreateWithEllipseInRect(maskBounds, NULL);
//        maskLayer.bounds = maskBounds;
//        [maskLayer setPath:maskPath];
//        [maskLayer setFillColor:[[UIColor whiteColor] CGColor]];
//        maskLayer.position = CGPointMake(maskBounds.size.width/2, maskBounds.size.height/2);
        
       // [roundImageView.layer setMask:maskLayer];
        [self.contentView addSubview:roundImageView];
        
//        self.layer.borderWidth = 0.0f;
//        self.layer.borderColor = [[UIColor redColor] CGColor];
//        self.backgroundView = nil;
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 70, 40)];
        self.lblName.textAlignment = NSTextAlignmentCenter;
        self.lblName.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblName.numberOfLines = 2;
        [Helper setToLabel:self.lblName Text:nil WithFont:HELVETICALTSTD_LIGHT FSize:9 Color:[Helper getColorFromHexString:@"#7c7c7c" :1.0]];
        [self.contentView addSubview:self.lblName];
        
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setImage:(UIImage *)image
{
    roundImageView.image = image;
}


@end
