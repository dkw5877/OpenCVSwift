//
//  PatternDetectorWrapper.m
//  OpenCVSwift
//
//  Created by user on 1/24/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

#import "PatternDetectorWrapper.h"
#import "PatternDetector.cpp"
#import <opencv2/imgcodecs/ios.h>

//stuct to wrap cpp class object, we add the cpp object as a struct property
struct PatternDetectorCPP {
    PatternDetector *detector;
};


@implementation PatternDetectorWrapper

- (instancetype)init{
    self = [super init];
    if (self) {


    }
    return self;
}

- (id)initWithPattern:(UIImage*)pattern {
    self = [self init];
    if (self) {
        cv::Mat imageMat;
        UIImageToMat(pattern, imageMat);
        detectorWrapper = new PatternDetectorCPP(); //create struct wrapper
        detectorWrapper->detector = new PatternDetector(imageMat); //create cpp class
    }
    return self;
}

- (void)dealloc {
    delete detectorWrapper->detector;
    delete detectorWrapper;
}

- (bool)isTracking {
    bool result = detectorWrapper->detector->isTracking();
    NSLog(@" tracking %i", result);
    return  result;
}

- (float)matchValue {
    float value = detectorWrapper->detector->matchValue();
    NSLog(@"match value %f", value);
    return value;
}

- (void)scanFrame:(VideoFrame)frame {
//    NSLog(@"frame height:%ld  width:%ld", (long)frame.height, (long)frame.width);
    detectorWrapper->detector->scanFrame(frame);
}

@end
