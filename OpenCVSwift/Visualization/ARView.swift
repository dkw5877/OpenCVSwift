//
//  ARView.swift
//  OpenCVSwift
//
//  Created by user on 2/7/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

import UIKit

enum ColorRing:Int {
    case Ring1
    case Ring2
    case Ring3
    case Ring4
    case Ring5
    case Miss

    var color:UIColor {
        switch self {
        case .Ring1:
            return .blue
        case .Ring2:
            return .green
        case .Ring3:
            return .yellow
        case .Ring4:
            return .orange
        case .Ring5:
            return .red
        case .Miss:
            return .clear
        }
    }
}

class ARView: UIView {


    let kRadius5:CGFloat = 18.0
    let kRadius4:CGFloat = 30.0
    let kRadius3:CGFloat = 45.0
    let kRadius2:CGFloat = 58.0
    let kRadius1:CGFloat = 73.0

    let kAlphaShow:CGFloat = 0.5
    let kAlphaHide:CGFloat = 0.0

     // Change this line to change which ring is highlighted
    var ringNumber:ColorRing
    var hits = Set<UIView>()
    private var calibration:CameraCalibration
    private var size:CGSize

    init() {
        ringNumber = ColorRing(rawValue: 0)!
        calibration = CameraCalibration(xDistortion: 0, yDistortion: 0, xCorrection: 0, yCorrection: 0)
        size = .zero
        super.init(frame: .zero)
    }

    init(size:CGSize, calibration:CameraCalibration) {

        // Must do math first
        self.calibration = calibration
        self.size = CGSize(width:size.width * calibration.xDistortion,
                           height:size.height * calibration.yDistortion)
        ringNumber = ColorRing(rawValue: 0)!

        // Now construct object
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        //set properties
        center = CGPoint(x:self.frame.size.width / 2.0, y:self.frame.size.height / 2.0)
        backgroundColor = .darkGray

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func drawTargetCircle(center:CGPoint, color:UIColor, radius:CGFloat , calibration: CameraCalibration ) {

        if let context = UIGraphicsGetCurrentContext() {
            let xF = calibration.xDistortion
            let yF = calibration.yDistortion
            let factor = CGFloat(568.0/480.0)
            if let comps = color.cgColor.components {
                context.setFillColor(red: comps[0], green: comps[1], blue: comps[2], alpha: comps[3])
            }

            let circle1 = CGRect(x:center.x - (radius*factor) / (yF*2.0), y:center.y - (radius*factor) / (xF*2.0),
                                 width:(radius*factor) / (yF),
                                 height:(radius*factor) / (xF))
            context.fillEllipse(in: circle1)
        }
    }

    func distance(a:CGPoint, b:CGPoint, calibration:CameraCalibration ) -> CGFloat {
        let dx = (b.x - a.x) / calibration.xDistortion;
        let dy = (b.y - a.y) / calibration.yDistortion;
        return sqrt(dx * dx + dy * dy);
    }

    override func draw(_ rect: CGRect) {
        switch ( ringNumber ) {
        case .Ring1:
            drawTargetCircle(center: center, color: ringNumber.color, radius: kRadius1, calibration: calibration)
        case .Ring2:
            drawTargetCircle(center: center, color: ringNumber.color, radius: kRadius2, calibration: calibration)
        case .Ring3:
            drawTargetCircle(center: center, color: ringNumber.color, radius: kRadius3, calibration: calibration)
        case .Ring4:
            drawTargetCircle(center: center, color: ringNumber.color, radius: kRadius4, calibration: calibration)
        case .Ring5:
            drawTargetCircle(center: center, color: ringNumber.color, radius: kRadius5, calibration: calibration)
        case .Miss:
            drawTargetCircle(center: center, color: ringNumber.color, radius: 0, calibration: calibration)
        }
    }

    func selectBestRing(point:CGPoint) -> Int {
        var bestRing = 0
        let dist:CGFloat = distance(a: point, b: center, calibration: calibration)
        if ( dist < kRadius5 )      { bestRing = 5 }
        else if ( dist < kRadius4 ) { bestRing = 4 }
        else if ( dist < kRadius3 ) { bestRing = 3 }
        else if ( dist < kRadius2 ) { bestRing = 2 }
        else if ( dist < kRadius1 ) { bestRing = 1 }

        if  bestRing > 0 {
            // (1) Create the UIView for the "bullet hole"
            let bulletSize:CGFloat = 6.0
            let bulletHole = UIView(frame: CGRect(x: point.x - bulletSize/2.0, y: point.y - bulletSize/2.0, width: bulletSize, height: bulletSize))
            bulletHole.backgroundColor = .green
            addSubview(bulletHole)

            // (2) Keep track of state, so it can be cleared
            hits.insert(bulletHole)
        }

        return bestRing
    }

    func show() {
        alpha = kAlphaShow
    }

    func hide() {
        alpha = kAlphaHide
        for view in hits {
            view.removeFromSuperview()
        }
        hits.removeAll()
    }

}
