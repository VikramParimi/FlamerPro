#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

@interface CaptureSessionManager : NSObject {
    AVCaptureDeviceInput *frontFacingCameraDeviceInput;
}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) UIImage *stillImage;


- (void)addVideoPreviewLayer;
- (void)addVideoInput:(int)devicePosition;

- (void)addStillImageOutput;
- (void)captureStillImage;
//- (void)addVideoInputFrontCamera:(BOOL)front;

@end
