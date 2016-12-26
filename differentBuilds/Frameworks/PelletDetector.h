//
//  OpenCVWrapper.h
//  PelletChecker
//
//  Created by Alex Burtnik on 12/6/16.
//  Copyright © 2016 Axcela. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#import <opencv2/opencv.hpp>
#pragma clang pop

using namespace cv;
using namespace std;

class PelletDetector {
    
public:
    static vector<KeyPoint> detectBlobs (Mat input);
    static Mat filterBlue(Mat input);
    
    static double evaluateDistribution(vector<KeyPoint> keypoints, Mat mat);
    static double averageSize(vector<KeyPoint> keypoints);
    
private:
    static vector<KeyPoint> findBlobs(Mat input, SimpleBlobDetector::Params params);
    static vector<KeyPoint> filterKeypointsBySize(vector<KeyPoint> keypoints);
    
    static uchar relevanceRGB(Vec3b color);
    
    static SimpleBlobDetector::Params parameters();
    
    static double averageNeighbourDistance (vector<KeyPoint> keypoints);
    static vector<double> closestNeighbourDistances(vector<KeyPoint> keypoints);
};
