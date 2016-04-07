//
//  EditProfileVC.h
//  Tinder
//
//  Created by Elluminati - macbook on 14/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RACollectionViewReorderableTripletLayout.h"


@interface EditProfileVC : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,UITextFieldDelegate,
RACollectionViewDelegateReorderableTripletLayout, RACollectionViewReorderableTripletLayoutDataSource>
{
    int selectedBtnTag;
    NSMutableArray *arrImages;
}
@property(nonatomic,copy)NSString *strStatus;
@property(nonatomic,weak)IBOutlet UITextField *txtStatus;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

-(IBAction)onClickChangeStatus:(id)sender;
-(IBAction)onClickBtn:(id)sender;
-(IBAction)onClickImage:(id)sender;

@end
