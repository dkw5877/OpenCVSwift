//
//  UIViewExtensions.swift
//  OpenCVSwift
//
//  Created by user on 1/11/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

import Foundation
import UIKit

enum AnimationDirection {
    case AnimationDirectionFromTop
    case AnimationDirectionFromBottom
}

let kAnimationLabel                       = "kAnimationLabel"
let kAnimationCompletionBlock             = "kAnimationCompletionBlock"
let kAnimationDirectionFromTopInLabel     = "kAnimationDirectionFromTopIn"
let kAnimationDirectionFromTopOutLabel    = "kAnimationDirectionFromTopOut"
let kAnimationDirectionFromBottomInLabel  = "kAnimationDirectionFromBottomIn"
let kAnimationDirectionFromBottomOutLabel = "kAnimationDirectionFromBottomOut"
let kAnimationPopIn                       = "kAnimationPopIn"
let kAnimationPopOut                      = "kAnimationPopOut"
let kAnimationDurationSlideIn:CGFloat = 1.50
let kAnimationDurationSlideOut:CGFloat = 0.75
let kAnimationDurationPop = 0.70
let kAnimationInterstitialSteps = 99

typealias CompletionHandlerClosureType = () -> ()

extension UIView: CAAnimationDelegate {

    func slideIn(fromDirection:AnimationDirection, completion:CompletionHandlerClosureType) {

        alpha = 1.0

        let endY = center.y
        var startY:CGFloat = 0.0

        switch ( fromDirection ) {
        case .AnimationDirectionFromTop:
            startY = center.y - frame.size.height
        case .AnimationDirectionFromBottom:
            startY = center.y + frame.size.height
        }

        CATransaction.begin()
        CATransaction.setValue(kCFBooleanFalse, forKey: kCATransactionDisableActions)
        CATransaction.setValue(kAnimationDurationSlideIn, forKey: kCATransactionAnimationDuration)
        layer.position = CGPoint(x: center.x, y: endY)

        let evaluationObject = SecondOrderResponseEvaluator(omega: 20.0, zeta: 0.33)
        let interstitialSteps = kAnimationInterstitialSteps
        let animation = AccelerationAnimation.animationWithKeyPath(keyPath: "position.y", startValue: Double(startY), endValue: Double(endY), evaluationObject: evaluationObject, steps: interstitialSteps)
        animation.delegate = self
        animation.setValue(completion, forKey: kAnimationCompletionBlock)
        layer.setValue(endY, forKey: "position.y")

        switch ( fromDirection ) {
        case .AnimationDirectionFromTop:
            animation.setValue(kAnimationDirectionFromTopInLabel, forKey: kAnimationLabel)
        case .AnimationDirectionFromBottom:
            animation.setValue(kAnimationDirectionFromBottomInLabel, forKey: kAnimationLabel)
        }

        layer.add(animation, forKey: "position")
        CATransaction.commit()
        setNeedsDisplay()

    }

    func slideOut(fromDirection:AnimationDirection, completion:CompletionHandlerClosureType) {

        let startY = self.center.y
        var endY:CGFloat = 0.0

        switch ( fromDirection ) {
        case .AnimationDirectionFromTop:
            endY = center.y - frame.size.height
        case .AnimationDirectionFromBottom:
            endY = center.y + frame.size.height
        }

        CATransaction.begin()
        CATransaction.setValue(kCFBooleanFalse, forKey: kCATransactionDisableActions)
        CATransaction.setValue(kAnimationDurationSlideOut, forKey: kCATransactionAnimationDuration)
        layer.position = CGPoint(x: center.x, y: endY)

        let evaluationObject = ReverseQuadraticEvaluator(a: 0.0, b: 0.35)
        let interstitialSteps = kAnimationInterstitialSteps
        let animation = AccelerationAnimation.animationWithKeyPath(keyPath: "position.y", startValue: Double(startY), endValue: Double(endY), evaluationObject: evaluationObject, steps: interstitialSteps)
        animation.delegate = self
        animation.setValue(completion, forKey: kAnimationCompletionBlock)
        layer.setValue(endY, forKey: "position.y")

        switch ( fromDirection ) {
        case .AnimationDirectionFromTop:
            animation.setValue(kAnimationDirectionFromTopOutLabel, forKey: kAnimationLabel)

            break;
        case .AnimationDirectionFromBottom:
            animation.setValue(kAnimationDirectionFromBottomOutLabel, forKey: kAnimationLabel)
            break;
        }

        layer.add(animation, forKey: "position")
        CATransaction.commit()
        setNeedsDisplay()

    }

    func popIn(completion:CompletionHandlerClosureType) {

        // Clear exiting animations
        self.layer.removeAllAnimations()

        // Add new animation
        self.alpha = 1.0
        let animation = generatePopInAnimation()
        animation.delegate = self
        animation.setValue(kAnimationPopIn, forKey: kAnimationLabel)
        animation.setValue(completion, forKey: kAnimationCompletionBlock)
        self.layer.add(animation, forKey: kAnimationPopIn)

    }

    func generatePopInAnimation() -> CAAnimation {
        let scale = CAKeyframeAnimation(keyPath:"transform.scale")
        scale.duration = kAnimationDurationPop
        scale.values = [0.50, 1.20, 0.85, 1.05, 0.98, 1.00]

        let fadeIn = CABasicAnimation(keyPath:"opacity")
        fadeIn.duration  = kAnimationDurationPop * 0.4
        fadeIn.fromValue = 0.0
        fadeIn.toValue = 1.0
        fadeIn.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
        fadeIn.fillMode = kCAFillModeForwards;

        return generateAnimationGroup(animations:[scale, fadeIn])
    }

    func popOut(completion:CompletionHandlerClosureType) {

        // Remove any pre-existing animations
        layer.removeAllAnimations()

        // Add a new animation
        let animation = generatePopOutAnimation()
        animation.delegate = self
        animation.setValue(kAnimationPopOut, forKey: kAnimationLabel)
        animation.setValue(completion, forKey: kAnimationCompletionBlock)
        layer.add(animation, forKey:kAnimationPopOut)

    }

    func generatePopOutAnimation() -> CAAnimation {

        let duration = kAnimationDurationPop * 0.8
        let scale = CAKeyframeAnimation(keyPath: "transform.scale")
        scale.duration = duration
        scale.isRemovedOnCompletion = false
        scale.values = [1.0, 1.2, 0.75]

        let fraction = 0.4
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.duration  = duration * fraction
        fadeOut.fromValue = 1.0
        fadeOut.toValue   = 0.0
        fadeOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        fadeOut.beginTime = duration * (1.0 - fraction);
        fadeOut.fillMode = kCAFillModeForwards;

        let group = generateAnimationGroup(animations:[scale, fadeOut])
        group.fillMode = kCAFillModeForwards
        return group
    }

    func generateAnimationGroup(animations:Array<CAAnimation>) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.animations = animations
        group.delegate = self //currently ignored (see docs)
        group.duration = kAnimationDurationPop
        group.isRemovedOnCompletion = false
        return group
    }

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {

        let identifier = anim.value(forKey: kAnimationLabel) as? String

        let completion:CompletionHandlerClosureType = anim.value(forKey: kAnimationCompletionBlock) as! () -> ()

        // SlideOut Animation
        if identifier == kAnimationDirectionFromBottomOutLabel {
            self.frame = CGRect(x:self.frame.origin.x,
                                y:self.frame.origin.y - self.frame.size.height,
                                width:self.frame.size.width,
                                height:self.frame.size.height);
            self.alpha = 0.0
        }

        if identifier == kAnimationDirectionFromTopOutLabel {
            self.frame = CGRect(x:self.frame.origin.x,
                                y:self.frame.origin.y + self.frame.size.height,
                                width:self.frame.size.width,
                                height:self.frame.size.height);
            self.alpha = 0.0
        }

        // Pop Animations
        if  identifier == kAnimationPopOut {
            if flag {
                self.alpha = 0.0
            }
        }
        
        // Completion Block
        completion()
    }

}
