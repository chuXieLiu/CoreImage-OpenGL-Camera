# 简介

结合CoreImage的图像处理和OpenGL的绘制功能，实现一个实时滤镜相机

ios平台上支持的滤镜有一百多种，Demo中只挑选了几个简单的滤镜效果，

```objc

                 @"CIPhotoEffectChrome",// 铬黄
                 @"CIPhotoEffectFade",// 褪色
                 @"CIPhotoEffectInstant",// 怀旧
                 @"CIPhotoEffectMono",// 单色
                 @"CIPhotoEffectNoir",// 暗色
                 @"CIPhotoEffectProcess",// 冲印
                 @"CIPhotoEffectTonal",// 色调
                 @"CIPhotoEffectTransfer",// 岁月
                 @"CIColorPosterize",// 海报
                 @"CISepiaTone"// 褐色
                 

```

### 实时滤镜效果

* 铬黄

![](https://github.com/chuXieLiu/CoreImage-OpenGL-Camera/blob/master/screenshots/_chrome.png?raw=true">)

* 冲印

![](https://github.com/chuXieLiu/CoreImage-OpenGL-Camera/blob/master/screenshots/_process.png?raw=true">)

* 岁月

![](https://github.com/chuXieLiu/CoreImage-OpenGL-Camera/blob/master/screenshots/_transfer.png?raw=true">)

* 海报

![](https://github.com/chuXieLiu/CoreImage-OpenGL-Camera/blob/master/screenshots/_posterize.png?raw=true">)


Demo中使用AVAssetWriter和CMSampleBufferRef等处理类对录制进行实时采样和写入，保存滤镜效果。





