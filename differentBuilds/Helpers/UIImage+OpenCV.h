//
//  UIImage+OpenCV.h
//  PrinterDemo
//
//  Created by Herb on 16/3/14.
//  Copyright © 2016年 fenzotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenCVHeader.h"

@interface UIImage (OpenCV)

+ (UIImage *)imageWithCVMat:(const cv::Mat &)cvMat;
+ (UIImage *)imageWithCVMat:(const cv::Mat &)img
                   fromArea:(const std::vector<cv::Point2f>& )fromArea
                     toSize:(const cv::Size2f& )tosize;
- (cv::Mat)cvMat;

@end
