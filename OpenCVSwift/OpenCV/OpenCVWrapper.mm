//
//  OpenCVWrapper.m
//  OpenCVSwift
//
//  Created by user on 1/10/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "PatternDetector.h"

using namespace std;
using namespace cv;

@implementation OpenCVWrapper

- (void) isThisWorking {
      cout << "Hey" << endl;
}

/* these methods are used in place of the category on UIImage */
//convert UIImage to CV:Mat
- (UIImage*)toCVMat:(UIImage*)image {
    cv:Mat imageMat;
    UIImageToMat(image, imageMat);
    return image;
}

//convert cvMat to UIImage
- (UIImage*)fromCVMat:(const cv::Mat)cvMat {
   return MatToUIImage(cvMat);
}


@end
