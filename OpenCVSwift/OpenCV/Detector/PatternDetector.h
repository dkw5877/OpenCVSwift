//
//  PatternDetector.h
//  OpenCVTutorial
//
//  Created by Paul Sholtz on 12/14/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "CommonDataStructures.h"

#ifndef __OpenCVTutorial__PatternDetector__
#define __OpenCVTutorial__PatternDetector__


#define kUSE_TRACKING_HELPER 0

class PatternDetector {

#pragma mark Public Interface
public:
    
    //Constructor
    PatternDetector(const cv::Mat& pattern);

    //Scan the input video frame
    void scanFrame(VideoFrame frame);

    //Match APIs
    const cv::Point& matchPoint();
    float matchValue();
    float matchThresholdValue();

    //Tracking API
    bool isTracking();

    // Peek inside the pattern detector to assist marker tracking
    const cv::Mat& sampleImage();

#pragma mark Private Members
private:
    //Reference Marker Images
    cv::Mat m_patternImage;
    cv::Mat m_patternImageGray;
    cv::Mat m_patternImageGrayScaled;
    cv::Mat m_sampleImage;

    //Supporting Members
    cv::Point m_matchPoint;
    int m_matchMethod;
    float m_matchValue;
    float m_matchThresholdValue;
    float m_scaleFactor;
};

#endif /* defined(__OpenCVTutorial__PatternDetector__) */


