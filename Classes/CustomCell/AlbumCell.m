//
//  AlbumCell.m
//  FriendPickerSample
//
//  Created by Surender Rathore on 08/12/13.
//
//

#import "AlbumCell.h"

@implementation AlbumCell
@synthesize albumName;
@synthesize albumPhotosCount;
@synthesize albumCoverImage;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        // album cover image
        self.albumCoverImage = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 58, 58)];
        self.albumCoverImage.contentMode = UIViewContentModeScaleToFill;
        self.albumCoverImage.clipsToBounds = YES;
        
        [self.contentView addSubview:self.albumCoverImage];
        
        //album name
        self.albumName = [[UILabel alloc] initWithFrame:CGRectMake(77, 15, 280, 20)];
        self.albumName.backgroundColor = CLEAR_COLOR;
        [Helper setToLabel:self.albumName Text:nil WithFont:HELVETICALTSTD_LIGHT FSize:18 Color:[Helper getColorFromHexString:@"#666666" :1.0]];
        [self.contentView addSubview:self.albumName];
        
        //album photocount
        
        self.albumPhotosCount = [[UILabel alloc] initWithFrame:CGRectMake(77, 35, 280, 20)];
        self.albumPhotosCount.backgroundColor = CLEAR_COLOR;
        [self.contentView addSubview:self.albumPhotosCount];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
