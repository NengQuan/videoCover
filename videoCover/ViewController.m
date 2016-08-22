//
//  ViewController.m
//  videoCover
//
//  Created by NengQuan on 16/6/30.
//  Copyright © 2016年 NengQuan. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "SliderView.h"
#import "VideoImageViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *videoDisplayView;
@property (weak, nonatomic) IBOutlet UIView *bottomImageView;

@property (nonatomic,strong) NSURL *videoUrl ;
@property (nonatomic,assign) CGFloat videoImageWidth ;// 底部固定帧图片的宽度
@property (nonatomic,assign) CGFloat videoLength ; // 视频长度
@property (nonatomic,strong) AVPlayer *player ;
@property (nonatomic,strong) AVPlayer *player1 ;
@property (nonatomic,assign) Float64 cutenttime ;

@property (nonatomic,strong) SliderView *sliderView ;
@property (nonatomic,strong) NSMutableArray *imagesArray ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view, typically from a nib.
    _videoImageWidth = ([UIScreen mainScreen].bounds.size.width -40)/8.0;
}


#pragma mark - 懒加载
- (SliderView *)sliderView
{
    if (_sliderView==nil) {
        _sliderView=[SliderView new];
        _sliderView.frame=CGRectMake(-5, -5, _videoImageWidth+10, _videoImageWidth+10);
        _sliderView.layer.borderWidth=2.0;
        _sliderView.layer.borderColor= [UIColor yellowColor].CGColor;
        [self.bottomImageView addSubview:_sliderView];
        [_sliderView addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _sliderView;
}

- (NSMutableArray *)imagesArray
{
    if (_imagesArray==nil) {
        _imagesArray=[[NSMutableArray alloc] initWithCapacity:0];
    }
    return _imagesArray;
}

#pragma mark - Action
- (IBAction)nextStepAction:(id)sender {
    VideoImageViewController *imageVC = [[VideoImageViewController alloc] initWithVideoUrl:self.videoUrl CurentTime:self.cutenttime];
    [self presentViewController:imageVC animated:YES completion:nil];
}

- (IBAction)selectVideoAction:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.mediaTypes =  @[(NSString *)kUTTypeMovie];
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium ;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *videoURL = info[UIImagePickerControllerMediaURL];
    self.videoUrl = videoURL;
    UIImage *image = [self thumbnailImageForVideoWithTIme:0];
    if(videoURL && image)
    {
        [picker dismissViewControllerAnimated:YES completion:^{
           
            [self getvideoLendth];//获取视频时长
            [self setupBottomView]; // 初始化bottomview
            [self playWithUrl:self.videoUrl];
        }];
    }else
    {
        [picker dismissViewControllerAnimated:YES completion:^{
            NSLog(@"导入失败");
        }];
    }
}

#pragma mark - Handle 
/** 播放视频 */
- (void)playWithUrl:(NSURL *)url{
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = self.videoDisplayView.bounds;
    playerLayer.contentsGravity = AVLayerVideoGravityResizeAspect;
    // 添加到imageview的layer上
    [self.videoDisplayView.layer addSublayer:playerLayer];
    [_player play];
    [_player pause];
    
    
    AVPlayerItem *playerItem1 = [AVPlayerItem playerItemWithURL:url];
    _player1 = [AVPlayer playerWithPlayerItem:playerItem1];
    AVPlayerLayer *playerLayer1 = [AVPlayerLayer playerLayerWithPlayer:_player1];
    playerLayer1.frame = self.sliderView.bounds;
     playerLayer1.contentsGravity = AVLayerVideoGravityResizeAspect;
    [self.sliderView.layer addSublayer:playerLayer1];
    [_player1 play];
    [_player1 pause];
    
}

- (void)setupBottomView
{
    for (int i =0; i<7;i++) {
        UIImage *image1=[self thumbnailImageForVideoWithTIme:i*(_videoLength/8.0)];
        [self.imagesArray addObject:image1];
        
    }
    // 放最后一帧图片
    UIImage *image1=[self thumbnailImageForVideoWithTIme:_videoLength];
    [self.imagesArray addObject:image1];
    
    // 放所有图片
    [self.imagesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageIV=[[UIImageView alloc] initWithFrame:CGRectMake(_videoImageWidth*idx, 0, _videoImageWidth, _videoImageWidth)];
        [imageIV setImage:self.imagesArray[idx]];
        [self.bottomImageView addSubview:imageIV];
    }];
    
    [self.bottomImageView bringSubviewToFront:self.sliderView];
    
    
}
/** 获取视频时长
 */
- (void)getvideoLendth
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoUrl options:nil];
    CMTime times= [asset duration];
    _videoLength=(CGFloat)times.value/times.timescale;
    NSLog(@"------------------->VideoLenth:%F<-------------",_videoLength);
}

/**
 *  通过videoURL获得图片
 *
 */
- (UIImage*) thumbnailImageForVideoWithTIme:(Float64)i {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoUrl options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(i, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumbImg = [[UIImage alloc] initWithCGImage:image];
    
    return thumbImg;
    
}

#pragma -mark- ======================observeValue======================
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"center"]) {
        
        CGFloat x=self.sliderView.center.x;
        CGFloat scale=(x-_videoImageWidth/2.0)/(self.view.frame.size.width-_videoImageWidth);
        NSLog(@"--===--%f",scale*_videoLength);
        NSLog(@"===++-%d",_player.currentTime.timescale);
        CMTime time = CMTimeMakeWithSeconds(scale*_videoLength, 600);
        [_player1 seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        self.cutenttime = scale * _videoLength;
    }
}

@end
