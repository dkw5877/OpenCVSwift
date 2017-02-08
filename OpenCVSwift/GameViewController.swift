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


struct CameraCalibration {
    var xDistortion:CGFloat = 0.0
    var yDistortion:CGFloat = 0.0
    var xCorrection:CGFloat = 0.0
    var yCorrection:CGFloat = 0.0
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

    // Transition Closures
    var transitioningTrackerComplete:CompletionHandlerClosureType = {}
    var transitioningTrackerCompleteResetScore:CompletionHandlerClosureType = {}

    var detector:PatternDetectorWrapper?
    var trackingTimer:Timer?
    var sampleTimer:Timer?

    var calibration:CameraCalibration
    var targetViewWidth:CGFloat = 0.0
    var targetViewHeight:CGFloat = 0.0

    var fontLarge = UIFont(name: "GROBOLD", size: 18)
    var fontSmall = UIFont(name: "GROBOLD", size: 14)
    var transitioningTracker:Bool
    var transitioningSample:Bool
    var score = 0 { didSet {
        scoreValueLabel.text = NumberFormatter.localizedString(from: NSNumber(value:oldValue), number: .decimal)
        } }

    let openCVWrapper = OpenCVWrapper()
    let videoSource = VideoSource()
    var arView = ARView()

    required init?(coder aDecoder: NSCoder) {
        transitioningTracker = false
        transitioningSample = false
        calibration = CameraCalibration(xDistortion: 0.8, yDistortion: 0.675, xCorrection: (16.0/11.0), yCorrection: 1.295238095238095)
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

        // Configure Pattern Detector
        let trackerImage = UIImage(named: "target.jpg")
        detector = PatternDetectorWrapper(pattern: trackerImage)

        if let detector = detector {
            let showSample = detector.useTrackingHelper()
            samplePanel.isHidden = !showSample
            samplePanel.alpha = 0
        }

        //we have to add the timer to the runloop as dispatching on main thread does not seem to work
        self.trackingTimer = Timer(timeInterval: 1.0/20.0, target: self, selector: #selector(self.updateTracking(timer:)), userInfo: nil, repeats: true)
        RunLoop.current.add(self.trackingTimer!, forMode: .commonModes)

        transitioningTrackerComplete = { [weak self] _ in self?.transitioningTracker = false }
        transitioningTrackerCompleteResetScore = { [weak self] _ in
            self?.transitioningTracker = false
            self?.score = 0
        }

        createARView(trackerImage: trackerImage)
    }

    func createARView(trackerImage:UIImage?) {
        guard let trackerImage = trackerImage else { return }
        // Create Visualization Layer
        arView = ARView(size: CGSize(width:trackerImage.size.width, height:trackerImage.size.height), calibration: calibration)
        view.addSubview(arView)
        arView.hide()

        // Save Visualization Layer Dimensions
        targetViewWidth = arView.frame.size.width
        targetViewHeight = arView.frame.size.height
    }

    override func viewDidAppear(_ animated: Bool) {
        transitioningTracker = true
        tutorialPanel.slideIn(fromDirection:.AnimationDirectionFromTop, completion: transitioningTrackerComplete)
        super.viewDidAppear(animated)
    }

    func configureViews() {
        // Turn on the game controls
        crosshairs.isHidden = false
        tutorialPanel.alpha = 0
        scorePanel.alpha = 0
        triggerPanel.alpha = 0
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

        let targetHit = arView.convert(crosshairs.center, from:self.view)
        let ring = arView.selectBestRing(point: targetHit)

        switch ring {
        case 5: // Bullseye
            hitTargetWithPoints(points: HitPoints.Points5.rawValue)
        case 4:
            hitTargetWithPoints(points: HitPoints.Points4.rawValue)
        case 3:
            hitTargetWithPoints(points: HitPoints.Points3.rawValue)
        case 2:
            hitTargetWithPoints(points: HitPoints.Points2.rawValue)
        case 1: // outermost ring
            hitTargetWithPoints(points: HitPoints.Points1.rawValue)
        default:
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
            sampleTimer = Timer.scheduledTimer(timeInterval: 1.0/20.0, target: self, selector: #selector(self.updateSample(timer:)), userInfo: nil, repeats: true)
            RunLoop.current.add(self.sampleTimer!, forMode: .commonModes)

            samplePanel.popIn { [weak self] _ in
                self?.transitioningSample = false
            }

        }
    }

    @IBAction func closeSample(_ sender: Any) {

        if isSamplePanelVisible(), !transitioningSample {
            sampleTimer?.invalidate()
        }

        samplePanel.popOut {
            transitioningSample = false
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

    func updateTracking(timer:Timer?) {

        if ( detector?.isTracking() )! {
            if isTutorialPanelVisible() {
                togglePanels()
            }

            // Begin tracking the bullseye target
            if let matchPoint = detector?.matchPoint() {
                arView.center = CGPoint(x:calibration.xCorrection * matchPoint.x + targetViewWidth / 2.0,
                                        y:calibration.yCorrection * matchPoint.y + targetViewHeight / 2.0)
                arView.show()
            }
        }
        else {
            if !isTutorialPanelVisible() {
                togglePanels()
            }
            arView.hide()
        }
    }

    func updateSample(timer:Timer?) {
        guard timer != nil else { return }
        sampleView.image = detector?.sampleImage()
        sampleLabel1.text = String(format: "%0.3f", (detector?.matchThresholdValue())!)
        sampleLabel2.text = String(format: "%0.3f", (detector?.matchValue())!)
    }

    func togglePanels() {
        if !transitioningTracker {
            transitioningTracker = true
            if isTutorialPanelVisible() {
                tutorialPanel .slideOut(fromDirection: .AnimationDirectionFromTop, completion: transitioningTrackerComplete)
                scorePanel.slideIn(fromDirection: .AnimationDirectionFromTop, completion: transitioningTrackerComplete)
                triggerPanel.slideIn(fromDirection: .AnimationDirectionFromBottom, completion: transitioningTrackerComplete)
                AudioServicesPlaySystemSound(soundTracking)
            } else {
                tutorialPanel .slideIn(fromDirection: .AnimationDirectionFromTop, completion: transitioningTrackerComplete)
                scorePanel.slideOut(fromDirection: .AnimationDirectionFromTop, completion: transitioningTrackerCompleteResetScore)
                triggerPanel.slideOut(fromDirection: .AnimationDirectionFromBottom, completion: transitioningTrackerComplete)
            }
        }
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

        detector?.scanFrame(frame as VideoFrame)
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
        AudioServicesCreateSystemSoundID(soundURL1 as! CFURL, &soundTracking)
        AudioServicesCreateSystemSoundID(soundURL2 as! CFURL, &soundShoot)
        AudioServicesCreateSystemSoundID(soundURL3 as! CFURL, &soundExplosion)

    }

}
