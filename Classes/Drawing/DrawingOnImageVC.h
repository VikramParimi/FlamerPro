//
//  DrawingOnImageVC.h
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UICircularSlider.h"

@protocol DrawingOnImageVCDelegate<NSObject>

-(void)btnCancelOnDrawingVCTapped;
-(void)btnSubmitOnDrawingVCTappedWithImage:(UIImage *)imgMoment;

@end

typedef enum {
    OptionCOLOR,
    OptionFILTER,
    OptionTOOL
}EditingOption;

typedef enum {
    OptionUndo,
    OptionRedo,
    OptionClear
}ExtraOption;

@class ACEDrawingView;

@interface DrawingOnImageVC : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
{
    IBOutlet UIView *vwColorPicker;
    NSArray *filterNames;
    NSMutableArray *preFilterImages;
    NSArray *arrayTools;
    
    IBOutlet UIButton *btnExtraOptions;
    
    IBOutlet UIView *vwSliders;
    IBOutlet UIButton *btnCancel;
    IBOutlet UIButton *btnSend;
    IBOutlet UIButton *btnDownload;
}

@property (nonatomic,retain) id <DrawingOnImageVCDelegate> delegate;

@property (nonatomic, unsafe_unretained) IBOutlet ACEDrawingView *drawingView;
@property (nonatomic, unsafe_unretained) IBOutlet UICircularSlider *lineWidthSlider;
@property (nonatomic, unsafe_unretained) IBOutlet UICircularSlider *lineAlphaSlider;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UIImage *imgTOEdit;
@property (strong, atomic) ALAssetsLibrary* library;


- (IBAction)createMomentTapped:(id)sender;
- (IBAction)btnCancelTapped:(id)sender;

-(void)addImageToEditor:(UIImage *)imageToEdit;


@end
