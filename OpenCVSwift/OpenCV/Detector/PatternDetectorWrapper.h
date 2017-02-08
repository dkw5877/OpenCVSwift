//
//  PatternDetectorWrapper.h
//  OpenCVSwift
//
//  Created by user on 1/24/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CommonDataStructures.h"


//stuct to wrap cpp class object
struct PatternDetectorCPP;

@interface PatternDetectorWrapper : NSObject {
    struct PatternDetectorCPP *detectorWrapper;
}

- (id) initWithPattern:(UIImage*)pattern;
- (void) dealloc;
- (bool) isTracking;
- (CGPoint) matchPoint;
- (float) matchValue;
- (float) matchThresholdValue;
- (void) scanFrame:(VideoFrame)frame;
- (UIImage*)sampleImage;
- (bool)useTrackingHelper;


@end
