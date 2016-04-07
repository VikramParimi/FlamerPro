//
//  MyTableViewCell.h
//  test
//
//  Created by Vinay Raja on 27/11/13.
//  Copyright (c) 2013 Vinay Raja. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RoundedImageView;
@interface MyTableViewCell : UITableViewCell
//@property(nonatomic,strong)  UIImageView *myImage;
@property(nonatomic,strong) RoundedImageView *roundImageView;
@property(nonatomic,strong) UILabel *lblName;
-(void)setImage:(UIImage *)image;

@end
