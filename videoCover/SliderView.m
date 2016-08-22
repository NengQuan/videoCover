//
//  SliderView.m
//  音视频混合
//
//  Created by NengQuan on 16/6/28.
//  Copyright © 2016年 厦门顶护体育用品有限公司. All rights reserved.
//

#import "SliderView.h"
@interface SliderView ()
{
    CGPoint startPoint;
    CGPoint endPoint;
}
@end
@implementation SliderView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch*touch = [touches anyObject];
    
    startPoint =[touch locationInView:self.superview];
//    [self.superview bringSubviewToFront:self];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch*touch = [touches anyObject];
    
     endPoint=[touch locationInView:self.superview];
    
    CGFloat x =endPoint.x - startPoint.x;
      CGFloat width=CGRectGetWidth(self.superview.frame)/8.0;
  
    if (endPoint.x<=width/2.0) {
       self.center = CGPointMake(width/2.0+0.01, self.center.y);
    }else
    if (endPoint.x>=CGRectGetWidth(self.superview.frame)-width) {
        self.center = CGPointMake(CGRectGetWidth(self.superview.frame)-width/2.0, self.center.y);
    }else
    {
          self.center = CGPointMake(self.center.x + x, self.center.y);
    }

    startPoint =endPoint;

}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    
}
- (void)touchesCancelled:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    
}
@end
