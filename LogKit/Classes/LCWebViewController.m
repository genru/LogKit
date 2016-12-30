//
//  LCWebViewController.m
//  Pods
//
//  Created by Chris Kap on 12/10/16.
//
//

@import WebKit;
#import "LCWebViewController.h"

@interface LCWebViewController ()
@property (nonatomic, strong) WKWebView* webView;
@end

@implementation LCWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_webView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onAction:)];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.webView loadHTMLString:self.htmlText baseURL:nil];
    self.navigationController.navigationBarHidden = NO;
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadData {
    NSString* content = [NSString stringWithContentsOfURL:self.fileUrl encoding:NSUTF8StringEncoding error:nil];
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    [self.webView loadHTMLString:content baseURL:nil];
}

- (void) onAction:(id) sender {
    UIActivityViewController* sheet = [[UIActivityViewController alloc] initWithActivityItems:@[self.fileUrl] applicationActivities:nil];
    [self presentViewController:sheet animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
