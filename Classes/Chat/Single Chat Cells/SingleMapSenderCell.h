//
//  SingleMapSenderCell.h
//  snapchatclone
//
//  Created by soumya ranjan sahu on 17/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import <MapKit/MapKit.h>
#import "LLARingSpinnerView.h"

@interface SingleMapSenderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *userImageView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chatImageView;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIView *spinnerBackView;
@property (weak, nonatomic) IBOutlet LLARingSpinnerView *spinnerView;

-(void)showmap_lat:(double)lat lng:(double)lng title:(NSString *)title;

@end
