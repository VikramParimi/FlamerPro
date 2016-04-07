//
//  CaptureMomentVC.h
//  Tinder
//
//  Created by Sanskar on 30/01/15.
//  Copyright (c) 2015 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVCamCaptureManager.h"
#import "DrawingOnImageVC.h"

@protocol CaptureMomentVCDelegate <NSObject>

-(void)hideCaptureVcWithMomentImage:(UIImage*)imgMomentCreated;

@end

@interface CaptureMomentVC : UIViewController<UIImagePickerControllerDelegate,AVCamCaptureManagerDelegate,DrawingOnImageVCDelegate,UINavigationControllerDelegate>
{
    IBOutlet UIButton *onOffCameraBtn;
    IBOutlet UIButton *swithCameraBtn;
    IBOutlet UIButton *cancelBtn;
    
    IBOutlet UIButton *btnCapturePicture;
    IBOutlet UIButton *btnGalary;
    
    IBOutlet  UIImageView *imgVwCaptured;
}
@property (nonatomic,retain) id <CaptureMomentVCDelegate> delegate;
@property (nonatomic,retain) AVCamCaptureManager *captureManager;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@end
