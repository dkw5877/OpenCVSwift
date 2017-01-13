//
//  AccelerationAnimation.swift
//  OpenCVSwift
//
//  Created by user on 1/11/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

import Foundation
import QuartzCore

class AccelerationAnimation : CAKeyframeAnimation {


    class func animationWithKeyPath<T : Evaluate>(keyPath:String,startValue:Double, endValue:Double, evaluationObject:T, steps:Int ) -> AccelerationAnimation where T: Evaluate {

        let animation = AccelerationAnimation(keyPath: keyPath)
        animation.calculateKeyFramesWithEvaluationObject(evaluationObject: evaluationObject, startValue: startValue, endValue: endValue, steps: steps)
        return animation

    }

    func calculateKeyFramesWithEvaluationObject<T : Evaluate>(evaluationObject:T, startValue:Double, endValue:Double,
                                                steps:Int) {

        let count = steps + 2
        var valueArray = [Double]()
        var progress = 0.0
        let increment = 1.0 / (Double(count) - 1.0)

        for _ in 0...count {
            let value = startValue + evaluationObject.evaluateAt(position: progress) * (endValue - startValue)
            valueArray.append(value)
            progress += increment
        }
    }

}
