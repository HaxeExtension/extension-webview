#import <UIKit/UIKit.h>
#include <hx/CFFI.h>
#include <WebViewEx.h>

typedef void (*OnUrlChangingFunctionType)(NSString *);
typedef void (*OnCloseClickedFunctionType)();
typedef void (^OnFinishLoadingFunctionType)();

@interface WebViewDelegate : NSObject <UIWebViewDelegate>
@property (nonatomic) OnUrlChangingFunctionType onUrlChanging;
@property (nonatomic) OnCloseClickedFunctionType onCloseClicked;
@property (nonatomic) OnFinishLoadingFunctionType onFinishLoading;
@end

@implementation WebViewDelegate
@synthesize onUrlChanging;
@synthesize onFinishLoading;
@synthesize onCloseClicked;
- (BOOL)webView:(UIWebView *)instance shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	onUrlChanging([[request URL] absoluteString]);
    
    return YES;
}
- (void) onCloseButtonClicked:(UIButton *)closeButton {
    onCloseClicked();
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    onFinishLoading();
}
@end

namespace webviewex {
    BOOL hasCloseButton = NO;
	UIWebView *instance;
	UIButton *closeButton;
	WebViewDelegate *webViewDelegate;
	AutoGCRoot *onDestroyedCallback = 0;
	AutoGCRoot *onURLChangingCallback = 0;
	void init(value, value, bool);
	void navigate(const char *);
	void destroy();
	void onUrlChanging(NSString *);
    
	void init(value _onDestroyedCallback, value _onURLChangingCallback, bool withPopup) {
		if(instance != nil) destroy();
		
		onDestroyedCallback = new AutoGCRoot(_onDestroyedCallback);
		onURLChangingCallback = new AutoGCRoot(_onURLChangingCallback);
		
		webViewDelegate = [[WebViewDelegate alloc] init];
		webViewDelegate.onUrlChanging = &onUrlChanging;
		webViewDelegate.onCloseClicked = &destroy;
		
		CGRect screen = [[UIScreen mainScreen] bounds];
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        
        NSString *dpi = @"mdpi";
        int padding = 58;
        
        if(screenScale > 1.0) {
            dpi = @"xhdpi";
            padding = 59;
        }
        
        padding /= 4;
        if(!withPopup) padding = 0;
        
        instance = [[UIWebView alloc] initWithFrame:CGRectMake(padding, padding + screen.size.height, screen.size.width - (padding * 2), screen.size.height - (padding * 2))];
		
        webViewDelegate.onFinishLoading = ^{
            // Transition from bottom to top
            [UIView animateWithDuration: 0.3
                delay: 0.0
                options: UIViewAnimationOptionCurveEaseOut
                animations:^{
                    instance.frame = CGRectMake(padding, padding, screen.size.width - (padding * 2), screen.size.height - (padding * 2));
                } 
                completion:^(BOOL finished){
            }];
        };
        
        instance.delegate = webViewDelegate;
		instance.scalesPageToFit=YES;
        
        //instance.scrollView.bounces = NO;
        [instance setBackgroundColor:[UIColor clearColor]];
        [instance setOpaque:NO];

        // Reset cache
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];

        [[[UIApplication sharedApplication] keyWindow] addSubview:instance];
        
        NSString *path = [[NSBundle mainBundle] pathForResource: @"assets/assets/webview/background.png" ofType: nil];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile: path];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
            imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
            imageView.contentMode = UIViewContentModeScaleToFill;
            imageView.frame = instance.bounds;
            [instance insertSubview:imageView atIndex:0];
        }

		
        path = [[NSBundle mainBundle] pathForResource: @"assets/assets/webview/close.png" ofType: nil];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        	UIImage *closeImage = [[UIImage alloc] initWithContentsOfFile: path];
			closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[closeButton setImage:closeImage forState:UIControlStateNormal];
			closeButton.adjustsImageWhenHighlighted = NO;
			closeButton.frame = CGRectMake(screen.size.width - 44 - 8, 8, 44, 44);
			[closeButton addTarget:webViewDelegate action:@selector(onCloseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
			//[[[UIApplication sharedApplication] keyWindow] addSubview:closeButton];
            [instance addSubview:closeButton];

            hasCloseButton = YES;
        }
	}
    
	void navigate (const char *url) {
		NSURL *_url = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"%@%@", [[NSString alloc] initWithUTF8String:url], hasCloseButton ? @"?app=1" : @""]];
		NSURLRequest *req = [[NSURLRequest alloc] initWithURL:_url];
		[instance loadRequest:req];
	}

	void loadHtml (const char *html){
		[instance loadHTMLString:[NSString stringWithUTF8String:html] baseURL: nil];
    	instance.allowsInlineMediaPlayback = YES;
    	instance.mediaPlaybackRequiresUserAction = NO;
	}

	void destroy(){
		if(instance==nil) return;
		val_call0(onDestroyedCallback->get());
		[instance stopLoading];

        CGRect screen = [[UIScreen mainScreen] bounds];
        int padding = 0;

        // Transition from top to bottom
        UIWebView *localInstance = instance;
        [UIView animateWithDuration: 0.2
            delay: 0.0
            options: UIViewAnimationOptionCurveEaseIn
            animations:^{
                localInstance.frame = CGRectMake(padding, padding + screen.size.height, screen.size.width - (padding * 2), screen.size.height - (padding * 2));
            }
            completion:^(BOOL finished){
            if (finished) {
                [localInstance removeFromSuperview];
                if(closeButton != nil) {
                    [closeButton removeFromSuperview];
                }
                //[localInstance release];
            }
        }];
        instance=nil;
	}
	
	void onUrlChanging (NSString *url) {
		val_call1(onURLChangingCallback->get(), alloc_string([url cStringUsingEncoding:NSUTF8StringEncoding]));
	}
}
