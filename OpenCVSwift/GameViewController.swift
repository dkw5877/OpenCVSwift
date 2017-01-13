//
//  GameViewController.swift
//  OpenCVSwift
//
//  Created by user on 1/11/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

import UIKit
import AVFoundation
import CoreGraphics
import AudioToolbox

enum HitPoints:Int {
    case Points1 = 50
    case Points2 = 100
    case Points3 = 250
    case Points4 = 500
    case Points5 = 1000
}

class GameViewController: UIViewController, VideoSourceDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var crosshairs: UIImageView!

    @IBOutlet weak var tutorialPanel: UIView!
    @IBOutlet weak var tutorialInnerPanel: UIImageView!
    @IBOutlet weak var tutorialLabel: UILabel!
    @IBOutlet weak var tutorialDescLabel: UILabel!

    @IBOutlet weak var scorePanel: UIView!
    @IBOutlet weak var scoreInnerPanel: UIImageView!
    @IBOutlet weak var scoreValueLabel: UILabel!
    @IBOutlet weak var scoreHeaderLabel: UILabel!

    @IBOutlet weak var triggerPanel: UIView!
    @IBOutlet weak var triggerLabel: UILabel!

    @IBOutlet weak var sampleButtonPanel: UIView!
    @IBOutlet weak var sampleButtonLabel: UILabel!

    @IBOutlet weak var samplePanel: UIView!
    @IBOutlet weak var samplePanelInner: UIView!
    @IBOutlet weak var sampleView: UIImageView!
    @IBOutlet weak var sampleLabel1: UILabel!
    @IBOutlet weak var sampleLabel2: UILabel!

    var soundExplosion:SystemSoundID = 0
    var soundShoot:SystemSoundID = 1
    var soundTracking:SystemSoundID = 2

//    let m_detector:PatternDetector
    var trackingTimer:Timer?
    var sampleTimer:Timer?

//    var calibration:CameraCalibration
    var targetViewWidth = 0.0
    var targetViewHeight = 0.0

    var fontLarge = UIFont(name: "GROBOLD", size: 18)
    var fontSmall = UIFont(name: "GROBOLD", size: 14)
    var transitioningTracker:Bool
    var transitioningSample:Bool
    var score = 0 { didSet {
        scoreValueLabel.text = NumberFormatter.localizedString(from: NSNumber(value:oldValue), number: .decimal)
        } }

    let openCVWrapper = OpenCVWrapper()
    let videoSource = VideoSource()

    required init?(coder aDecoder: NSCoder) {
        transitioningTracker = false
        transitioningSample = false

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        videoSource.delegate = self
        let _ = videoSource.startWithDevicePosition(devicePosition: AVCaptureDevicePosition.back)

        configureViews()
        configureTutorialViews()
        configureScoreViews()
        configureSamplePanel()
        configureSampleViews()
        loadSounds()
    }

    func configureViews() {
        // Turn on the game controls
        crosshairs.isHidden = false
        tutorialPanel.isHidden = false
        scorePanel.isHidden = false
        triggerPanel.isHidden = false
        samplePanel.isHidden = true
    }

    func configureTutorialViews() {
        tutorialInnerPanel.layer.cornerRadius = CGFloat(kCornerRadius)
        tutorialInnerPanel.clipsToBounds = true
        tutorialInnerPanel.backgroundColor = UIColor.clear
        tutorialLabel.font = fontLarge
        tutorialDescLabel.font = fontSmall
    }

    func configureScoreViews() {
        scoreInnerPanel.layer.cornerRadius = CGFloat(kCornerRadius)
        scoreInnerPanel.clipsToBounds = true
        scoreInnerPanel.backgroundColor = UIColor.clear
        scoreValueLabel.font = fontLarge
        scoreHeaderLabel.font = fontLarge
        triggerLabel.font = fontLarge
    }

    func configureSamplePanel() {
        sampleButtonLabel.font = fontLarge
        samplePanelInner.layer.cornerRadius = CGFloat(kCornerRadius)
        samplePanelInner.clipsToBounds =  true
        samplePanelInner.backgroundColor = UIColor.clear
        sampleLabel1.font = UIFont.systemFont(ofSize: 11.0)
        sampleLabel2.font = UIFont.systemFont(ofSize:11.0)
    }

    func configureSampleViews() {
        sampleView.layer.borderColor = UIColor.orange.cgColor
        sampleView.layer.borderWidth = 1.0
        sampleView.layer.cornerRadius = 4.0
        sampleView.clipsToBounds = true
    }

    @IBAction func pressTrigger(_ sender: Any) {

        print("Fire!")
        let ring = selectRandomRing()
        switch ring {
        case RingValue.BullsEye: // Bullseye
            hitTargetWithPoints(points: HitPoints.Points5.rawValue)
        case RingValue.Fourth:
            hitTargetWithPoints(points: HitPoints.Points4.rawValue)
        case RingValue.Third:
            hitTargetWithPoints(points: HitPoints.Points3.rawValue)
        case RingValue.Second:
            hitTargetWithPoints(points: HitPoints.Points2.rawValue)
        case RingValue.First:
            hitTargetWithPoints(points: HitPoints.Points1.rawValue)
        case RingValue.Miss:
            missTarget()
        }
    }

    @IBAction func pressSample(_ sender: Any) {

        if  !isSamplePanelVisible() && !transitioningSample  {

            transitioningSample = true

            // Clear the UI
            self.updateSample(timer:nil)

            // Clear the timer
            if (sampleTimer != nil)   {
                sampleTimer!.invalidate()
                sampleTimer = nil
            }

            // Start the timer
            sampleTimer = Timer.scheduledTimer(timeInterval: 1.0/20.0, target: self, selector: #selector(updateSample), userInfo: nil, repeats: true)

            samplePanel.popIn { [weak self] _ in
                self?.transitioningSample = false
            }

        }
    }

    func hitTargetWithPoints(points:Int) {
        // (1) Play the hit sound
        AudioServicesPlaySystemSound(soundExplosion)

        // (2) Animate the floating scores
        showFloatingScore(points: points)

        // (3) Update the score
        score += points

        // (4) Run the explosion sprite
        showExplosion()
    }

    func missTarget() {
        AudioServicesPlaySystemSound(soundShoot)
    }

    func updateTracking(timer:Timer) {
        // TODO: Add code here
    }

    func updateSample(timer:Timer?) {
        // TODO: Add code here
    }

    func togglePanels() {
        // TODO: Add code here
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

    func isTutorialPanelVisible() -> Bool {
        return tutorialPanel.alpha == 1.0
    }

    func isSamplePanelVisible() -> Bool {
        return samplePanel.alpha == 1.0
    }

    func loadSounds() {

        let soundURL1 = Bundle.main.url(forResource: "powerup", withExtension: "caf")
        let soundURL2 = Bundle.main.url(forResource: "laser", withExtension: "caf")
        let soundURL3 = Bundle.main.url(forResource: "explosion", withExtension: "caf") 

        //In Swift 3, status retuns as unsupported file type, no idea why
        let status = AudioServicesCreateSystemSoundID(soundURL1 as! CFURL, &soundTracking)
        AudioServicesCreateSystemSoundID(soundURL2 as! CFURL, &soundShoot)
        AudioServicesCreateSystemSoundID(soundURL3 as! CFURL, &soundExplosion)

    }

}
