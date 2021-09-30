//
//  StripeViewController.m
//  Workbox
//
//  Created by developer on 5/9/18.
//  Copyright © 2018 wei. All rights reserved.
//

#import "StripeViewController.h"

@interface StripeViewController ()<UIWebViewDelegate>{
    UIWebView *newWebView;
    BOOL inited;
    NSURLRequest *stripeRequest;
    __weak IBOutlet UILabel *lblTitle;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation StripeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *stripeURL = [NSString stringWithFormat:@"%@?email=%@&password=%@", STRIPE_CONNECT_URL, [Util getLoginUserName], [Util getLoginUserPassword]];
    NSURL *url = [NSURL URLWithString:stripeURL];
    stripeRequest =[NSURLRequest requestWithURL:url];
    _bCreateAccount = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (inited)
        return;
    
    newWebView = [[UIWebView alloc] initWithFrame:_webView.frame];
    [self.view addSubview:newWebView];
    inited = YES;
    newWebView.delegate = self;
    if(_bCreateAccount == YES) {
        NSString *stripeURL = [NSString stringWithFormat:@"%@", STRIPE_CREATE_ACCOUNT_URL];
        NSURL *url = [NSURL URLWithString:stripeURL];
        stripeRequest =[NSURLRequest requestWithURL:url];
        [newWebView loadRequest:stripeRequest];
    }
    else{
        [newWebView loadRequest:stripeRequest];
    }
    
    newWebView.backgroundColor = [UIColor clearColor];
    [newWebView setOpaque:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onBack:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) webViewDidStartLoad:(UIWebView *)webView{
    if([webView.request.URL.absoluteString isEqualToString:@"https://stripe.workbox.brainyapps.com/stripe-log"]) {
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:webView.request];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
//
    NSLog(@"Error: %@", webView.request.URL.absoluteString);
    
}


@end
