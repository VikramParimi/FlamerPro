//
//  DrawingOnImageVC.m
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "DrawingOnImageVC.h"
#import "ACEDrawingView.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorCell.h"
#import "ADCircularMenuViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "DWBubbleMenuButton.h"

#define kActionSheetColor       100
#define kActionSheetTool        101


#define ScreenSize [UIScreen mainScreen].bounds.size

#define ArrayColor @[[UIColor colorWithRed:253.0/255.0 green:183.0/255.0 blue:63.0/255.0 alpha:1.0],[UIColor colorWithRed:241.0/255.0 green:89.0/255.0 blue:40.0/255.0 alpha:1.0],[UIColor colorWithRed:53.0/255.0 green:152.0/255.0 blue:220.0/255.0 alpha:1.0],[UIColor colorWithRed:255.0/255.0 green:228.0/255.0 blue:0.0/255.0 alpha:1.0],[UIColor colorWithRed:27.0/255.0 green:188.0/255.0 blue:55.0/255.0 alpha:1.0],[UIColor colorWithRed:214.0/255.0 green:214.0/255.0 blue:.0/255.0 alpha:1.0]]

@interface DrawingOnImageVC ()<UIActionSheetDelegate, ACEDrawingViewDelegate,ADCircularMenuDelegate,DWBubbleMenuViewDelegate,UIGestureRecognizerDelegate>
{
    int flgForSelectionOption;
    
    ADCircularMenuViewController *circularMenuVC;
    DWBubbleMenuButton *bubbleMenuDown;
    DWBubbleMenuButton *bubbleTextOptionsMenuDown;
    CGRect selectedRectFrame;
    UIImageView *imgVwSaveImg;
}

@end

@implementation DrawingOnImageVC
@synthesize library;

static NSString * const cellIdentifier = @"ColorCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set the delegate
    self.drawingView.delegate = self;
    
    // start with a black pen
    self.lineWidthSlider.value = self.drawingView.lineWidth;
    
    
    [self.collectionView registerClass:[ColorCell class] forCellWithReuseIdentifier:cellIdentifier];
    
    filterNames = @[@"CIPhotoEffectChrome", @"CIPhotoEffectFade", @"CIPhotoEffectInstant",
                    @"CIPhotoEffectMono", @"CIPhotoEffectNoir", @"CIPhotoEffectProcess",
                    @"CIPhotoEffectTonal", @"CIPhotoEffectTransfer"];
    
    arrayTools = @[@"pen.png", @"line.png",
                   @"rect_stroke.png", @"rect_fill.png",
                   @"ellipse_stroke.png", @"ellipse_fill.png",
                   @"eraser.png", @"text.png"];
    
   
    [self initialSetupView];
    
    [self addBubbleMenu];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

-(void)initialSetupView
{
    UIGestureRecognizer * _gestureRecognizerTap = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(handleSingleTap:)];
    _gestureRecognizerTap.cancelsTouchesInView = NO;
    _gestureRecognizerTap.delegate = self;
    [vwColorPicker addGestureRecognizer:_gestureRecognizerTap];
    
    UIGestureRecognizer * gestureRecognizerTap = [[UITapGestureRecognizer alloc]
                                                  initWithTarget:self action:@selector(handleSingleTap:)];
    gestureRecognizerTap.cancelsTouchesInView = NO;
    gestureRecognizerTap.delegate = self;
    
    [vwSliders addGestureRecognizer:gestureRecognizerTap];
    
    
    //self.collectionView.backgroundColor = [Helper getColorFromHexString:@"#333333" :1.0];
    btnExtraOptions.backgroundColor = [UIColor whiteColor];
    [btnExtraOptions.layer setCornerRadius:20];
    [btnCancel.layer setCornerRadius:20];
    [btnSend.layer setCornerRadius:40];
    [btnDownload.layer setCornerRadius:20];
    
    [btnExtraOptions.layer setMasksToBounds:YES];
    [btnSend.layer setMasksToBounds:YES];
    [btnCancel.layer setMasksToBounds:YES];
    [btnDownload.layer setMasksToBounds:YES];
    
    self.library = [[ALAssetsLibrary alloc] init];
    
    [self.lineAlphaSlider addTarget:self action:@selector(alphaChange:) forControlEvents:UIControlEventValueChanged];
    self.lineAlphaSlider.minimumValue = 0.1;
    self.lineAlphaSlider.maximumValue =1.0;
    self.lineAlphaSlider.value = 1.0;
    self.lineAlphaSlider.continuous = NO;
    
    [self.lineWidthSlider addTarget:self action:@selector(widthChange:) forControlEvents:UIControlEventValueChanged];
    self.lineWidthSlider.minimumValue = 1;
    self.lineWidthSlider.maximumValue = 20;
    self.lineWidthSlider.value = 10;
    self.lineWidthSlider.continuous = NO;
}

-(void)addBubbleMenu
{
    // Create down menu button
    
    UIButton *menuButton = [self createMenuButtonViewWithImage:[UIImage imageNamed:@"menuIcon.png"] optionalText:@"Menu"];
    
    CGRect frame = CGRectMake(ScreenSize.width-50, 10, 40, 40);
    
    bubbleMenuDown = [[DWBubbleMenuButton alloc] initWithFrame:frame
                                                                expansionDirection:DirectionDown];
    
    bubbleMenuDown.homeButtonView = menuButton;
    
    NSArray *imageList = @[@"no",@"icon_option_filters.png",@"pen.png",@"width.png",@"alpha.png"];
    
    NSArray *btnsArray = [self createMenuButtonArrayWithImageArray:imageList];
  
    for (UIButton *button in btnsArray)
    {
         [button addTarget:self action:@selector(bubbleMenuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
   
    [bubbleMenuDown addButtons:btnsArray];
    [bubbleMenuDown setDelegate:self];
    
    [self.view addSubview:bubbleMenuDown];

}

-(void)addTextOptionsMenu
{
    // Create down menu button
    
    [bubbleTextOptionsMenuDown removeFromSuperview];
    
    UIButton *menuButton = [self createMenuButtonViewWithImage:[UIImage imageNamed:@"text.png"] optionalText:@"Text"];
    
   
    CGRect frame = CGRectMake(ScreenSize.width/2-20, 10, 40, 40);
    bubbleTextOptionsMenuDown = [[DWBubbleMenuButton alloc] initWithFrame:frame
                                            expansionDirection:DirectionDown];
    
    bubbleTextOptionsMenuDown.homeButtonView = menuButton;
    
    
    NSArray *imageList = @[@"align_justify.png",@"align-center.png",@"align-left.png",@"align-right.png"];
    NSArray *btnsArray = [self createMenuButtonArrayWithImageArray:imageList];
    
    for (UIButton *button in btnsArray)
    {
        [button addTarget:self action:@selector(bubbleTextOptionsTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [bubbleTextOptionsMenuDown addButtons:btnsArray];
    [bubbleTextOptionsMenuDown setDelegate:self];
    
    [bubbleTextOptionsMenuDown setFrame:bubbleMenuDown.frame];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = CGRectMake(ScreenSize.width/2-20, 10, 40, 40);
        bubbleTextOptionsMenuDown.frame = frame;
        [self.view addSubview:bubbleTextOptionsMenuDown];

    }];
}

-(void)removeTextOptionsMenu
{
    [UIView animateWithDuration:0.5 animations:^{
        [bubbleTextOptionsMenuDown setFrame:bubbleMenuDown.frame];
    } completion:^(BOOL finished) {
        [bubbleTextOptionsMenuDown removeFromSuperview];
    }];

}


- (UIButton *)createMenuButtonViewWithImage : (UIImage *)image optionalText:(NSString *)text
{
    UIButton *btnMenu = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
    
    
    [btnMenu setImage:image forState:UIControlStateNormal];
    if (!image)
    {
        [btnMenu setTitle:text forState:UIControlStateNormal];
        [btnMenu setFont:[UIFont systemFontOfSize:12.0]];
        [btnMenu setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    btnMenu.layer.cornerRadius = btnMenu.frame.size.height / 2.f;
    btnMenu.backgroundColor =[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
    btnMenu.clipsToBounds = YES;
    [btnMenu setEnabled:NO];
    return btnMenu;

}

- (NSArray *)createMenuButtonArrayWithImageArray:(NSArray *)arrayimages
{
    NSMutableArray *arrayMenuButtons = [[NSMutableArray alloc] init];
    
    int i = 0;
    for (NSString *imageName in arrayimages)
    {
        UIButton *button = [self createButtonWithName:imageName];
        
        button.frame = CGRectMake(0.f, 0.f, 30.f, 30.f);
        button.tag = i++;
        [arrayMenuButtons addObject:button];
    }
    return [arrayMenuButtons copy];
    
}

- (UIButton *)createButtonWithName:(NSString *)imageName
{
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button sizeToFit];
    return button;
}

#pragma mark - BubbleMenuDelegate

- (void)bubbleMenuButtonWillExpand:(DWBubbleMenuButton *)expandableView
{
    if (expandableView == bubbleMenuDown)
    {
        for (UIButton *btn in bubbleMenuDown.buttons)
        {
            if (btn.tag == OptionCOLOR)                                 //Additional handling for color button
            {
                btn.layer.cornerRadius = btn.frame.size.height / 2.f;
                btn.clipsToBounds = YES;
                [btn setBackgroundColor:self.drawingView.lineColor];
            }
        }

    }
    else if (expandableView == bubbleTextOptionsMenuDown)
    {
        for (UIButton *btn in bubbleTextOptionsMenuDown.buttons)
        {
              btn.layer.cornerRadius = btn.frame.size.height / 2.f;
              btn.clipsToBounds = YES;
              [btn setBackgroundColor:[UIColor whiteColor]];
           
        }

    }
}

- (void)bubbleMenuButtonDidExpand:(DWBubbleMenuButton *)expandableView
{
    
}

- (void)bubbleMenuButtonWillCollapse:(DWBubbleMenuButton *)expandableView
{
    
}
- (void)bubbleMenuButtonDidCollapse:(DWBubbleMenuButton *)expandableView
{
    
}

#pragma mark - bubble Menu buttons Actions
- (void)bubbleMenuButtonTapped:(UIButton *)sender
{
    int index = sender.tag;
    if (index<=2)
    {
        flgForSelectionOption = index;
        [_collectionView reloadData];
        [self showFilterView];
    }
    else if(index == 3)
    {
        self.lineWidthSlider.hidden = NO;
        self.lineAlphaSlider.hidden = YES;
        [self showSliderView];
    }
    else if (index == 4)
    {
        self.lineWidthSlider.hidden = YES;
        self.lineAlphaSlider.hidden = NO;
        [self showSliderView];
    }
    
}

- (void)bubbleTextOptionsTapped:(UIButton *)sender
{
    switch (sender.tag) {
        case 0:
            self.drawingView.textAlignment = NSTextAlignmentJustified;
            break;
            
        case 1:
            self.drawingView.textAlignment = NSTextAlignmentCenter;
            break;
            
        case 2:
            self.drawingView.textAlignment = NSTextAlignmentLeft;
            break;
            
        case 3:
            self.drawingView.textAlignment = NSTextAlignmentRight;
            break;
            
    }

}


#pragma mark - Circular menu Call

- (IBAction)btnExtraOptionsTapped:(id)sender
{
    circularMenuVC = nil;
    
    //use 3 or 7 or 12 for symmetric look (current implementation supports max 12 buttons)
    NSArray *arrImageName = [[NSArray alloc] initWithObjects:@"undo.png",
                             @"redo.png",
                             @"clear.png",
                             nil];
    
    circularMenuVC = [[ADCircularMenuViewController alloc] initWithMenuButtonImageNameArray:arrImageName andCornerButtonImageName:nil onView:self.view];
    circularMenuVC.delegateCircularMenu = self;

    for (UIButton *btn in circularMenuVC.arrButtons)
    {
        if (btn.tag == OptionUndo) {
            btn.hidden = ![self.drawingView canUndo];
        }
        if (btn.tag == OptionRedo) {
            btn.hidden = ![self.drawingView canRedo];
        }
    }
    
    [circularMenuVC show];
}


#pragma mark -
#pragma mark - CDCircularMenuController delegate

- (void)circularMenuClickedButtonAtIndex:(int) buttonIndex
{
    NSLog(@"Clicked menu button at index : %d",buttonIndex);
    if (buttonIndex == OptionUndo)
        [self undo];
    else if(buttonIndex == OptionRedo)
        [self redo];
    else if(buttonIndex == OptionClear)
        [self clear];
}


//Updated By Sanskar
-(void)addImageToEditor:(UIImage *)imageToEdit
{
    [self.drawingView loadImage:imageToEdit];
    _imgTOEdit = imageToEdit;
    [self reloadPreloadedImages];
}

#pragma mark - Utility Methods
- (NSArray *)preFilterImages
{
    NSMutableArray *images = [NSMutableArray new];
    for(NSString *filterName in filterNames)
    {
        // Filter the image
        CIFilter *filter = [CIFilter filterWithName:filterName];
        [filter setValue:[CIImage imageWithCGImage:_drawingView.image.CGImage] forKey:kCIInputImageKey];
        // Create a CG-back UIImage
        CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:filter.outputImage fromRect:filter.outputImage.extent];
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        [images addObject:image];
    }
    return [images copy];
}

-(void)reloadPreloadedImages {
   // [[ProgressIndicator sharedInstance] showPIOnView:self.view withMessage:nil];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        preFilterImages = [self preFilterImages].mutableCopy;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[ProgressIndicator sharedInstance]hideProgressIndicator];
            [self.collectionView reloadData];
        });
    });
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex
{
    if (flgForSelectionOption == OptionFILTER)
        return preFilterImages.count;
    else if(flgForSelectionOption == OptionCOLOR)
        return ArrayColor.count;
    else
        return arrayTools.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ColorCell *cell = (ColorCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                                               forIndexPath:indexPath];

    [cell.lblName setHidden:YES];
    [cell.imgColor setHidden:YES];
    
    if (flgForSelectionOption == OptionFILTER)
    {
        cell.imgColor.image = (UIImage *)[preFilterImages objectAtIndex:indexPath.row];
        [cell.imgColor setBackgroundColor:[UIColor clearColor]];
        [cell.imgColor.layer setCornerRadius:0];
        [cell.imgColor.layer setMasksToBounds:YES];
        [cell.imgColor setHidden:NO];
    }
    else if(flgForSelectionOption == OptionCOLOR)
    {
        [cell.imgColor setImage:nil];
        [cell.imgColor setBackgroundColor:[ArrayColor objectAtIndex:indexPath.item]];
        [cell.imgColor.layer setCornerRadius:cell.frame.size.height/2];
        [cell.imgColor.layer setMasksToBounds:YES];
        [cell.imgColor setHidden:NO];
    }
    else
    {
       // cell.lblName.text = arrayTools[indexPath.row];
       // [cell.lblName setHidden:NO];
        [cell.imgColor setBackgroundColor:[UIColor whiteColor]];
        cell.imgColor.image = [UIImage imageNamed:[arrayTools objectAtIndex:indexPath.row]];
        [cell.imgColor.layer setCornerRadius:0];
        [cell.imgColor.layer setMasksToBounds:YES];
        [cell.imgColor setHidden:NO];
        
    }
   
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (flgForSelectionOption == OptionFILTER)
    {
        if ([UIScreen mainScreen].bounds.size.width <= 320)
        {
            return CGSizeMake(130.f, 140.f);
        }
        else
        {
            return CGSizeMake(87.f, 87.f);
        }

    }
    else if(flgForSelectionOption == OptionCOLOR)
        return CGSizeMake(80, 80);
    else
        return CGSizeMake(80, 80);
}

 
#pragma mark - CollectionView Delegate Method
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (flgForSelectionOption == OptionFILTER)
    {
        [self.drawingView changeImageWithFiltered:preFilterImages[indexPath.row]];
        //[sideBar setSelectedFilterImage:preFilterImages[indexPath.row]];
        
        for (UIButton *btn in bubbleMenuDown.buttons) {
            if (btn.tag == OptionFILTER) {
                [btn setImage:preFilterImages[indexPath.row] forState:UIControlStateNormal];
            }
        }
    }
    else if(flgForSelectionOption == OptionCOLOR)
    {
        self.drawingView.lineColor = [ArrayColor objectAtIndex:indexPath.item];
        
        for (UIButton *btn in bubbleMenuDown.buttons) {
            if (btn.tag == OptionCOLOR) {
                [btn setBackgroundColor:[ArrayColor objectAtIndex:indexPath.row]];
            }
        }
        
        //[sideBar setSelectedColor:[ArrayColor objectAtIndex:indexPath.item]];
    }
    else
    {
        switch (indexPath.row) {
            case 0:
                self.drawingView.drawTool = ACEDrawingToolTypePen;
                break;
                
            case 1:
                self.drawingView.drawTool = ACEDrawingToolTypeLine;
                break;
                
            case 2:
                self.drawingView.drawTool = ACEDrawingToolTypeRectagleStroke;
                break;
                
            case 3:
                self.drawingView.drawTool = ACEDrawingToolTypeRectagleFill;
                break;
                
            case 4:
                self.drawingView.drawTool = ACEDrawingToolTypeEllipseStroke;
                break;
                
            case 5:
                self.drawingView.drawTool = ACEDrawingToolTypeEllipseFill;
                break;
                
            case 6:
                self.drawingView.drawTool = ACEDrawingToolTypeEraser;
                break;
                
            case 7:
                self.drawingView.drawTool = ACEDrawingToolTypeText;
                break;
        }
        
        // if eraser, disable color and alpha selection
       // self.colorButton.enabled = self.alphaButton.enabled = indexPath.row != 6;
        
       // self.toolButton.title = arrayTools[indexPath.row];
        
        for (UIButton *btn in bubbleMenuDown.buttons) {
            if (btn.tag == OptionTOOL) {
                [btn setImage:[UIImage imageNamed:[arrayTools objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
            }
        }
        
        
       // [sideBar setSelectedToolImage:[UIImage imageNamed:[arrayTools objectAtIndex:indexPath.row]] andName:arrayTools[indexPath.row]];
    }
    [self hideFilterView];
    
    if (flgForSelectionOption == OptionTOOL)
    {
        if (indexPath.row ==7) {
             [self addTextOptionsMenu];
        }
        else
        {
             [self removeTextOptionsMenu];
        }
    }

}

#pragma mark - Animation Methods

-(void)showFilterView
{
     [vwColorPicker setFrame:[APPDELEGATE window].frame];
     [[APPDELEGATE window] addSubview:vwColorPicker];
    
     selectedRectFrame = CGRectMake(bubbleMenuDown.frame.origin.x,bubbleMenuDown.frame.origin.y,40,40);
   
     [self zoomOutView:vwColorPicker fromRect:selectedRectFrame];
}

-(void)hideFilterView
{
    [self zoomInView:vwColorPicker toRect:selectedRectFrame];
}


-(void)zoomOutView:(UIView *)view fromRect:(CGRect)fromRect
{
    
    [view setFrame:fromRect];
    view.userInteractionEnabled = NO;
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    
    [UIView animateWithDuration:0.6 animations:^{
        
        view.transform = CGAffineTransformIdentity;
        [view setFrame:[APPDELEGATE window].frame];
        
    } completion:^(BOOL finished) {
         view.transform = CGAffineTransformIdentity;
        [view setCenter:[APPDELEGATE window].center];
        [view setFrame:[APPDELEGATE window].frame];
        view.userInteractionEnabled = YES;
        [view setAlpha:1.0];
    }];
    
}

-(void)zoomInView:(UIView *)view toRect:(CGRect)toRect
{
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.8 animations:^{
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        [view setFrame:toRect];
    }completion:^(BOOL finished) {
        view.transform = CGAffineTransformIdentity;
        [view setFrame:[APPDELEGATE window].frame];
        [view setCenter:[APPDELEGATE window].center];
        self.view.userInteractionEnabled = YES;
        [view removeFromSuperview];
        
    }];
    
}


-(void)zoomOutView:(UIView *)view fromRect:(CGRect)fromRect WithImage:(UIImage *)imgToZoom
{
    UIImageView *imgScreenShot = nil;
    
    if (imgToZoom) {
        imgScreenShot = [[UIImageView alloc]initWithImage:imgToZoom];
    }
    else
    {
        imgScreenShot = [self customSnapshoFromView:view];
    }
    
    [imgScreenShot setFrame:fromRect];
    
    [view setHidden:YES];
    
    // [[APPDELEGATE window] addSubview:imgScreenShot];
    [[APPDELEGATE window] addSubview:imgScreenShot];
    
    [UIView animateWithDuration:0.3 animations:^{
        [imgScreenShot setFrame:[APPDELEGATE window].frame];
        
    } completion:^(BOOL finished) {
        [view setCenter:[APPDELEGATE window].center];
        [view setFrame:[APPDELEGATE window].frame];
        [view setHidden:NO];
        [imgScreenShot removeFromSuperview];
    }];
    
    
}

-(void)zoomInView:(UIView *)view toRect:(CGRect)toRect WithImage:(UIImage *)imgToZoomIn
{
    UIImageView *imgScreenShot = nil;
    
    if (imgToZoomIn) {
        imgScreenShot = [[UIImageView alloc]initWithImage:imgToZoomIn];
    }
    else
    {
        imgScreenShot = [self customSnapshoFromView:view];
    }
    
    [imgScreenShot setFrame:[APPDELEGATE window].frame];
    [[APPDELEGATE window] addSubview:imgScreenShot];
    // [self.view addSubview:imgScreenShot];
    //[view removeFromSuperview];
    [view setHidden:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        [imgScreenShot setFrame:toRect];
    }completion:^(BOOL finished) {
        [imgScreenShot removeFromSuperview];
        [view removeFromSuperview];
    }];

}


-(UIImageView *)customSnapshoFromView:(UIView *)inputView
{
   
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, YES, 0);
    
    [inputView drawViewHierarchyInRect:inputView.bounds afterScreenUpdates:YES];
    
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, inputView.frame.size.width, inputView.frame.size.height)];
    [img setImage:screenShot];
     
    return img;
}


-(void)showSliderView
{
    [vwSliders setFrame:[APPDELEGATE window].frame];
    [[APPDELEGATE window] addSubview:vwSliders];
    selectedRectFrame = CGRectMake(bubbleMenuDown.frame.origin.x,bubbleMenuDown.frame.origin.y,40,40);
    [self zoomOutView:vwSliders fromRect:selectedRectFrame];
    
}

-(void)hideSliderView
{
     [self zoomInView:vwSliders toRect:selectedRectFrame];
}

-(void)callForWebseviceToCreateMomentWithImage:(UIImage *)imgMomentToShare andText : (NSString *)txtMoment
{
   
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    
    [afn getDataFromPath:METHOD_CREATE_MOMENT withParamDataImage:dictParam andImage:imgMomentToShare withBlock:^(id response, NSError *error) {
        if (response)
        {
            [[ProgressIndicator sharedInstance] hideProgressIndicator];
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
               [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
               [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_NEW_MOMENT_CREATED_DELETED object:nil];
            }
        }
        
    }];
    
}

#pragma mark - Extra Editing Options
- (void)undo
{
    [self.drawingView undoLatestStep];
}

- (void)redo
{
    [self.drawingView redoLatestStep];
}

- (void)clear
{
    [self.drawingView clear];
}

#pragma mark - IBActions
- (IBAction)widthChange:(UISlider *)sender
{
    self.drawingView.lineWidth = sender.value;
}


- (IBAction)alphaChange:(UISlider *)sender
{
    self.drawingView.lineAlpha = sender.value;
}


- (IBAction)btnDownloadImageTapped:(UIButton *)sender
{
    /*
    imgVwSaveImg =[[UIImageView alloc]initWithFrame:[APPDELEGATE window].frame];
    [self.view addSubview:imgVwSaveImg];
    [imgVwSaveImg setImage:self.drawingView.image];
    */
    
    CGRect frame = [sender convertRect:sender.bounds toView:self.view];
   
    [self zoomInView:imgVwSaveImg toRect:frame WithImage:self.drawingView.image];
    
    [self.library saveImage:self.drawingView.image toAlbum:@"Tinder Photos" withCompletionBlock:^(NSError *error) {
        if (error!=nil) {
            NSLog(@"Big error: %@", [error description]);
        }
        else
        {
           // Show_AlertView(nil, @"Image Saved Succesfully");
        }
    }];
    
}

- (IBAction)createMomentTapped:(UIButton *)sender
{
    UIImage *imgCropped = [[UtilityClass sharedObject] scaleImage:self.drawingView.image toSize:CGSizeMake(ScreenSize.width/2, ScreenSize.height/2)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self callForWebseviceToCreateMomentWithImage:imgCropped andText:nil];
    });
     
    if ([self.delegate respondsToSelector:@selector(btnSubmitOnDrawingVCTappedWithImage:)])
    {
        [self.delegate btnSubmitOnDrawingVCTappedWithImage:self.drawingView.image];
    }
}

- (IBAction)btnCancelTapped:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(btnCancelOnDrawingVCTapped)]) {
        [self.delegate btnCancelOnDrawingVCTapped];
    }
}


#pragma mark - Tap gesture handling

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"Class %@",[touch.view class]);
    if (([touch.view isKindOfClass:[UICollectionView class]]))
        return YES;
    if (touch.view == vwColorPicker)
        return YES;
    if (touch.view == vwSliders)
        return YES;
    
    return NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self hideFilterView];
    [self hideSliderView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
