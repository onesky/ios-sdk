#import "OneSkyWebViewController.h"
#import "OneSkyHelper.h"
#import "NSString+Additions.h"

@implementation OneSkyWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"Translate", nil);
    OneSkyHelper *helper = [OneSkyHelper sharedHelper];
    NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *url = [NSString stringWithFormat:@"http://www.oneskyapp.com/mobile/?key=%@&platform-id=%d&l=%@", 
                     [helper.key URLEncodedString],
                     helper.platformId,
                     [lang URLEncodedString]];
    if ([helper.sortedHistoryKeys count] > 0) {
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:helper.sortedHistoryKeys options:NSJSONWritingPrettyPrinted error:nil];
        NSString* JSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        url = [url stringByAppendingFormat:@"&keys=%@", [JSON URLEncodedString]];
    }
//    url = [NSString stringWithFormat:@"http://fb-test.oneskyapp.com/index/cookie"];
//    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    NSLog(@"------HTTPShouldHandleCookies----%d", [request HTTPShouldHandleCookies]);
//    webView.delegate = self;
    [webView loadRequest:request];
     NSLog(@"webview url=%@", url);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    webView.delegate = nil;
    [webView release];
    webView = nil;
    
    [super dealloc];
    
}

//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    NSString *url = @"http://fb-test.oneskyapp.com/index/cookie";
//    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:url]];
//    NSLog(@"------HTTPShouldHandleCookies----%@", cookies);
//}

@end
