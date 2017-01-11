//
//  VideoSource.swift
//  OpenCVSwift
//
//  Created by user on 1/10/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

import UIKit
import AVFoundation
import CoreVideo

struct VideoFrame {
    var width:Int
    var height:Int
    var stride:Int
    var data:UnsafeMutableRawPointer?
}

protocol VideoSourceDelegate:class {
    func frameReady(frame:VideoFrame)

    /* alternate method to just pass an image back to delegate */
//    func imageReady(image:CIImage)
}

class VideoSource:NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    let captureSession:AVCaptureSession
    var delegate:VideoSourceDelegate?

    override init() {
        captureSession = AVCaptureSession()

        if captureSession.canSetSessionPreset(AVCaptureSessionPreset1280x720){
            captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        }
    }

    deinit {
        captureSession.stopRunning()
    }

    func startWithDevicePosition(devicePosition:AVCaptureDevicePosition) -> Bool {

        guard let videoDevice = cameraWithPosition(postion: devicePosition) else {
            print("Could not initialize camera at postion")
            return false
        }

        do { //assign input device to session
            let cameraInput =  try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            } else {
                 print("could not add input for device")
                return false
            }

            addVideoDataOutput()

            let sessionQueue = DispatchQueue(label: "com.camera.capture_session")
            sessionQueue.async { [weak self] _ in
                self?.captureSession.startRunning()
            }
            return true

        } catch {
            print("could not open input port for device")
        }

        return false
    }

    /* find possible input devices using the position (e.g. Back or Front camera)*/
    func cameraWithPosition(postion:AVCaptureDevicePosition) -> AVCaptureDevice? {
        let session = AVCaptureDeviceDiscoverySession(deviceTypes:[.builtInTelephotoCamera, .builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: postion)
        return session?.devices.first
    }

    /* process camera video output on background queue */
    func addVideoDataOutput() {
        let captureOutput = AVCaptureVideoDataOutput()
        captureOutput.alwaysDiscardsLateVideoFrames = true
        let queue = DispatchQueue(label: "com.camera.video_capture.output")
        captureOutput.setSampleBufferDelegate(self, queue: queue)
        captureOutput.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey):NSNumber.init(value:kCVPixelFormatType_32BGRA)]

        if captureSession.canAddOutput(captureOutput) {
            captureSession.addOutput(captureOutput)
        }
    }


    /* capture live frames and pass on to delegate, samples sent from the camera are rotated 90 degrees, because that’s how the camera sensor is oriented */
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        //Lock pixel buffer, option 0 = kCVPixelBufferLock_ReadOnly
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let stride = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let frame = VideoFrame(width: width, height: height, stride: stride, data: baseAddress)

        //Dispatch VideoFrame to delegate
        delegate?.frameReady(frame: frame)

        /* alernate option is just to create a CIImage and return it back to the delegate */
//        let image = CIImage(cvPixelBuffer: pixelBuffer)
//        delegate?.imageReady(image: image)

        //unlock pixel buffer
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    }

    func checkAuthorizationStatus() {

        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authorizationStatus {
        case .notDetermined:
            // permission dialog not yet presented, request authorization
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo,
                                                      completionHandler: { (granted:Bool) -> Void in
                                                        if granted {
                                                            // go ahead
                                                        }
                                                        else {
                                                            // user denied, nothing much to do
                                                        }
            })
        case .authorized: break
        // go ahead
        case .denied, .restricted: break
            // the user explicitly denied camera usage or is not allowed to access the camera devices
        }
    }

}




















