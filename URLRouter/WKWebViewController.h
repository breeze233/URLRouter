//
//  WKWebViewController.h
//  WKWebViewOC
//
//  Created by XiaoFeng on 2016/11/24.


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WKWebViewControllerStyle) {
    WKWebViewControllerStyleNone = 0,
    WKWebViewControllerInTab
};

@class WKWebView;
typedef void (^disssMissBlock)();

@interface WKWebViewController : UIViewController

@property (nonatomic, assign) WKWebViewControllerStyle style;

/**
 加载纯外部链接网页

 @param string URL地址
 */
- (void)loadWebURLSring:(NSString *)string;

/**
 加载本地网页
 
 @param string 本地HTML文件名
 */
- (void)loadWebHTMLSring:(NSString *)string;

/**
 加载外部链接POST请求(注意检查 XFWKJSPOST.html 文件是否存在 )
 postData请求块 注意格式：@"\"username\":\"xxxx\",\"password\":\"xxxx\""
 
 @param string 需要POST的URL地址
 @param postData post请求块
 */
- (void)POSTWebURLSring:(NSString *)string postData:(NSString *)postData;


@property (nonatomic,strong) disssMissBlock block;

- (void)disssMissBlock:(disssMissBlock)block;

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic)UIBarButtonItem* customBackBarItem;
@property (nonatomic, strong) NSString * cate_id;
@property (nonatomic, strong) NSString * cate_code;
@property (nonatomic, strong) NSString * product_type;
//仅当第一次的时候加载本地JS
@property(nonatomic,assign) BOOL needLoadJSPOST;

@property(nonatomic,assign,getter=IsNeedingHidebackBarItem) BOOL needHideBackBarItem;

- (void)roadLoadClicked;
- (void)closeItemClicked;
- (void)customBackItemClicked;
- (void)refreshItemClicked;
- (void)pushCurrentSnapshotViewWithRequest:(NSURLRequest*)request;
- (void)updateNavigationItems;
- (void)postRequestWithJS;
- (NSString *)getURL;
- (void)hideColseItem;
- (void)hideRefreshItem;
- (void)hideBackItem;
@end

#import <WebKit/WebKit.h>
@interface WeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
