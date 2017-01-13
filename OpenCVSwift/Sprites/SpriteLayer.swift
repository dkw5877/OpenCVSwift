//
//  SpriteLayer.swift
//  OpenCVSwift
//
//  Created by user on 1/12/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

import UIKit

class SpriteLayer: CALayer, CAAnimationDelegate {

    var spriteIndex:Int

    /* returns the value of the spriteIndex attribute associated with object’s presentation layer,
     Calling this method will return the correct, in-progress value of spriteIndex while the animation
     is running */
    func currentSpriteIndex() -> Int {
        if let presentationLayer = presentation()  {
            return presentationLayer.spriteIndex
        }
        return 0
    }

    /* display image “subframe”, each subframe will be 128 x 128 pixels 
       core animation uses a unit coordinate system with values between 0.0 and 1.0 */
    convenience init(withImage image:CGImage, spriteSize size:CGSize) {
        self.init(withImage:image)
        let spriteSizeNormalized = CGSize(width:size.width/CGFloat(image.width), height:size.height/CGFloat(image.height))
        bounds = CGRect(x:0, y:0, width:size.width, height:size.height)
        contentsRect = CGRect(x:0, y:0, width:spriteSizeNormalized.width, height:spriteSizeNormalized.height)
        print("bounds \(bounds)")
        print("contentsRect \(contentsRect)")

    }

    init(withImage image:CGImage) {
        self.spriteIndex = 1
        super.init()
        self.contents = image
    }

    /* required init for presention layer, we must initialize custom layer properties */
    override init(layer: Any) {
        spriteIndex = (layer as! SpriteLayer).spriteIndex
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /* Core Animation will animate spriteIndex when you instruct the layer to redraw its contents whenever the value associated with the spriteIndex key changes. */
    override class func needsDisplay(forKey key: String) -> Bool {
        return key == "spriteIndex"
    }

    /* deactivate implicit animation  for the “key” contentsRect. */
    override class func defaultAction(forKey event: String) -> CAAction? {
        if event == "contentsRect" {
            return nil
        } else {
            return super.defaultAction(forKey: event)
        }
    }

    /* manually change the value of contentsRect and slide it along one frame at a time as sprieIndex changes */
    override func display() {

        let currentSpriteIndex = self.currentSpriteIndex()
        if ( currentSpriteIndex == 0 ) { return }

        let spriteSize = contentsRect.size
        let xOrigin = CGFloat( (currentSpriteIndex - 1) % Int(1.0/spriteSize.width)) * spriteSize.width
        let yOrigin = CGFloat( (currentSpriteIndex - 1) / Int(1.0/spriteSize.width)) * spriteSize.height

        print("currentSpriteIndex \(currentSpriteIndex)")
        print("spriteSize \(spriteSize)")
        print("xOrigin \(xOrigin)")
        print("yOrigin \(yOrigin)")

        self.contentsRect = CGRect(x:xOrigin,
                                   y:yOrigin,
                                   width:spriteSize.width,
                                   height:spriteSize.height)
    }

    /* CAAnimation delegate callback method */
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
         removeFromSuperlayer()
    }

}
