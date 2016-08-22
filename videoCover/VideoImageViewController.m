//
//  VideoImageViewController.m
//  videoCover
//
//  Created by NengQuan on 16/6/30.
//  Copyright © 2016年 NengQuan. All rights reserved.
//

#import "VideoImageViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic,strong) NSURL *videoUrl ;
@property (nonatomic,assign) Float64 time ;
@end

@implementation VideoImageViewController

- (instancetype)initWithVideoUrl:(NSURL *)url CurentTime:(Float64)time
{
    if (self = [super init]) {
        _videoUrl = url;
        _time = time;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageView.image = [self thumbnailImageForVideoWithTIme:self.time];
    
}
- (IBAction)dimissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage*) thumbnailImageForVideoWithTIme:(Float64)i {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoUrl options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.requestedTimeToleranceAfter = kCMTimeZero;
    gen.requestedTimeToleranceBefore = kCMTimeZero;
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(i, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumbImg = [[UIImage alloc] initWithCGImage:image];
    
    return thumbImg;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
