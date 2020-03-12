//
//  ViewController.swift
//  TikTok
//
//  Created by Nidhi Kulkarni on 3/9/20.
//  Copyright © 2020 Nidhi Kulkarni. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet var captureView: UIView!
    var captureSession: AVCaptureSession!
    var captureOutput: AVCaptureMovieFileOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var videoDeviceInput: AVCaptureDeviceInput!
    
    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
    mediaType: .video, position: .unspecified)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup camera here
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        guard let rearCamera = AVCaptureDevice.default(for: AVMediaType.video),
            let audioInput = AVCaptureDevice.default(for: AVMediaType.audio)
            else {
                print("Unable to access capture devices!")
                return
        }
        do {
            let cameraInput = try AVCaptureDeviceInput(device: rearCamera)
            let audioInput = try AVCaptureDeviceInput(device: audioInput)
            captureOutput = AVCaptureMovieFileOutput()
            if captureSession.canAddInput(cameraInput) && captureSession.canAddInput(audioInput) && captureSession.canAddOutput(captureOutput) {
                captureSession.addInput(cameraInput)
                captureSession.addInput(audioInput)
                captureSession.addOutput(captureOutput)
                self.videoDeviceInput = cameraInput
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize inputs:  \(error.localizedDescription)")
        }
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession?.startRunning()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }

    // MARK: AVCaptureFileOutputRecordingDelegate
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
            let client = MuxApiClient()
            client.uploadVideo(fileURL: outputFileURL)
        } else {
            print("Error saving movie to disk: \(String(describing: error))")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func animateRecordButton() {
        let cornerRadiusAnimation = CASpringAnimation(keyPath: "cornerRadius")
        cornerRadiusAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        cornerRadiusAnimation.fromValue = 40.0
        cornerRadiusAnimation.toValue = 0.0
        cornerRadiusAnimation.duration = 1.0;
        self.recordButton.layer.cornerRadius = 0.0
   
        
        let pulse1 = CASpringAnimation(keyPath: "transform.scale")
        pulse1.duration = 0.6
        pulse1.fromValue = 1.0
        pulse1.toValue = 1.12
        pulse1.autoreverses = true
        pulse1.repeatCount = 1
        pulse1.initialVelocity = 0.5
        pulse1.damping = 0.8

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 2.0
        animationGroup.repeatCount = HUGE
        animationGroup.animations = [pulse1]

        self.recordButton.layer.add(animationGroup, forKey: "pulse")
        self.recordButton.layer.add(cornerRadiusAnimation, forKey: "cornerRadius")
    }
    
    func stopAnimatingRecordButton() {
        self.recordButton.layer.removeAllAnimations()
        self.recordButton.layer.cornerRadius = 40.0
    }

    @IBAction func tappedRecord(_ sender: Any) {
        // TODO
        if self.captureOutput.isRecording {
            self.captureOutput.stopRecording()
            self.stopAnimatingRecordButton()
        } else {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileURL = paths[0].appendingPathComponent("tiktok_output.mov")
            try? FileManager.default.removeItem(at: fileURL)
            self.captureOutput.startRecording(to: fileURL, recordingDelegate: self)
            self.animateRecordButton()
        }
    }
    
    @IBAction func tappedCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedFlipCamera(_ sender: Any) {
        // TODO: flip the camera
        print("Flip camera tapped")
        DispatchQueue.global(qos: .userInitiated).async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back
                preferredDeviceType = .builtInDualCamera
                
            case .back:
                preferredPosition = .front
                preferredDeviceType = .builtInTrueDepthCamera
                
            @unknown default:
                print("Unknown capture position. Defaulting to back, dual-camera.")
                preferredPosition = .back
                preferredDeviceType = .builtInDualCamera
            }
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice? = nil
            
            // First, seek a device with both the preferred position and device type. Otherwise, seek a device with only the preferred position.
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.captureSession.beginConfiguration()
                    
                    // Remove the existing device input first, because AVCaptureSession doesn't support
                    // simultaneous use of the rear and front cameras.
                    self.captureSession.removeInput(self.videoDeviceInput)
                    
                    if self.captureSession.canAddInput(videoDeviceInput) {
                        self.captureSession.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.captureSession.addInput(self.videoDeviceInput)
                    }
                    if let connection = self.captureOutput?.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    
                    self.captureSession.commitConfiguration()
                } catch {
                    print("Error occurred while creating video device input: \(error)")
                }
            }
        }
    }
    
    func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
        [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
        mediaType: .video, position: .unspecified)
        let devices = discoverySession.devices
        guard !devices.isEmpty else { fatalError("Missing capture devices.")}

        return devices.first(where: { device in device.position == position })!
    }
}
