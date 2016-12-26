//
//  UIImage+OpenCV.m
//  PrinterDemo
//
//  Created by Herb on 16/3/14.
//  Copyright © 2016年 fenzotech. All rights reserved.
//

#import "UIImage+OpenCV.h"

@implementation UIImage (OpenCV)

#pragma mark Conversion

+ (UIImage *)imageWithCVMat:(const cv::Mat &)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    CGColorSpaceRef colorSpace;
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

+ (UIImage *)imageWithCVMat:(const cv::Mat &)img
                   fromArea:(const std::vector<cv::Point2f>& )fromArea
                     toSize:(const cv::Size2f& )tosize {
    // build to area
    cv::Mat dst = cv::Mat::zeros(tosize.height, tosize.width, CV_8UC3);
    std::vector<cv::Point2f> toArea;
    toArea.push_back(cv::Point(0, 0));
    toArea.push_back(cv::Point(tosize.width - 1, 0));
    toArea.push_back(cv::Point(0, tosize.height - 1));
    toArea.push_back(cv::Point(tosize.width - 1, tosize.height - 1));
    
    // get transformation matrix
    cv::Mat transmtx = cv::getPerspectiveTransform(fromArea, toArea);
    
    // apply perspective transformation
    cv::warpPerspective(img, dst, transmtx, dst.size());
    
    return [UIImage imageWithCVMat:dst];
}

- (cv::Mat)cvMat
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

@end
