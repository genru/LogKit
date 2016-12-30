//
//  LKViewController.m
//  LogKit
//
//  Created by chris on 12/10/2016.
//  Copyright (c) 2016 chris. All rights reserved.
//

#import "LKViewController.h"
#import <LogKit/Logcat.h>

@interface LKViewController ()
@end

@implementation LKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    DLog(@"%s", __FUNCTION__);
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DLog(@"%s", __FUNCTION__);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)action:(id)sender {
    DLog(@"%s", __FUNCTION__);
    UIViewController* dest = [Logcat sharedInstance].fileViewController;
//    [self presentViewController:dest animated:YES completion:nil];
//    [self showViewController:dest sender:sender];
    UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:dest];
    [self presentViewController:navi animated:YES completion:nil];
}

- (IBAction)showVersionInfo:(id)sender {
    UIAlertController* alert = [Logcat sharedInstance].infoAlert;
    [self presentViewController:alert animated:YES completion:nil];
}

@end
