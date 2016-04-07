//
//  ActivityTableCell.m
//  Tinder
//
//  Created by Sanskar on 05/01/15.
//  Copyright (c) 2015 AppDupe. All rights reserved.
//

#import "ActivityTableCell.h"

@implementation ActivityTableCell

- (void)awakeFromNib
{
    [_imgMoment.layer setCornerRadius:5.0];
    [_imgMoment.layer setMasksToBounds:YES];
    [_imgUserPic.layer setCornerRadius:_imgUserPic.frame.size.width/2];
    [_imgUserPic.layer setMasksToBounds:YES];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setDataInCellForActivity : (Activity *)activity
{
    
    [_imgUserPic setShowActivity:YES];
    [_imgUserPic setImageURL : [NSURL URLWithString:activity.activity_Creator_profilePic]];
    [_imgMoment setShowActivity:YES];
    [_imgMoment setImageURL : [NSURL URLWithString:activity.activity_image]];
    
    if ([activity.activity_type isEqualToString:@"like_moment"]) {
         [_lblActivityName setText:@"liked your moment"];
    }

    NSDate *dateCreated = [[UtilityClass sharedObject]stringToDate:activity.activity_Created_date withFormate:@"yyyy-MM-dd HH:mm:ss"];
    NSString *difference = [[UtilityClass sharedObject]prettyTimestampSinceDate:dateCreated];
    
    NSString *strNameAndTime = [NSString stringWithFormat:@"%@ %@",activity.activity_Creator_firstName,difference];
    
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc]initWithString:strNameAndTime];
    [attrStr addAttribute:NSForegroundColorAttributeName value:RED_STRIP_COLOR range:NSMakeRange(0,activity.activity_Creator_firstName.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange([strNameAndTime rangeOfString:difference].location,difference.length)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange([strNameAndTime rangeOfString:difference].location,difference.length)];
    
    [_lblUserAndTime setAttributedText:attrStr];
    
}


-(void)setDataInCellForLike : (NSDictionary *)dictLike
{
    [_imgUserPic setShowActivity:YES];
    [_imgUserPic setImageURL : [NSURL URLWithString:[dictLike objectForKey:@"profile_pic_url"]]];
    [_imgMoment setHidden:YES];
    [_lblActivityName setText:@"liked your moment"];
       
    NSDate *dateCreated = [[UtilityClass sharedObject]stringToDate:[dictLike objectForKey:@"created_date"] withFormate:@"yyyy-MM-dd HH:mm:ss"];
    NSString *difference = [[UtilityClass sharedObject]prettyTimestampSinceDate:dateCreated];
    
    NSString *strNameAndTime = [NSString stringWithFormat:@"%@ %@",[dictLike objectForKey:@"first_name"],difference];
    
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc]initWithString:strNameAndTime];
    [attrStr addAttribute:NSForegroundColorAttributeName value:RED_STRIP_COLOR range:NSMakeRange(0,[[dictLike objectForKey:@"first_name"] length])];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange([strNameAndTime rangeOfString:difference].location,difference.length)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange([strNameAndTime rangeOfString:difference].location,difference.length)];
    
    [_lblUserAndTime setAttributedText:attrStr];

}

@end
