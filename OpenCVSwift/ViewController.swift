//
//  ViewController.swift
//  OpenCVSwift
//
//  Created by user on 1/10/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

import UIKit
import AVFoundation
import CoreGraphics


class ViewController: UIViewController, VideoSourceDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!
    let openCVWrapper = OpenCVWrapper()
    let videoSource = VideoSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        videoSource.delegate = self
        let _ = videoSource.startWithDevicePosition(devicePosition: AVCaptureDevicePosition.back)
    }

    

    func frameReady(frame:VideoFrame) {

        DispatchQueue.main.async { [weak self] _ in

            let colorSpace = CGColorSpaceCreateDeviceRGB()

            guard let context = CGContext.init(data: frame.data, width: frame.width, height: frame.height, bitsPerComponent:8, bytesPerRow: frame.stride, space: colorSpace, bitmapInfo: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)) else { return }

            if let newImage = context.makeImage() {
                let image = UIImage.init(cgImage: newImage)
                self?.backgroundImageView.image = image
            }
        }
    }

}

