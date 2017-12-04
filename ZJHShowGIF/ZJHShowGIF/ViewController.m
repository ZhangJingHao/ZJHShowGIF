//
//  ViewController.m
//  ZJHShowGIF
//
//  Created by ZhangJingHao2345 on 2017/12/1.
//  Copyright © 2017年 ZhangJingHao2345. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+GIF.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "FLAnimatedImage.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *viewArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 0、创建界面
    [self setupUI];
    
    // 1、WebView加载
    [self webViewShowGif];
    
    // 2、UIImageView加载多图动画
    [self imageViewStartAnimating];
    
    // 3、SDWebImage加载本地GIF
    [self imageViewLocalGif];
    
    // 4、SDWebImage加载网络GIF
    [self webImageGif];
    
    // 5、FLAnimatedImage使用
    [self animatedImageViewShowGif];
}

// 0、创建界面
- (void)setupUI {
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    
    NSArray *nameArr = @[@"WebView加载",
                         @"UIImageView加载多图",
                         @"SDWebImage加载本地GIF",
                         @"SDWebImage加载网络GIF",
                         @"FLAnimatedImage使用"];
    
    NSArray *classArr = @[@"UIWebView",
                          @"UIImageView",
                          @"UIImageView",
                          @"UIImageView",
                          @"FLAnimatedImageView"];
    
    self.viewArr = [NSMutableArray arrayWithCapacity:classArr.count];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat backW = width * 0.6;
    CGFloat backX = (width - backW) / 2;
    CGFloat backH = backW * 1.15;
    CGFloat backY = 0;
    for (int i = 0; i < nameArr.count; i++) {
        backY = (20 + backH) * i;
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(backX, backY, backW, backH)];
        [scrollView addSubview:backView];
       
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, backW, backH - backW)];
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = nameArr[i];
        [backView addSubview:lab];
        
        Class viewClass = NSClassFromString(classArr[i]);
        UIView *imageView = [[viewClass alloc] initWithFrame:CGRectMake(0, backH - backW, backW, backW)];
        [backView addSubview:imageView];
        [self.viewArr addObject:imageView];
    }
    scrollView.contentSize = CGSizeMake(0, backY + backH + 20);
}

// 1、WebView加载
- (void)webViewShowGif {
    UIWebView *webView = self.viewArr[0];
    
    // 本地地址
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"hello" ofType:@"gif"];
    // 网路地址
//    NSString *imagePath = @"http://qq.yh31.com/tp/zjbq/201711092144541829.gif";
    
    NSURL *imageUrl = [NSURL URLWithString:imagePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
    [webView loadRequest:request];
}

// 2、UIImageView加载多张图片，播放
- (void)imageViewStartAnimating {
    UIImageView *imageView = self.viewArr[1];
    
    NSMutableArray *imageArr = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i<3; i++) {
        NSString *imageStr = [NSString stringWithFormat:@"import_progress%d",i + 1];
        UIImage *image = [UIImage imageNamed:imageStr];
        [imageArr addObject:image];
    }
    imageView.animationImages = imageArr;
    imageView.animationDuration = 2;
    [imageView startAnimating];
}

// 3、SDWebImage加载本地GIF
- (void)imageViewLocalGif {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"happy" ofType:@"gif"];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage sd_animatedGIFWithData:imageData];

    UIImageView *imageView = self.viewArr[2];
    imageView.image = image;
}

// 4、SDWebImage加载网络GIF，先下载、后展示
- (void)webImageGif {
    NSString *imageStr = @"http://qq.yh31.com/tp/zjbq/201711142021166458.gif";
    NSURL *imgeUrl = [NSURL URLWithString:imageStr];
    SDWebImageDownloaderOptions options = 0;
    UIImageView *imageView = self.viewArr[3];
    
//     方法一 SDWebImageDownloader下载
    SDImageCache *imageCache = [SDWebImageManager sharedManager].imageCache;
    NSString *imagePath = [imageCache defaultCachePathForKey:imgeUrl.absoluteString];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    if (imageData) {
        imageView.image = [UIImage sd_animatedGIFWithData:imageData];
        return ;
    }
    SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
    [downloader downloadImageWithURL:imgeUrl
                             options:options
                            progress:nil
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                               [imageCache storeImage:image
                                            imageData:data
                                               forKey:imgeUrl.absoluteString
                                               toDisk:YES
                                           completion:nil];
                               imageView.image = [UIImage sd_animatedGIFWithData:data];
                            }];
    
    // 方法二 sd_setImageWithURL下载
//    SDWebImageOptions opt = SDWebImageRetryFailed | SDWebImageAvoidAutoSetImage;
//    [imageView sd_setImageWithURL:imgeUrl
//                 placeholderImage:nil
//                          options:opt
//                        completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//
//                            if (image.images && image.images.count) {
//                                NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:imageURL.absoluteString];
//                                NSData *data = [NSData dataWithContentsOfFile:path];
//                                UIImage *gifImage = [UIImage sd_animatedGIFWithData:data];
//                                imageView.image = gifImage;
//                            }
//                        }];
}

// 5、FLAnimatedImage使用
- (void)animatedImageViewShowGif {
    FLAnimatedImageView *imageView = self.viewArr[4];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"weiwei" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
    imageView.animatedImage = animatedImage;
}

@end
