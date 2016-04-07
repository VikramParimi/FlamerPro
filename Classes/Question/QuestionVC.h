//
//  QuestionVC.h
//  Tinder
//
//  Created by Elluminati - macbook on 26/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "BaseVC.h"

@interface QuestionVC : BaseVC<UIScrollViewDelegate>
{
    NSMutableArray *arrQuestions;
    NSMutableArray *arrSelectedAns;
    int currentPage;
}
@property(nonatomic,weak)IBOutlet UIScrollView *scrQue;
@property(nonatomic,strong)NSMutableArray *arrSelectedAns;

@property(nonatomic,weak)IBOutlet UIButton *btnPrev;
@property(nonatomic,weak)IBOutlet UIButton *btnNext;

-(IBAction)onClickClose:(id)sender;
-(IBAction)onClickPrev:(id)sender;
-(IBAction)onClickNext:(id)sender;

@end
