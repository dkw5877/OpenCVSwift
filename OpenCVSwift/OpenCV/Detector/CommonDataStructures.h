//
//  CommonDataStructures.h
//  OpenCVSwift
//
//  Created by user on 1/24/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

#ifndef CommonDataStructures_h
#define CommonDataStructures_h


typedef struct {
    NSInteger width;
    NSInteger height;
    NSInteger stride;
    unsigned char * data;

} VideoFrame;

#endif /* CommonDataStructures_h */
