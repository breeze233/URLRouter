

typedef enum{
    loadWebURLString = 0,
    loadWebHTMLString,
    POSTWebURLString,
}wkWebLoadType;

#import "WKWebViewController.h"
#import <WebKit/WKWebView.h>
#import <WebKit/WebKit.h>
#import "UIViewController+UrlRouterPrivate.h"

static void *WkwebBrowserContext = &WkwebBrowserContext;

@interface WKWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,UINavigationControllerDelegate,UINavigationBarDelegate>


//设置加载进度条
@property (nonatomic,strong) UIProgressView *progressView;
//网页加载的类型
@property(nonatomic,assign) wkWebLoadType loadType;
//保存的网址链接
@property (nonatomic, copy) NSString *URLString;
//保存POST请求体
@property (nonatomic, copy) NSString *postData;
//保存请求链接
@property (nonatomic)NSMutableArray* snapShotsArray;
//返回按钮
@property (nonatomic,strong)UIButton* backButton;
//关闭按钮
@property (nonatomic)UIBarButtonItem* closeButtonItem;
//刷新按钮
@property (nonatomic)UIBarButtonItem* refreshButtonItem;
@property (nonatomic,strong)UIButton* refreshButton;

/** 原来导航栏的translucent   */
@property (nonatomic, assign) BOOL navTranslucent;

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.h5Url.length > 0) {
        [self loadWebURLSring:self.h5Url];
    }
    //加载web页面
    [self webViewloadURLType];
    //添加到主控制器上
    [self.view addSubview:self.wkWebView];
    //添加进度条
    [self.view addSubview:self.progressView];
    
    [self updateNavigationItems];
    

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_wkWebView) {
        // 设置代理
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.wkWebView setNavigationDelegate:nil];
    [self.wkWebView setUIDelegate:nil];

}

//注意，观察的移除
-(void)dealloc{
    
    [_wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_wkWebView removeObserver:self forKeyPath:@"title"];
    [_wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"NativeMethod"];
    
}

- (void)setTitle:(NSString *)title {
    if (self.style == WKWebViewControllerStyleNone) {
        [super setTitle:title];
    }
    else {
        self.navigationItem.title = title;
    }
}

#pragma mark - 点击事件

- (void)roadLoadClicked{
    [self.wkWebView reload];
}

- (void)customBackItemClicked{
    if (self.wkWebView.canGoBack) {
        [self.wkWebView goBack];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
        if (self.block != nil) {
            self.block();
        }
    }
    [self updateNavigationItems];
}

- (void)closeItemClicked{
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.block != nil) {
        self.block();
    }
    [self updateNavigationItems];
}


- (void)hideColseItem {
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.closeButtonItem = closeButton;
}

- (void)hideRefreshItem{
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.refreshButtonItem = refreshButton;
}

- (void)hideBackItem{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.customBackBarItem = backButton;
}

-(void)refreshItemClicked{
    
    [self.wkWebView reload];
}

-(void)disssMissBlock:(disssMissBlock)block {
    self.block = block;
}

- (NSString *)getURL{
    return self.URLString;
}

#pragma mark - ================ 加载方式 ================

- (void)webViewloadURLType{
    switch (self.loadType) {
        case loadWebURLString:{
            //创建一个NSURLRequest 的对象
            NSURLRequest * Request_zsj = [NSURLRequest requestWithURL:[NSURL URLWithString:self.URLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
            //加载网页
            [self.wkWebView loadRequest:Request_zsj];
            break;
        }
        case loadWebHTMLString:{
            [self loadHostPathURL:self.URLString];
            break;
        }
        case POSTWebURLString:{
            // JS发送POST的Flag，为真的时候会调用JS的POST方法
            self.needLoadJSPOST = YES;
            //POST使用预先加载本地JS方法的html实现，请确认WKJSPOST存在
            [self loadHostPathURL:@"WKJSPOST"];
            break;
        }
    }
}

- (void)loadHostPathURL:(NSString *)url{
    //获取JS所在的路径
    NSString *path = [[NSBundle mainBundle] pathForResource:url ofType:@"html"];
    //获得html内容
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //加载js
    [self.wkWebView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
}

// 调用JS发送POST请求
- (void)postRequestWithJS {
    // 拼装成调用JavaScript的字符串
    NSString *jscript = [NSString stringWithFormat:@"post('%@',{%@});", self.URLString, self.postData];
    // 调用JS代码
    [self.wkWebView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
    }];
}

- (void)loadWebURLSring:(NSString *)string{
    self.URLString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.loadType = loadWebURLString;
}

- (void)loadWebHTMLSring:(NSString *)string{
    self.URLString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.loadType = loadWebHTMLString;
}

- (void)POSTWebURLSring:(NSString *)string postData:(NSString *)postData{
    self.URLString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.postData = postData;
    self.loadType = POSTWebURLString;
}

#pragma mark - ================ 自定义返回/关闭按钮 ================
-(void)updateNavigationItems{
    
    [self.navigationItem setRightBarButtonItems:@[self.refreshButtonItem]];
    if (self.wkWebView.canGoBack) {
        [self.navigationItem setLeftBarButtonItems:@[self.customBackBarItem,self.closeButtonItem] animated:NO];
    }
    else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:@[self.customBackBarItem]];
        if (self.IsNeedingHidebackBarItem) {
            self.backButton.hidden = true;
        }
    }
}

//请求链接处理
-(void)pushCurrentSnapshotViewWithRequest:(NSURLRequest*)request{
    //    JROLog(@"push with request %@",request);
    NSURLRequest* lastRequest = (NSURLRequest*)[[self.snapShotsArray lastObject] objectForKey:@"request"];
    
    //如果url是很奇怪的就不push
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        //        JROLog(@"about blank!! return");
        return;
    }
    //如果url一样就不进行push
    if ([lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return;
    }
    UIView* currentSnapShotView = [self.wkWebView snapshotViewAfterScreenUpdates:YES];
    if (currentSnapShotView) {
        [self.snapShotsArray addObject:@{@"request":request,@"snapShotView":currentSnapShotView}];
    }
    
    
}

#pragma mark - ================ WKNavigationDelegate ================

//这个是网页加载完成，导航的变化
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    /*
     主意：这个方法是当网页的内容全部显示（网页内的所有图片必须都正常显示）的时候调用（不是出现的时候就调用），，否则不显示，或则部分显示时这个方法就不调用。
     */
    // 判断是否需要加载（仅在第一次加载）
    if (self.needLoadJSPOST) {
        // 调用使用JS发送POST请求的方法
        [self postRequestWithJS];
        // 将Flag置为NO（后面就不需要加载了）
        self.needLoadJSPOST = NO;
    }
    // 获取加载网页的标题
    self.title = self.wkWebView.title;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateNavigationItems];
}

//开始加载
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    //开始加载的时候，让加载进度条显示
    self.progressView.hidden = NO;
    
}

#pragma mark ================ WKUIDelegate ================

// 获取js 里面的提示
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
}

// js 信息的交流
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

// 交互。可输入的文本。
-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"textinput" message:@"JS调用输入框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    
}
#pragma mark  - KVO监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"title"]) {
        
        [self updateNavigationItems];
        if ([self.wkWebView.title isEqualToString:@""]) {
            return;
        }
        self.title = self.wkWebView.title;
        if ([self.wkWebView.title isEqualToString:@"贷款超市"] && self.IsNeedingHidebackBarItem) {
            self.backButton.hidden = true;
        }else{
            self.backButton.hidden = false;
        }
        
    }
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkWebView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        
        // Once complete, fade out UIProgressView
        if(self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
}

#pragma mark - ================ 懒加载 ================

- (WKWebView *)wkWebView{
    
    //清理缓存
    if ([[[UIDevice currentDevice] systemVersion] intValue ] > 9) {
        NSArray * types = @[WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeDiskCache];  // 9.0之后才有的
        NSSet *websiteDataTypes = [NSSet setWithArray:types];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
        }];
    }else{
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *errors;
        
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }
    
    if (!_wkWebView) {
        //设置网页的配置文件
        WKWebViewConfiguration * Configuration = [[WKWebViewConfiguration alloc]init];
       
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
            //允许视频播放
            Configuration.allowsAirPlayForMediaPlayback = YES;
        }
        // 允许在线播放
        Configuration.allowsInlineMediaPlayback = YES;
        // 允许可以与网页交互，选择视图
        Configuration.selectionGranularity = YES;
        // web内容处理池
        Configuration.processPool = [[WKProcessPool alloc] init];
        // 是否支持记忆读取
        Configuration.suppressesIncrementalRendering = YES;
       
        
        //自定义配置,一般用于 js调用oc方法(OC拦截URL中的数据做自定义操作)
        WKUserContentController * UserContentController = [[WKUserContentController alloc]init];
        // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
        [UserContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:@"NativeMethod"];
        // 允许用户更改网页的设置
        Configuration.userContentController = UserContentController;
        
        
        if (Configuration.userContentController.userScripts) {
        }

        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) configuration:Configuration];
        _wkWebView.scrollView.showsHorizontalScrollIndicator = NO;
        _wkWebView.scrollView.showsVerticalScrollIndicator = NO;
        _wkWebView.backgroundColor = [UIColor whiteColor];
        
        _wkWebView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _wkWebView.frame = CGRectMake(_wkWebView.frame.origin.x, _wkWebView.frame.origin.y , _wkWebView.frame.size.width, _wkWebView.frame.size.height);
        
        
        // 设置代理
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        //kvo 添加进度监控
        [_wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:WkwebBrowserContext];
        [_wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        
        //开启手势触摸
        _wkWebView.allowsBackForwardNavigationGestures = YES;
        // 设置 可以前进 和 后退
        
        //适应你设定的尺寸
        [_wkWebView sizeToFit];
    }
    return _wkWebView;
}

-(UIBarButtonItem*)customBackBarItem{
    
    if (!_customBackBarItem) {
        
        self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.backButton.frame = CGRectMake(0, 0, 17, 30);
        [self.backButton setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(customBackItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _customBackBarItem =  [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    }
    return _customBackBarItem;
}

-(UIBarButtonItem*)closeButtonItem{
    if (!_closeButtonItem) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setImage:[UIImage imageNamed:@"Group"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(closeItemClicked) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, 36, 30);
        _closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
    }
    return _closeButtonItem;
}

-(UIBarButtonItem*)refreshButtonItem{
    
    if (!_refreshButtonItem) {
        
        self.refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.refreshButton setImage:[UIImage imageNamed:@"nav_icon_refresh"] forState:UIControlStateNormal];
        [self.refreshButton addTarget:self action:@selector(refreshItemClicked) forControlEvents:UIControlEventTouchUpInside];
        self.refreshButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);
        self.refreshButton.frame = CGRectMake(0, 0, 30, 30);
        _refreshButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.refreshButton];
    }
    return _refreshButtonItem;
}

- (UIProgressView *)progressView{
    
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0,0, self.view.bounds.size.width, 3);
        // 设置进度条的色彩
        [_progressView setTrackTintColor:[UIColor clearColor]];
        _progressView.progressTintColor = self.navigationController.navigationBar.tintColor;
    }
    return _progressView;
}


-(NSMutableArray*)snapShotsArray{
    if (!_snapShotsArray) {
        _snapShotsArray = [NSMutableArray array];
    }
    return _snapShotsArray;
}


#pragma mark - ================ WKScriptMessageHandler ================
//拦截执行网页中的JS方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end

@implementation WeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}
#pragma mark - ================ WKScriptMessageHandler ================
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end
