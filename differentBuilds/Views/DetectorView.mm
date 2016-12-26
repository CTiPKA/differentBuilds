//
//  DetectionView.m
//  PelletChecker
//
//  Created by Alex Burtnik on 12/8/16.
//  Copyright © 2016 Axcela. All rights reserved.
//

#import "DetectorView.h"
#import "OpenCVHeader.h"
#import "UIImage+OpenCV.h"
#import "PelletDetector.h"
//#import "CardDetector.h"
#import <AVFoundation/AVFoundation.h>
//#import <MBPro

@interface DetectorView () {
    vector<KeyPoint> _keyPoints;
}

@property(nonatomic, strong) UIImageView *imageView;

//@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) UIImage *secondaryImage;

@property(nonatomic, strong) UIView *markersView;
@property(nonatomic, strong) NSMutableArray *markers;

@end

@implementation DetectorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void) setup {    
    self.strokeColor = [UIColor redColor];
    self.fillColor = [UIColor clearColor];
    self.showMarkers = YES;
    
    self.imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
    
    self.markersView = [UIView new];
    [self addSubview:_markersView];
    
    self.markers = [NSMutableArray array];
    
//    [self addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)]];
}

//- (void) tapRecognized: (UITapGestureRecognizer *) tapRecognizer {
//    CGPoint point = [tapRecognizer locationInView:tapRecognizer.view];
//    [self detectCardOnImage:self.image point:point completion:nil];
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
//    _markersView.frame = _imageView.image ? AVMakeRectWithAspectRatioInsideRect(_imageView.image.size, _imageView.frame) : CGRectZero;
}

- (void) setImage: (UIImage *) image {
    _image = image;
    _imageView.image = image;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void) setShowMarkers:(BOOL)showMarkers {
    _showMarkers = showMarkers;
    _markersView.hidden = !showMarkers;
}

- (void) setShowBinaryImage:(BOOL)showBinaryImage {
    _showBinaryImage = showBinaryImage;
    _imageView.image = _showBinaryImage ? _secondaryImage : _image;
}

- (double) scale {
    return _markersView.bounds.size.width / _imageView.image.size.width;
}

#pragma mark Markers

- (void) createMarkers {
    [self removeAllMarkers];
    
    if (_imageView.image.size.width) {
        double scale = [self scale];
        for (int i = 0; i < _keyPoints.size(); i++) {
            KeyPoint keyPoint = _keyPoints[i];
            CGPoint center = CGPointMake(keyPoint.pt.x * scale, keyPoint.pt.y * scale);
            CGFloat radius = keyPoint.size * scale;
            [self createMarkerAtPoint:center radius:radius];
        }
    }
}

- (void) createMarkerAtPoint: (CGPoint) center radius: (CGFloat) radius {
    CAShapeLayer *marker = [CAShapeLayer layer];

    marker.frame = CGRectMake(center.x - radius, center.y - radius, 2 * radius, 2 * radius);
    marker.path = [UIBezierPath bezierPathWithOvalInRect:marker.bounds].CGPath;
    marker.strokeColor = _strokeColor.CGColor;
    marker.fillColor = _fillColor.CGColor;

    [_markers addObject:marker];
    [_markersView.layer addSublayer:marker];
}

- (void) removeAllMarkers {
    for (CAShapeLayer *marker in self.markers) {
        [marker removeFromSuperlayer];
    }
}

#pragma mark Detection

- (void) reset {
    _keyPoints.clear();
    _secondaryImage = nil;
    [self setNeedsDisplay];
}

//- (void) detectCardOnImage: (UIImage *) image
//                     point: (CGPoint) point
//                completion: (void(^)(UIImage *image, float area, NSTimeInterval calculationTime)) completion {
//    
//    if (image) {
//        [self reset];
//        
//        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSDate *startDate = [NSDate date];            
//            cv::Point imagePoint = [self imagePoint:point];
//            Mat result = CardDetector::detectCard(image.cvMat, imagePoint);
//            NSTimeInterval calculationTime = [[NSDate date] timeIntervalSinceDate:startDate];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.image = [UIImage imageWithCVMat:result];
//                self.secondaryImage = image;
//                if (completion) {
//                    completion(image, 0, calculationTime);
//                }
//            });
//        });
//    }
//}

- (void) detectPelletsOnImage: (UIImage *) image
                     blobSize: (CGFloat) blobSize
                   completion: (void(^)(UIImage *image, NSInteger blobsCount, double evaluation, double averageSize, NSTimeInterval calculationTime)) completion {
    if (image) {
        [self reset];
        self.image = image;
//        Swi
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDate *startDate = [NSDate date];
            Mat input = image.cvMat;
            
//            if (blobSize > 0)
//                _keyPoints = PelletDetector::detectBlobs(input, blobSize);
//            else
                _keyPoints = PelletDetector::detectBlobs(input);
            
            double evaluation = PelletDetector::evaluateDistribution(_keyPoints, input);
            double averageSize = PelletDetector::averageSize(_keyPoints);
            NSTimeInterval calculationTime = [[NSDate date] timeIntervalSinceDate:startDate];
            Mat binaryMat = PelletDetector::filterBlue(input);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
                self.secondaryImage = [UIImage imageWithCVMat:binaryMat];
//                self.image = self.secondaryImage;
                [self createMarkers];
                if (completion) {
                    completion(image, _keyPoints.size(), evaluation, averageSize, calculationTime);
                }
            });
        });
    }
}

#pragma mark Helpers

- (cv::Point) imagePoint: (CGPoint) point {
    CGPoint convertedPoint = [self convertPoint:point toView:_markersView];
    return cv::Point(convertedPoint.x/self.scale, convertedPoint.y/self.scale);
}

@end
