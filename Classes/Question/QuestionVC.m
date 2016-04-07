//
//  QuestionVC.m
//  Tinder
//
//  Created by Elluminati - macbook on 26/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "QuestionVC.h"

#import "ViewQA.h"
#import "JSON.h"

@interface QuestionVC ()

@end

@implementation QuestionVC

@synthesize arrSelectedAns;

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
//    [super viewDidLoad];
//    arrQuestions=[[NSMutableArray alloc]init];
//    arrSelectedAns=[[NSMutableArray alloc]init];
//    [self getAllQuestions];
//    currentPage=0;
//    self.btnPrev.hidden=YES;
    
    
    //naveen
    if ([arrSelectedAns count]==0) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    //naveen
    
    
   
}

#pragma mark -
#pragma mark - Methods

-(void)getAllQuestions
{
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading..."];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GET_QUESTION withParamData:dictParam withBlock:^(id response, NSError *error) {
        [arrQuestions removeAllObjects];
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                NSArray *arr=[response objectForKey:@"detail_que"];
                if (arr) {
                    [arrQuestions addObjectsFromArray:arr];
                }
            }
        }
        [self setScrollView];
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];
}

-(void)setScrollView{
    [self.scrQue setContentSize:CGSizeMake(self.scrQue.frame.size.width*[arrQuestions count], self.scrQue.frame.size.height)];
    
    int x=0;
    for (int i=0; i<[arrQuestions count]; i++)
    {
        CGRect rect=self.scrQue.frame;
        rect.origin.x=x;
        ViewQA *v=[[ViewQA alloc]initWithFrame:rect];
        v.tag=i+1000;
        v.parent=self;
        [v setAllViews:[arrQuestions objectAtIndex:i]];
        [self.scrQue addSubview:v];
        x+=rect.size.width;
    }
}

#pragma mark -
#pragma mark - Actions

-(IBAction)onClickClose:(id)sender
{
    if ([arrSelectedAns count]==0) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else{
        SBJsonWriter *jsonWriter = [SBJsonWriter new];
        NSString *jsonString = [jsonWriter stringWithObject:arrSelectedAns];
        
        
        if (jsonString!=nil) {
            [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Submitting..."];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
            [dictParam setObject:jsonString forKey:PARAM_ENT_JSON];
            
            AFNHelper *afn=[[AFNHelper alloc]init];
            
            //NSString *strBody=[NSString stringWithFormat:@"%@=%@&%@=%@",PARAM_ENT_USER_FBID,[User currentUser].fbid,PARAM_ENT_JSON,jsonString];
            
            //[afn callWebserviceWithMethod:METHOD_GET_QUESTION_ANS_INSERT andBody:strBody];
            
            [afn getDataFromPath:METHOD_GET_QUESTION_ANS_INSERT withParamData:dictParam withBlock:^(id response, NSError *error) {
                if (response) {
                    
                }
                [[ProgressIndicator sharedInstance]hideProgressIndicator];
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }];
        }
        else{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}

-(IBAction)onClickPrev:(id)sender{
    [self.scrQue setContentOffset:CGPointMake(self.scrQue.frame.size.width*(currentPage-1), 0.0f) animated:YES];
}

-(IBAction)onClickNext:(id)sender{
    [self.scrQue setContentOffset:CGPointMake(self.scrQue.frame.size.width*(currentPage+1), 0.0f) animated:YES];
}

#pragma mark -
#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.scrQue.frame.size.width;
    currentPage = floor((self.scrQue.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (currentPage==0) {
        self.btnPrev.hidden=YES;
        self.btnNext.hidden=NO;
    }
    else if (currentPage==[arrQuestions count]-1) {
        self.btnNext.hidden=YES;
        self.btnPrev.hidden=NO;
    }
    else{
        self.btnNext.hidden=NO;
        self.btnPrev.hidden=NO;
    }
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

