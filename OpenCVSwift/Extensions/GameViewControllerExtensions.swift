//
//  UIViewControllerExtensions.swift
//  OpenCVSwift
//
//  Created by user on 1/11/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

import Foundation
import UIKit

let kCornerRadius = 10.0
let kDurationFade = 1.25

enum RingValue:Int {
    case First = 1
    case Second = 2
    case Third = 3
    case Fourth = 4
    case BullsEye = 5
    case Miss = 0
}

extension GameViewController {

    func selectRandomRing() -> RingValue {

        // Simulate a 50% chance of hitting the target
        let randomNumber1 = arc4random() % 100
        if randomNumber1 < 50  {
            // Stagger the 5 simulations linearly
            let randomNumber2 = arc4random() % 100

            switch randomNumber2 {
            case 0...20:
                return RingValue.First
            case 21...40:
                return RingValue.Second
            case 41...60:
                return RingValue.Third
            case 61...80:
                return RingValue.Fourth
            case 81...100: /* bullseye */
                return RingValue.BullsEye
            default:
                return RingValue.Miss
            }
        }
        return RingValue.Miss
    }

    func showFloatingScore(points:Int) {

        // Configure the label
        let r1 = UIScreen.main.bounds
        let w1 = r1.size.width
        let h1 = r1.size.height
        let xMargin = CGFloat(5.0)
        let yMargin = CGFloat(-40.0)

        /* Flip-flop because in landscape */
        let frame = CGRect(x: h1/2.0 + xMargin, y: w1/2.0 + yMargin, width: 60, height: 30)
        let label = UILabel(frame: frame)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.orange
        label.shadowColor = UIColor.black
        label.shadowOffset = CGSize(width:0, height:-1)
        label.font = UIFont(name: "GROBOLD", size: 18.0)
        label.text = NumberFormatter.localizedString(from: NSNumber(value:points), number: NumberFormatter.Style.decimal)
        label.textAlignment = .center
        view.addSubview(label)

        // Animate the fade and motion upwards
        let startFrame = label.frame

        UIView.animate(withDuration: kDurationFade, animations: { [weak label] _ in
            let offset = CGFloat(50.0)
            label?.alpha = 0.0
            label?.frame = CGRect(x: startFrame.origin.x,
                                 y: startFrame.origin.y - offset,
                                 width: startFrame.size.width,
                                 height: startFrame.size.height)
        }) { (Bool) in
            label.removeFromSuperview()
        }

    }

    func showExplosion() {

        // (1) Create the explosion sprite
        let explosionImageOrig = UIImage(named:"explosion")
        let explosionImageCopy = (explosionImageOrig?.cgImage!)!.copy()
        let explosionSize = CGSize(width:128, height:128)
        let sprite = SpriteLayer(withImage: explosionImageCopy!, spriteSize: explosionSize)

        // (2) Position the explosion sprite
        let xOffset:CGFloat = -7.0
        let yOffset:CGFloat = -3.0
        sprite.position = CGPoint(x:crosshairs.center.x + xOffset, y:crosshairs.center.y + yOffset)

        // (3) Add to the view
        view.layer.addSublayer(sprite)

        // (4) Configure and run the animation
        let animation = CABasicAnimation(keyPath:"spriteIndex")
        animation.fromValue = 1
        animation.toValue = 12
        animation.duration = 0.45
        animation.repeatCount = 1
        animation.delegate = sprite
        sprite.add(animation, forKey: nil)

    }

}
