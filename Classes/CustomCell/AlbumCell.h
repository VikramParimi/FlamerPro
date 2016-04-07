//
//  AlbumCell.h
//  FriendPickerSample
//
//  Created by Surender Rathore on 08/12/13.
//
//

#import <UIKit/UIKit.h>

@interface AlbumCell : UITableViewCell
@property (nonatomic,strong) UIImageView *albumCoverImage;
@property (nonatomic,strong) UILabel *albumName;
@property (nonatomic,strong) UILabel *albumPhotosCount;
@end
