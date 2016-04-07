//
//  SettingsViewController.h
//  Tinder
//
//  Created by Rahul Sharma on 30/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "BaseVC.h"
#import "TinderAppDelegate.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@class RangeSlider;
@class TinderAppDelegate;
@interface SettingsViewController : BaseVC<MFMailComposeViewControllerDelegate,UIActionSheetDelegate>
{
  IBOutlet UILabel *lblTitle;
  IBOutlet UIButton *btnDone;
  
  IBOutlet  UISlider *sliderDistance;
  IBOutlet  UISlider *sliderAgePrefrence;
  RangeSlider *slider;
  UILabel *reportLabel;
  IBOutlet UILabel *lblAgeMin;
  IBOutlet UILabel *lblShowAges;
 
  IBOutlet UILabel *lblLimitSearch;
 
  TinderAppDelegate * appDelagte;
  IBOutlet UIScrollView * scrollview;
   IBOutlet UIView * viewBG;
 
  int Intested_in;
  int sex;
   
}
@property (strong, nonatomic) IBOutlet UISwitch *switchDiscovery;
@property (strong, nonatomic) IBOutlet UIButton *btnGenderOutlet;
- (IBAction)btnGenderTapped:(UIButton *)sender;

- (IBAction)discovrySwitched:(UISwitch *)sender;

 @property (weak, nonatomic) IBOutlet UILabel *lblDistance;
-(IBAction)sliderChange:(UISlider*)sender;

//-(void)saveUpdatedValue;

@end
