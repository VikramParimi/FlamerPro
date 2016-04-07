//
//  ViewQA.m
//  Tinder
//
//  Created by Elluminati - macbook on 27/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "ViewQA.h"
#import "QuestionVC.h"

@implementation ViewQA

@synthesize parent;

#pragma mark -
#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUpView];
    }
    return self;
}

-(void)setUpView
{
    self.lblQuestion=[[UILabel alloc]initWithFrame:CGRectMake(10, 65, 300, 24)];
    self.lblQuestion.numberOfLines=0;
    self.lblQuestion.backgroundColor=[UIColor clearColor];
    self.lblQuestion.font=[UIFont boldSystemFontOfSize:18.0];
    [self addSubview:self.lblQuestion];
    
    
    self.lblOpt1=[[UILabel alloc]initWithFrame:CGRectMake(15, 186, 25, 25)];
    self.lblOpt1.text=@"A.";
    [self addSubview:self.lblOpt1];
    self.lblOpt2=[[UILabel alloc]initWithFrame:CGRectMake(15, 215, 25, 25)];
    self.lblOpt2.text=@"B.";
    [self addSubview:self.lblOpt2];
    self.lblOpt3=[[UILabel alloc]initWithFrame:CGRectMake(15, 244, 25, 25)];
    self.lblOpt3.text=@"C.";
    [self addSubview:self.lblOpt3];
    self.lblOpt4=[[UILabel alloc]initWithFrame:CGRectMake(15, 273, 25, 25)];
    self.lblOpt4.text=@"D.";
    [self addSubview:self.lblOpt4];
    
    
    self.lblAns1=[[UILabel alloc]initWithFrame:CGRectMake(40, 186, 200, 25)];
    self.lblAns1.numberOfLines=0;
    self.lblAns1.backgroundColor=[UIColor clearColor];
    [self addSubview:self.lblAns1];
    self.lblAns2=[[UILabel alloc]initWithFrame:CGRectMake(40, 215, 200, 25)];
    self.lblAns2.numberOfLines=0;
    self.lblAns2.backgroundColor=[UIColor clearColor];
    [self addSubview:self.lblAns2];
    self.lblAns3=[[UILabel alloc]initWithFrame:CGRectMake(40, 244, 200, 25)];
    self.lblAns3.numberOfLines=0;
    self.lblAns3.backgroundColor=[UIColor clearColor];
    [self addSubview:self.lblAns3];
    self.lblAns4=[[UILabel alloc]initWithFrame:CGRectMake(40, 273, 200, 25)];
    self.lblAns4.numberOfLines=0;
    self.lblAns4.backgroundColor=[UIColor clearColor];
    [self addSubview:self.lblAns4];
    
    
    
    self.btnY1=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btnY1.frame=CGRectMake(270, 186, 25, 25);
    [self addSubview:self.btnY1];
    self.btnY2=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btnY2.frame=CGRectMake(270, 215, 25, 25);
    [self addSubview:self.btnY2];
    self.btnY3=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btnY3.frame=CGRectMake(270, 244, 25, 25);
    [self addSubview:self.btnY3];
    self.btnY4=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btnY4.frame=CGRectMake(270, 273, 25, 25);
    [self addSubview:self.btnY4];
    
    
    [self.btnY1 setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
    [self.btnY1 setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
    [self.btnY2 setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
    [self.btnY2 setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
    [self.btnY3 setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
    [self.btnY3 setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
    [self.btnY4 setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
    [self.btnY4 setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
 
    [self.btnY1 addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnY2 addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnY3 addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnY4 addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.btnSubmit=[UIButton buttonWithType:UIButtonTypeCustom];
    int y=420;
    if (IS_IPHONE_5) {
        y=510;
    }
    self.btnSubmit.frame=CGRectMake(90, y, 143, 46);
    [self addSubview:self.btnSubmit];
    [self bringSubviewToFront:self.btnSubmit];
    [self.btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnSubmit setTitle:@"Submit" forState:UIControlStateNormal];
    [self.btnSubmit setBackgroundImage:[UIImage imageNamed:@"logout_tab_on"] forState:UIControlStateNormal];
    [self.btnSubmit addTarget:self action:@selector(onClickSubmit:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)setAllViews:(NSDictionary *)dictData
{
    data=dictData;
    
    self.lblQuestion.text=[data objectForKey:@"question"];
    
    self.lblAns1.text=@"";
    self.lblAns2.text=@"";
    self.lblAns3.text=@"";
    self.lblAns4.text=@"";
    
    NSArray *arrOpt=[data objectForKey:@"options"];
    for (int i=0; i<[arrOpt count]; i++) {
        NSDictionary *dict=[arrOpt objectAtIndex:i];
        NSString *strAns=[dict objectForKey:@"option"];
        switch (i) {
            case 0:
                self.lblAns1.text=strAns;
                break;
            case 1:
                self.lblAns2.text=strAns;
                break;
            case 2:
                self.lblAns3.text=strAns;
                break;
            case 3:
                self.lblAns4.text=strAns;
                break;
            default:
                break;
        }
    }
    
    float height=10.0f;
    CGRect rect=self.lblQuestion.frame;
    rect.size=[self getExpectedLabelSize:self.lblQuestion For:CGSizeMake(self.lblQuestion.frame.size.width, 999)];
    self.lblQuestion.frame=rect;
    height+=rect.origin.y+rect.size.height+10;
    
    //Option A
    rect=self.lblOpt1.frame;
    rect.origin.y=height;
    self.lblOpt1.frame=rect;
    
    rect=self.btnY1.frame;
    rect.origin.y=height;
    self.btnY1.frame=rect;
    
    rect=self.lblAns1.frame;
    rect.origin.y=height;
    rect.size=[self getExpectedLabelSize:self.lblAns1 For:CGSizeMake(self.lblAns1.frame.size.width, 999)];
    self.lblAns1.frame=rect;
    height+=rect.size.height+10;
    
    //Option B
    rect=self.lblOpt2.frame;
    rect.origin.y=height;
    self.lblOpt2.frame=rect;
    
    
    rect=self.btnY2.frame;
    rect.origin.y=height;
    self.btnY2.frame=rect;
    
    rect=self.lblAns2.frame;
    rect.size=[self getExpectedLabelSize:self.lblAns2 For:CGSizeMake(self.lblAns2.frame.size.width, 999)];
    rect.origin.y=height;
    self.lblAns2.frame=rect;
    height+=rect.size.height+10;
    
    //Option C
    rect=self.lblOpt3.frame;
    rect.origin.y=height;
    self.lblOpt3.frame=rect;
    
    rect=self.btnY3.frame;
    rect.origin.y=height;
    self.btnY3.frame=rect;
    
    rect=self.lblAns3.frame;
    rect.size=[self getExpectedLabelSize:self.lblAns3 For:CGSizeMake(self.lblAns3.frame.size.width, 999)];
    rect.origin.y=height;
    self.lblAns3.frame=rect;
    height+=rect.size.height+10;
    
    //Option D
    rect=self.lblOpt4.frame;
    rect.origin.y=height;
    self.lblOpt4.frame=rect;
    
    rect=self.btnY4.frame;
    rect.origin.y=height;
    self.btnY4.frame=rect;
    
    rect=self.lblAns4.frame;
    rect.size=[self getExpectedLabelSize:self.lblAns4 For:CGSizeMake(self.lblAns4.frame.size.width, 999)];
    rect.origin.y=height;
    self.lblAns4.frame=rect;
    height+=rect.size.height+10;
    
    [self hideLables];
    [self setYourAns];
    
}

-(CGSize)getExpectedLabelSize:(UILabel *)lbl For:(CGSize)maximumLabelSize
{
    CGSize expectedLabelSize = [lbl.text sizeWithFont:lbl.font
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:lbl.lineBreakMode];
    return expectedLabelSize;
}

-(void)hideLables
{
    if ([self.lblAns1.text isEqualToString:@""])
    {
        self.lblOpt1.hidden=self.lblAns1.hidden=self.btnY1.hidden=TRUE;
    }
    if ([self.lblAns2.text isEqualToString:@""])
    {
        self.lblOpt2.hidden=self.lblAns2.hidden=self.btnY2.hidden=TRUE;
    }
    if ([self.lblAns3.text isEqualToString:@""])
    {
        self.lblOpt3.hidden=self.lblAns3.hidden=self.btnY3.hidden=TRUE;
    }
    if ([self.lblAns4.text isEqualToString:@""])
    {
        self.lblOpt4.hidden=self.lblAns4.hidden=self.btnY4.hidden=TRUE;
    }
}

-(void)setYourAns
{
    NSArray *arrOpt=[data objectForKey:@"options"];
    for (int i=0; i<[arrOpt count]; i++) {
        NSDictionary *dict=[arrOpt objectAtIndex:i];
        NSString *strAns=[dict objectForKey:@"flag"];
        switch (i) {
            case 0:
                self.btnY1.selected=[strAns boolValue];
                break;
            case 1:
                self.btnY2.selected=[strAns boolValue];
                break;
            case 2:
                self.btnY3.selected=[strAns boolValue];
                break;
            case 3:
                self.btnY4.selected=[strAns boolValue];
                break;
            default:
                break;
        }
    }
    
}

#pragma mark -
#pragma mark - Actions

-(IBAction)onClickBtn:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if (btn==self.btnY1 || btn==self.btnY2 || btn==self.btnY3 || btn==self.btnY4)
    {
        if (!btn.selected) {
            self.btnY1.selected=self.btnY2.selected=self.btnY3.selected=self.btnY4.selected=FALSE;
            btn.selected=TRUE;
        }
    }
    else{
        btn.selected=!btn.selected;
    }
}

-(IBAction)onClickSubmit:(id)sender
{
    if ([parent isKindOfClass:[QuestionVC class]]) {
        QuestionVC *vc=(QuestionVC *)parent;
        NSArray *arrOpt=[data objectForKey:@"options"];

        NSDictionary *dict=nil;
        if (self.btnY1.selected) {
            dict=[arrOpt objectAtIndex:0];
        }
        else if (self.btnY2.selected){
            dict=[arrOpt objectAtIndex:1];
        }
        else if (self.btnY3.selected){
            dict=[arrOpt objectAtIndex:2];
        }
        else if (self.btnY4.selected){
            dict=[arrOpt objectAtIndex:2];
        }
        
        if (dict==nil) {
            return;
        }
        
        NSMutableDictionary *dictAns=[[NSMutableDictionary alloc]init];
        [dictAns setObject:[data objectForKey:@"q_id"] forKey:@"q_id"];
        [dictAns setObject:[dict objectForKey:@"ans_id"] forKey:@"ans_id"];
        [vc.arrSelectedAns removeObject:dictAns];
        [vc.arrSelectedAns addObject:dictAns];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
