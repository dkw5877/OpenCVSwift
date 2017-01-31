//
//  OpenCVWrapper.h
//  OpenCVSwift
//
//  Created by user on 1/10/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

- (void)isThisWorking;

- (UIImage*)toCVMat:(UIImage*)image;

@end
