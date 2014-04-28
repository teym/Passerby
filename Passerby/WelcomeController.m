//
//  WelcomeController.m
//  Passerby
//
//  Created by Mike on 14-4-20.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import "WelcomeController.h"
#import "AppDelegate.h"

@interface WelcomeController ()
@property (weak) IBOutlet UITextField * nameField;
@property (copy) void(^FinalBlock)();
@end

@implementation WelcomeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -- action
-(IBAction)onStart:(id)sender{
    TheUserManage.myself.name = self.nameField.text;
    self.FinalBlock();
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)hideKeybord:(id)sender{
    [self.nameField resignFirstResponder];
}
@end
