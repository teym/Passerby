//
//  ProfileViewController.m
//  Passerby
//
//  Created by Mike on 14-4-11.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"

@interface ProfileViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (weak) IBOutlet UISwitch * serviceSwitch;
@property (weak) IBOutlet UIImageView * avatar;
@property (weak) IBOutlet UITextField * nickName;
@property (weak) IBOutlet UITextField * shortText;
@property (weak) IBOutlet UITableView * table;
@end

@implementation ProfileViewController

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
    RAC(_serviceSwitch,on) = RACObserve(TheServiceManage, serviceOn);
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
#pragma mark --action
-(IBAction)onServiceSwitch:(UISwitch*)sender{
    sender.on?[TheServiceManage startService]:[TheServiceManage stopService];
}
-(IBAction)onBack:(id)sender{
    
}
#pragma mark --tableview
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * reusableIdentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reusableIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableIdentifier];
    }
    return cell;
}
@end
