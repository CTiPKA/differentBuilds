//
//  DetectionView.h
//  PelletChecker
//
//  Created by Alex Burtnik on 12/8/16.
//  Copyright © 2016 Axcela. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetectorView : UIView

@property(nonatomic, strong) UIImage *image;

@property(nonatomic, strong) UIColor *strokeColor;
@property(nonatomic, strong) UIColor *fillColor;

@property(nonatomic, assign) BOOL showMarkers;
@property(nonatomic, assign) BOOL showBinaryImage;

//- (void) detectCardOnImage: (UIImage *) image
//                     point: (CGPoint) point
//                completion: (void(^)(UIImage *image, float area, NSTimeInterval calculationTime)) completion;

- (void) detectPelletsOnImage: (UIImage *) image
                     blobSize: (CGFloat) blobSize
                   completion: (void(^)(UIImage *image, NSInteger blobsCount, double evaluation, double averageSize, NSTimeInterval calculationTime)) completion;

@end
