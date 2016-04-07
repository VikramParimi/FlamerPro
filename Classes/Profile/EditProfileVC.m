//
//  EditProfileVC.m
//  Tinder
//
//  Created by Elluminati - macbook on 14/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "EditProfileVC.h"
#import "UIImageView+Download.h"
#import "UserImage.h"
#import "Base64.h"
#import "EditMyInfoViewCell.h"
#import "Photo.h"
#import "User.h"
#import "EBTinderClient.h"

@interface EditProfileVC ()
{
     int selectedIndexToChange;
}

@end

@implementation EditProfileVC

@synthesize strStatus;

static NSString * const cellCollectionView = @"CellImage";


#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    selectedBtnTag=-1;
    selectedIndexToChange = -1;
    
    arrImages=[[NSMutableArray alloc]init];
    
    [self getUserPhotos];
    
    self.txtStatus.text=strStatus;
    [self.collectionView registerClass:[EditMyInfoViewCell class] forCellWithReuseIdentifier:cellCollectionView];
    
}

-(IBAction)doneEditing:(id)sender
{
    //[self updateProfilePicture];
    [self dismissViewControllerAnimated:NO completion:nil];
}

/*
-(void)updateProfilePicture
{
    if ([arrImages count])
    {
        UserImage *ui=[arrImages firstObject];
        
        [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading..."];
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
        [dictParam setObject:ui.image_id forKey:PARAM_ENT_NEW_IMAGE_ID];
        [dictParam setObject:ui.index_id forKey:PARAM_ENT_NEW_PRF_INDEX_ID];
        
        AFNHelper *afn=[[AFNHelper alloc]init];
        [afn getDataFromPath:METHOD_UPDATE_PROFILE_PIC withParamData:dictParam withBlock:^(id response, NSError *error) {
            if (response)
            {
                if ([[response objectForKey:@"errFlag"] intValue]==0)
                {
                    
                    [arrImages removeAllObjects];
                    NSArray *arr=[response objectForKey:@"Userphotos"];
                    for (NSDictionary *dict in arr) {
                        UserImage *ui=[[UserImage alloc]init];
                        ui.image_id=[dict objectForKey:@"image_id"];
                        ui.image_url=[dict objectForKey:@"image_url"];
                        ui.index_id=[dict objectForKey:@"index_id"];
                        [arrImages addObject:ui];
                    }
                    [_collectionView reloadData];
                    
                    if([[UserDefaultHelper sharedObject]facebookLoginRequest]!=nil) {
                        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]initWithDictionary:[[UserDefaultHelper sharedObject] facebookLoginRequest]];
                        UserImage *uiPP=nil;
                        for (int i=0; i<[arrImages count]; i++) {
                            UserImage *u=[arrImages objectAtIndex:i];
                            if ([u.index_id intValue]==0) {
                                uiPP=u;
                            }
                        }
                        if (uiPP!=nil) {
                            [dictParam setObject:uiPP.image_url forKey:PARAM_ENT_PROFILE_PIC];
                            [[UserDefaultHelper sharedObject]setFacebookLoginRequest:dictParam];
                        }
                        [User currentUser].profile_pic=[dictParam objectForKey:PARAM_ENT_PROFILE_PIC];
                    }
                    
                    [APPDELEGATE callNotificationForScreenUpdates:NOTIFICATION_MENUSCREEN_REFRESH];
                }
            }
            [[ProgressIndicator sharedInstance] hideProgressIndicator];
        }];
    }
}*/

#pragma mark -
#pragma mark - Methods

-(void)getUserPhotos
{
    User *currentUser = [User currentUser];
    [arrImages removeAllObjects];
    NSArray *arr= [currentUser.photos allObjects];
    for (Photo *dict in arr) {
        UserImage *ui= [[UserImage alloc]init];
        ui.image_id= [NSString stringWithFormat:@"%d",[dict.orderId intValue]];//[dict objectForKey:@"image_id"];
        ui.image_url= [NSString stringWithFormat:@"%@",dict.url];// [dict objectForKey:@"image_url"];
        ui.index_id= [NSString stringWithFormat:@"%d",[dict.orderId intValue]];//[dict objectForKey:@"index_id"];
        [arrImages addObject:ui];
    }
    // [self reloadAllImages];
    [_collectionView reloadData];
    
    /*[[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading..."];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GET_USER_PROFILE_PIC withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
                [arrImages removeAllObjects];
                NSArray *arr=[response objectForKey:@"Userphotos"];
                for (NSDictionary *dict in arr) {
                    UserImage *ui=[[UserImage alloc]init];
                    ui.image_id=[dict objectForKey:@"image_id"];
                    ui.image_url=[dict objectForKey:@"image_url"];
                    ui.index_id=[dict objectForKey:@"index_id"];
                    [arrImages addObject:ui];
                }
               // [self reloadAllImages];
                [_collectionView reloadData];
            }
        }
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];*/
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 5.f;
}

- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 5.f;
}

- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 5.f;
}

- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(5.f, 0, 5.f, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForLargeItemsInSection:(NSInteger)section
{
    // if (section == 0)
    {
        return RACollectionViewTripletLayoutStyleSquare; //same as default !
    }
}

- (UIEdgeInsets)autoScrollTrigerEdgeInsets:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(50.f, 0, 50.f, 0); //Sorry, horizontal scroll is not supported now.
}

- (UIEdgeInsets)autoScrollTrigerPadding:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(64.f, 0, 0, 0);
}

- (CGFloat)reorderingItemAlpha:(UICollectionView *)collectionview
{
    return .3f;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.item < arrImages.count && toIndexPath.item < arrImages.count)
    {
        NSString *imageUrl = [arrImages objectAtIndex:fromIndexPath.item];
        [arrImages removeObjectAtIndex:fromIndexPath.item];
        [arrImages insertObject:imageUrl atIndex:toIndexPath.item];
    }
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item >= arrImages.count) {
        return  NO;
    }
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.item >= arrImages.count || toIndexPath.item >= arrImages.count) {
        return  NO;
    }
    
    return YES;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    EditMyInfoViewCell *cell = (EditMyInfoViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellCollectionView
                                                                                               forIndexPath:indexPath];
    
    [cell.imgPhoto setShowActivity:YES];
    if (indexPath.item < arrImages.count)
    {
        if ([arrImages objectAtIndex:indexPath.item])
        {
             UserImage *ui = arrImages[indexPath.item];
            [cell.imgPhoto setImageURL:[NSURL URLWithString: ui.image_url]];
            [cell.btnAddRemove setSelected:YES];
        }
        else
        {
            [cell.imgPhoto setImage:[UIImage imageNamed:@"pfImage.png"]];
            [cell.btnAddRemove setSelected:NO];
        }
    }
    else
    {
        [cell.imgPhoto setImage:[UIImage imageNamed:@"pfImage.png"]];
        [cell.imgPhoto setContentMode:UIViewContentModeScaleAspectFill];
        [cell.imgPhoto setClipsToBounds:YES];
        [cell.btnAddRemove setSelected:NO];
    }
    [cell.btnAddRemove setTag:indexPath.item];
    [cell.btnAddRemove addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
   if (selectedIndexToChange == (int)indexPath.item)
    {
        cell.imgPhoto.frame =CGRectMake(cell.contentView.frame.size.width/2,0, 1, cell.contentView.frame.size.height);
        [UIView animateWithDuration:0.3f animations:^{
            cell.imgPhoto.frame = CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
        }];
    }
   
    return cell;
}

-(void)deleteImage{
    
   /* [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Deleting..."];
    
    UserImage *ui=[arrImages objectAtIndex:selectedIndexToChange];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:ui.image_id forKey:PARAM_ENT_IMAGE_ID];
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_DELETE_USER_IMAGE withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                [arrImages removeObject:ui];
               // [_collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:selectedIndexToChange inSection:0]]];
                [_collectionView reloadData];
            }
        }
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];*/
}

#pragma mark -
#pragma mark - Actions

-(IBAction)onClickChangeStatus:(id)sender{
    [self.txtStatus resignFirstResponder];
    
    if (self.txtStatus.text.length==0) {
        return;
    }

  /*  [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading..."];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:self.txtStatus.text forKey:PARAM_ENT_STATUS];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_UPDATE_STATUS withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
            }
        }
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];*/
    
}

-(IBAction)onClickBtn:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    selectedIndexToChange = btn.tag;
    
    if (btn.selected)
    {
       // btn.selected=NO;
        [self deleteImage];
    }
    else
    {
        UIActionSheet *as=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open camera",@"Choose from Library", nil];
        as.tag=selectedIndexToChange;
        [as showInView:self.view];
        //[btn setSelected:YES];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    
    SEL selector = NSSelectorFromString(@"_alertController");
    if ([actionSheet respondsToSelector:selector])
    {
        UIAlertController *alertController = [actionSheet valueForKey:@"_alertController"];
        if ([alertController isKindOfClass:[UIAlertController class]])
        {
            alertController.view.tintColor = ACTION_SHEET_COLOR;
        }
    }
    else
    {
        // use other methods for iOS 7 or older.
        for (UIView *subview in actionSheet.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                [button setTitleColor:ACTION_SHEET_COLOR forState:UIControlStateNormal];
            }
        }
        
    }
    
}

-(IBAction)onClickImage:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    int tag=btn.tag-3000;
    
    UserImage *ui=nil;
    for (int i=0; i<[arrImages count]; i++) {
        UserImage *u=[arrImages objectAtIndex:i];
        if ([u.index_id intValue]==tag) {
            ui=u;
        }
    }
    
    if (ui==nil) {
        return;
    }
    
    
    UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"Profile Picture" message:@"Set as profile picture?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alt.tag=tag;
    [alt show];
    
}

#pragma mark -
#pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    /*if (buttonIndex==0) {
        return;
    }
    
    UserImage *ui=nil;
    for (int i=0; i<[arrImages count]; i++) {
        UserImage *u=[arrImages objectAtIndex:i];
        if ([u.index_id intValue]==alertView.tag) {
            ui=u;
        }
    }
    
    if (ui==nil) {
        return;
    }
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading..."];
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:ui.image_id forKey:PARAM_ENT_NEW_IMAGE_ID];
    [dictParam setObject:ui.index_id forKey:PARAM_ENT_NEW_PRF_INDEX_ID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_UPDATE_PROFILE_PIC withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                [arrImages removeAllObjects];
                NSArray *arr=[response objectForKey:@"Userphotos"];
                for (NSDictionary *dict in arr) {
                    UserImage *ui=[[UserImage alloc]init];
                    ui.image_id=[dict objectForKey:@"image_id"];
                    ui.image_url=[dict objectForKey:@"image_url"];
                    ui.index_id=[dict objectForKey:@"index_id"];
                    [arrImages addObject:ui];
                }
                [_collectionView reloadData];
                
                if([[UserDefaultHelper sharedObject]facebookLoginRequest]!=nil) {
                    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]initWithDictionary:[[UserDefaultHelper sharedObject] facebookLoginRequest]];
                    UserImage *uiPP=nil;
                    for (int i=0; i<[arrImages count]; i++) {
                        UserImage *u=[arrImages objectAtIndex:i];
                        if ([u.index_id intValue]==0) {
                            uiPP=u;
                        }
                    }
                    if (uiPP!=nil) {
                        [dictParam setObject:uiPP.image_url forKey:PARAM_ENT_PROFILE_PIC];
                        [[UserDefaultHelper sharedObject]setFacebookLoginRequest:dictParam];
                    }
                    [User currentUser].profile_pic=[dictParam objectForKey:PARAM_ENT_PROFILE_PIC];
                }
            }
        }
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];*/
}

#pragma mark -
#pragma mark - UIActionSheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self openCamera];
            break;
        case 1:
            [self chooseFromLibaray];
            break;
        case 2:
            break;
    }
}

-(void)openCamera
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.view.tag=selectedBtnTag;
        imagePickerController.delegate = self;
        imagePickerController.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePickerController.editing=YES;
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
    else{
        UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"" message:@"Camera Not Available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alt show];
    }
}

-(void)chooseFromLibaray
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.view.tag=selectedBtnTag;
    imagePickerController.delegate = self;
    imagePickerController.sourceType =
    UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.editing=YES;
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

#pragma mark -
#pragma mark - UIImagePickerController Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    /* [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Uploading..."];
    
    UIImage *img=[[UtilityClass sharedObject] scaleAndRotateImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:[NSString stringWithFormat:@"%d",picker.view.tag] forKey:PARAM_ENT_INDEX_ID];
    
    NSData *imageToUpload = UIImageJPEGRepresentation(img, 1.0);
    if (imageToUpload) {
        NSString *strImage=[Base64 encode:imageToUpload];
        if (strImage) {
            [dictParam setObject:strImage forKey:PARAM_ENT_USERIMAGE];
        }
    }
    
   AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_UPLOAD_USER_IMAGE withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response)
        {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                UserImage *ui=[[UserImage alloc]init];
                ui.index_id=[NSString stringWithFormat:@"%d",selectedBtnTag];
                ui.image_id=[response objectForKey:@"ent_image_id"];
                ui.image_url=[response objectForKey:@"picURL"];
                [arrImages addObject:ui];
                [_collectionView reloadData];
            }
        }
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];*/
}

- (IBAction) imageMoved:(UIButton *) sender withEvent:(UIEvent *) event
{
    UIControl *control = sender;
    
    UITouch *t = [[event allTouches] anyObject];
    CGPoint pPrev = [t previousLocationInView:control];
    CGPoint p = [t locationInView:control];
    
    CGPoint center = control.center;
    center.x += p.x - pPrev.x;
    center.y += p.y - pPrev.y;
    control.center = center;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect rect=self.view.frame;
    if (IS_IPHONE_5)
    {
        rect.origin.y=-110;
    }
    else
    {
        rect.origin.y=-170;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame=rect;
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect rect=self.view.frame;
    rect.origin.y=0;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame=rect;
    }];
}

#pragma mark - Methods To Hide StatusBar

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(BOOL)prefersStatusBarHidden   // iOS8 definitely needs this one. checked.
{
    return NO;
}

-(UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}


#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
