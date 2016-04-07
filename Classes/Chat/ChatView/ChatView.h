//
//  ChatView.h
//  snapchatclone
//
//  Created by soumya ranjan sahu on 03/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnapChatList.h"
#import "SingleChatTable.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>
#import "DDAnnotation.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "VideoPlayerViewController.h"

@protocol ChatViewDelegate <NSObject>

@optional
- (void)chatViewDeleteSnap;
@end

@interface ChatView : UIView <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, AVAudioSessionDelegate, ABUnknownPersonViewControllerDelegate, MKMapViewDelegate>
{
    int _currentKeyboardHeight;
    UIImagePickerController *imagePicker;
    NSMutableData *mediaData, *updateData;
    NSURLConnection *updateCon;
    AVAudioRecorder *recorder;
    AVAudioPlayer *newPlayer;
    
    NSString *mediaTypeString;
    NSString *mediaNameString;
    
    NSTimer *audioTimer;
    int selectedIndex;
    
    MPMoviePlayerController *moviePlayer;
    
    UIView *viewFullImage;
    MKMapView *mapView;
    UIImageView *imageView;
    CGRect cellFrame;
    
    NSTimer *recordTimer;
    int recordTimeSecond;
    BOOL sendAudio;
}

@property (strong, nonatomic) id <ChatViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *chatBackView;
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UIView *headerBackView;
@property (weak, nonatomic) IBOutlet UIImageView *chatImageView;
@property (weak, nonatomic) IBOutlet UIView *optionView;
@property (weak, nonatomic) IBOutlet UIView *recorderView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *recordingButton;
@property (weak, nonatomic) IBOutlet UILabel *recordingTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *semiTransView;

@property (assign, nonatomic) int mediaId;
@property (assign, nonatomic) BOOL isChatOpen;
@property (assign, nonatomic) BOOL isChatViewOpen;
@property (retain, nonatomic) SnapChatList *snapObject;

@property (retain, nonatomic) VideoPlayerViewController *myPlayerViewController;

@property (retain, nonatomic) NSMutableArray *messageArray;
@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
@property (retain, nonatomic) NSTimer *connectionTimer;

- (IBAction)buttonSendTapped:(id)sender;
- (IBAction)optionButtonTapped:(UIButton *)sender;
- (IBAction)buttonPlusTapped:(id)sender;
- (void)manageLayout;
- (IBAction)buttonCloseOptionTapped:(id)sender;
- (IBAction)buttonStopTapped:(id)sender;
- (IBAction)buttonDeleteTapped:(id)sender;
- (IBAction)buttonCancelRecordTapped:(id)sender;

- (void)tapHandle:(UITapGestureRecognizer *)recognizer;

@end
