# ZJHShowGIF
iOS 显示动态图、GIF图方法总结。详情链接：http://www.jianshu.com/p/55fec384eee5

### 一、WebView加载
可以通过WebView加载本地Gif图和网络Gif图，但图片大小不能自适应控件大小，也不能设置Gif图播放时间。使用如下：

```
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
```

### 二、UIImageView加载多图动画
把动态图拆分成一张张图片，将一系列帧添加到animationImages数组里面，然后设置animation一系列属性，如动画时间，动画重复次数。例：

```
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
```

### 三、SDWebImage加载本地GIF
在SDWebImage这个库里有一个UIImage+GIF的类别，使用sd_animatedGIFWithData方法可以将GIF图片数据专为图片。例：

```
// 3、SDWebImage加载本地GIF
- (void)imageViewLocalGif {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"happy" ofType:@"gif"];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage sd_animatedGIFWithData:imageData];

    UIImageView *imageView = self.viewArr[2];
    imageView.image = image;
}
```

### 四、SDWebImage加载网络GIF
首先将网络gif图下载到本地，然后再用sd_animatedGIFWithData方法，转为可用的图片，下载gif图的方式有两种

方式一：采用SDWebImageDownloader下载，回调里面会有NSData。只是，你会发现采用SDWebImageDownloader下载，界面显示就是没有sd_setImageWithURL方法流畅，这是因为sd_setImageWithURL里面对cache和线程做了很多处理，保证了UI的流畅。

```
    NSString *imageStr = @"http://qq.yh31.com/tp/zjbq/201711142021166458.gif";
    NSURL *imgeUrl = [NSURL URLWithString:imageStr];
    SDWebImageDownloaderOptions options = 0;
    UIImageView *imageView = self.viewArr[3]; 
    
    // 方法一 SDWebImageDownloader下载
    SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
    [downloader downloadImageWithURL:imgeUrl
                             options:options
                            progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {

                            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                                imageView.image = [UIImage sd_animatedGIFWithData:data];
                            }];

```

方式二、sd_setImageWithURL下载，回调的时候不用image，去直接读cache。(首先要了解sd_setImageWithURL里的内部逻辑，下载完之后先入cache，再执行block，这才保证外面可以直接读取到)，取出来的就是NSData

```
    // 方法二 sd_setImageWithURL下载
    SDWebImageOptions opt = SDWebImageRetryFailed | SDWebImageAvoidAutoSetImage;
    [imageView sd_setImageWithURL:imgeUrl
                 placeholderImage:nil
                          options:opt
                        completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                            
                            if (image.images && image.images.count) {
                                NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:imageURL.absoluteString];
                                NSData *data = [NSData dataWithContentsOfFile:path];
                                UIImage *gifImage = [UIImage sd_animatedGIFWithData:data];
                                imageView.image = gifImage;
                            }
                        }];
```

### 五、FLAnimatedImage使用
FLAnimatedImage 是由Flipboard开源的iOS平台上播放GIF动画的一个优秀解决方案，在内存占用和播放体验都有不错的表现。FLAnimatedImage项目的流程比较简单，FLAnimatedImage就是负责GIF数据的处理，然后提供给FLAnimatedImageView一个UIImage对象。FLAnimatedImageView拿到UIImage对象显示出来就可以了。 例：

```
// 5、FLAnimatedImage使用
- (void)animatedImageViewShowGif {
    FLAnimatedImageView *imageView = self.viewArr[4];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"weiwei" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
    imageView.animatedImage = animatedImage;
}
```



