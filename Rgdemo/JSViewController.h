//
//  JSViewController.h
//  Rgdemo
//
//  Created by Jan Sanchez on 10/26/12.
//  Copyright (c) 2012 Jan Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface JSViewController : UIViewController <TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)goButtonPressed:(id)sender;

@end
