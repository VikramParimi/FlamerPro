//
//  CaptureMomentVC.m
//  Tinder
//
//  Created by Sanskar on 30/01/15.
//  Copyright (c) 2015 AppDupe. All rights reserved.
//

#import "CaptureMomentVC.h"


@interface CaptureMomentVC ()
{
    UIImagePickerController *imagePicker;
    UIImage *imgToSend;
    DrawingOnImageVC *drawVC;
}

@end

@implementation CaptureMomentVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [btnGalary.layer setCornerRadius:20.0];
    [btnGalary.layer setMasksToBounds:YES];
   // [btnGalary setImage:[self getMostRecentPicFromGalary] forState:UIControlStateNormal];
    
    imgVwCaptured.contentMode = UIViewContentModeScaleAspectFit;
   
    
    [imgVwCaptured setHidden:YES];
    
    //new code
    if ([self captureManager] == nil) {
        AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] init];
        [self setCaptureManager:manager];
    }
    [[self captureManager] setDelegate:self];
    
    if ([[self captureManager] setupSession])
    {
        // Create video preview layer and add it to the UI
        AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
        
        CALayer *viewLayer = [self.view layer];
        [viewLayer setMasksToBounds:YES];
        
        CGRect bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);//[view bounds];
        [newCaptureVideoPreviewLayer setFrame:bounds];
        
        [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
        
        [self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
        
        // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[[self captureManager] session] startRunning];
        });
    }
    
}



-(UIImage *)getMostRecentPicFromGalary
{
    __block UIImage *imgRecentPic = nil;
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                     if (nil != group) {
                                         // be sure to filter the group so you only get photos
                                         [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                         
                                         
                                         [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1]
                                                                 options:0
                                                              usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
                                                            {
                                                                  if (nil != result) {
                                                                      ALAssetRepresentation *repr = [result defaultRepresentation];
                                                                      // this is the most recent saved photo
                                                                      UIImage *img = [UIImage imageWithCGImage:[repr fullResolutionImage]];
                                                                      
                                                                      imgRecentPic = img;
                                                                      *stop = YES;
                                                                  }
                                                              }];
                                     }
                                     
                                     *stop = NO;
                                 } failureBlock:^(NSError *error) {
                                     NSLog(@"error: %@", error);
                                 }];
    return imgRecentPic;
}

- (IBAction)btnOnOffScreenTapped:(UIButton *)sender
{
     if (sender.selected) {
        [sender setSelected:NO];
        [[self captureManager] cameraFlashAction:1]; // camera flash mode OFF
    }else{
        [sender setSelected:YES];
        [[self captureManager] cameraFlashAction:2];  // camera flash mode ON
    }
}

- (IBAction)btnCancelTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnGalaryTapped:(id)sender
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePicker animated:NO completion:NULL];

}





- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}






- (UIImage *) imageByScalingToSize:(CGSize)targetSize forImage:(UIImage *)sourceImage
{
    UIImage *generatedImage = nil;
    //UIGraphicsBeginImageContextWithOptions(targetSize,NO,2.0);
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 5.0);
    
    [sourceImage drawInRect:CGRectMake(0, 0,targetSize.width,targetSize.height)];
    generatedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return generatedImage;
}





- (void) imagePickerController:(UIImagePickerController *)thePicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [[NSUserDefaults standardUserDefaults]setObject:@"from_camara" forKey:@"social"];
    
    
    
    UIImage *img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
  
    UIImage *finalImage = [self imageByScalingToSize:imgVwCaptured.frame.size forImage:img];
    
    
    
    
    [thePicker dismissViewControllerAnimated:NO completion:NULL];
    
    [imgVwCaptured setImage:finalImage];
    [imgVwCaptured setHidden:NO];
    [self showImageEditorWithImage:img];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Image Editor
-(void)showImageEditorWithImage : (UIImage *)image
{
    drawVC = [[DrawingOnImageVC alloc]init];
//    drawVC.view.frame = self.view.frame;
    drawVC.view.frame =  (self.view.frame);
    [drawVC addImageToEditor:image];
    [drawVC setDelegate:self];
    //  [self presentViewController:drawVC animated:YES completion:nil];
    
    //[[APPDELEGATE window] addSubview:drawVC.view];
     [self.view addSubview:drawVC.view];
     [drawVC didMoveToParentViewController:self];
     [self addChildViewController:drawVC];
}

-(void)hideImageEditorWithImage:(UIImage *)imgMoment
{
    [drawVC removeFromParentViewController];
    [drawVC.view removeFromSuperview];
}

#pragma mark - Drawing Vc Delegate
-(void)btnSubmitOnDrawingVCTappedWithImage:(UIImage *)imgMoment
{
    [self hideImageEditorWithImage:imgMoment];
    [self dismissViewControllerAnimated:NO completion:nil];
   
    if ([self.delegate respondsToSelector:@selector(hideCaptureVcWithMomentImage:)]) {
        [self.delegate hideCaptureVcWithMomentImage:imgMoment];
    }
}

-(void)btnCancelOnDrawingVCTapped
{
    [self hideImageEditorWithImage:nil];
    
    [btnGalary setImage:imgToSend forState:UIControlStateNormal];
    [imgVwCaptured setHidden:YES];
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[self captureManager] session] startRunning];
    });
}


- (IBAction)toggleCamera:(id)sender
{
    // Toggle between cameras when there is more than one
    [[self captureManager] toggleCamera];
    
    // Do an initial focus
    [[self captureManager] continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

- (IBAction)captureStillImage:(id)sender
{
    [[self captureManager] captureStillImage];
    
    UIView *flashView = [[UIView alloc] initWithFrame:[[self view] frame]];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [[[self view] window] addSubview:flashView];
    
    [UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                         //[flashView release];
                     }
     ];
}


#pragma mark - CaptureManagerDelegate -

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager Image:(UIImage *)image
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
       
        imgToSend =image;
        [self showImageEditorWithImage:imgToSend];
        
        [[[self captureManager] session] stopRunning];
        
    });
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
    //[self updateButtonStates];
}

#pragma mark - Methods To Hide StatusBar

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(BOOL)prefersStatusBarHidden   // iOS8 definitely needs this one. checked.
{
    return NO;
}

-(UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
