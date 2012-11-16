//
//  JSViewController.m
//  Rgdemo
//
//  Created by Jan Sanchez on 10/26/12.
//  Copyright (c) 2012 Jan Sanchez. All rights reserved.
//

#import "JSViewController.h"
#import "MBProgressHUD.h"
#import "TFHpple.h"
#import "TTTAttributedLabel.h"


@interface JSViewController ()

@end

@implementation JSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.contentLabel setTextColor:[UIColor whiteColor]];
    [self.scrollView setBackgroundColor:[UIColor blackColor]];
    
    UIColor *linkColor = [UIColor colorWithRed:255.0f/255.0f green:195.0f/255.0f blue:28.0f/255.0f alpha:1.0f];
    
    [self.contentLabel setDelegate:self];
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setValue:(id)[linkColor CGColor] forKey:(NSString*)kCTForegroundColorAttributeName];
    [mutableLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    [self.contentLabel setLinkAttributes:[NSDictionary dictionaryWithDictionary:mutableLinkAttributes]];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setValue:(id)[[UIColor blackColor] CGColor] forKey:(NSString*)kCTForegroundColorAttributeName];
    [mutableActiveLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableActiveLinkAttributes setValue:(id)[linkColor CGColor] forKey:(NSString*)kTTTBackgroundFillColorAttributeName];
    
    [self.contentLabel setActiveLinkAttributes:[NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes]];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)trimString:(NSString *)string
{
    return [string stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (IBAction)goButtonPressed:(id)sender {
    
    NSString *path = self.inputTextField.text;
    
    if (path.length < 1) return;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *stringURL = [NSString stringWithFormat:@"http://rapgenius.com/%@", path];
        NSURL *url = [NSURL URLWithString:stringURL];
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        NSMutableString *songString = [[NSMutableString alloc] init];
        
        NSMutableArray *hiperlinkArray = [[NSMutableArray alloc] init];
        
        if (data) {
            TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
            // //*[@id='main']/div[3]/div[3]
            // //*[@id='main']/div[@class='lyrics_container ']/div[@class='lyrics ']
            TFHppleElement *lyrics  = [doc peekAtSearchWithXPathQuery:@"//*[@id='main']/div[@class='lyrics_container ']/div[@class='lyrics ']"];
            
            
            for (TFHppleElement *child in [lyrics children]) {
                
                NSString *tag = [child tagName];
                
                if ([tag isEqualToString:@"br"]) [songString appendString:@"\n"];
                
                if ([tag isEqualToString:@"text"]) [songString appendString:[self trimString:[child content]]];
                
                if ([tag isEqualToString:@"a"]) {
                    
                    [songString appendString:@"||"];
                    
                    NSUInteger rangeStart = songString.length;
                    
                    NSArray *children = [child children];
                    
                    [children enumerateObjectsUsingBlock:^(TFHppleElement *elem, NSUInteger idx, BOOL *stop) {
                        if ([[elem tagName] isEqualToString:@"br"]) [songString appendString:@"\n"];
                        
                        if ([[elem tagName] isEqualToString:@"text"]) [songString appendString:[self trimString:[elem content]]];
                    }];
                    
                    NSUInteger rangEnd = songString.length - rangeStart;
                    
                    if (rangEnd - rangeStart > 0) {
                        
                        NSString *href = [child objectForKey:@"href"];
                        
                        if (!href) href = @"/";
                        
                        NSDictionary *hiperlinkObject = @{@"range" : [NSValue valueWithRange:NSMakeRange(rangeStart, rangEnd)], @"href" : href};
                        
                        [hiperlinkArray addObject:hiperlinkObject];
                    }
                    
                    [songString appendString:@"||"];
                    
                    
                }
                
            }
            
            NSLog(@"%@", songString);

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.contentLabel setText:songString];
//            [self.contentLabel setLinkAttributes:<#(NSDictionary *)#>]
            [hiperlinkArray enumerateObjectsUsingBlock:^(NSDictionary *linkDict, NSUInteger idx, BOOL *stop) {
                
                NSValue *rangeValue = [linkDict objectForKey:@"range"];
                NSString *link = [NSString stringWithFormat:@"http://rapgenius.com%@", [linkDict objectForKey:@"href"]];
                
                [self.contentLabel addLinkToURL:[NSURL URLWithString:link] withRange:[rangeValue rangeValue]];
            }];
            
            [self.contentLabel sizeToFit];

            [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, self.contentLabel.frame.size.height + 40.0f)];
        
            

            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

@end
