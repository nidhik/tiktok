//
//  ViewController.swift
//  TikTok
//
//  Created by Nidhi Kulkarni on 3/9/20.
//  Copyright © 2020 Nidhi Kulkarni. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController{
    
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet var captureView: UIView!
    var captureSession: AVCaptureSession!

    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var videoDeviceInput: AVCaptureDeviceInput!
    
    // NEW
    private var _videoOutput: AVCaptureVideoDataOutput!
    private var _assetWriter: AVAssetWriter!
    private var _assetWriterInput: AVAssetWriterInput!
    private var _adpater: AVAssetWriterInputPixelBufferAdaptor?
    private var _filename = ""
    private var _time: Double = 0
    
    @IBOutlet weak var deleteSegmentButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
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
            let output = AVCaptureVideoDataOutput()
            if captureSession.canAddInput(cameraInput) && captureSession.canAddInput(audioInput) && captureSession.canAddOutput(output) {
                captureSession.addInput(cameraInput)
                captureSession.addInput(audioInput)
                self.videoDeviceInput = cameraInput
                
                captureSession.addOutput(output)
                self._videoOutput = output
                self._videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.nidhi.tiktok.record"))
                
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
        previewView.layer.insertSublayer(videoPreviewLayer, at: 0)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession?.startRunning()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
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
    private enum _CaptureState {
        case idle, start, capturing, end
    }
    private var _captureState = _CaptureState.idle
    
    @IBAction func tappedRecord(_ sender: Any) {
        switch _captureState {
        case .idle:
            _captureState = .start
        case .capturing:
            _captureState = .idle
        default:
            break
        }
    }
    
    
    @IBAction func tappedCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedFlipCamera(_ sender: Any) {
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
//                    if let connection = self._videoOutput?.connection(with: .video) {
//                        if connection.isVideoStabilizationSupported {
//                            connection.preferredVideoStabilizationMode = .auto
//                        }
//                    }
                    
                    self.captureSession.commitConfiguration()
                } catch {
                    print("Error occurred while creating video device input: \(error)")
                }
            }
        }
    }
    
    @IBAction func tappedDeleteSegment(_ sender: Any) {
    }
    
    @IBAction func tappedDone(_ sender: Any) {
        _captureState = .end
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

extension RecordViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        switch _captureState {
        case .start:
            // Set up recorder
            DispatchQueue.main.async {
                self.animateRecordButton()
            }
            _filename = UUID().uuidString
            let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename).mov")
            let writer = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
            let settings = _videoOutput!.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings) // [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
            input.mediaTimeScale = CMTimeScale(bitPattern: 600)
            input.expectsMediaDataInRealTime = true
            input.transform = CGAffineTransform(rotationAngle: .pi/2)
            let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
            if writer.canAdd(input) {
                writer.add(input)
            }
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)
            _assetWriter = writer
            _assetWriterInput = input
            _adpater = adapter
            _captureState = .capturing
            _time = timestamp
        case .capturing:
            if _assetWriterInput?.isReadyForMoreMediaData == true {
                let time = CMTime(seconds: timestamp - _time, preferredTimescale: CMTimeScale(600))
                _adpater?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!, withPresentationTime: time)
            }
            break
        case .end:
            guard _assetWriterInput?.isReadyForMoreMediaData == true, _assetWriter!.status != .failed else { break }
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename).mov")
            _assetWriterInput?.markAsFinished()
            _assetWriter?.finishWriting { [weak self] in
                self?._captureState = .idle
                self?._assetWriter = nil
                self?._assetWriterInput = nil
                let client = MuxApiClient()
                client.uploadVideo(fileURL: url)
                DispatchQueue.main.async {
                    self?.stopAnimatingRecordButton()
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        case .idle:
            DispatchQueue.main.async {
                self.stopAnimatingRecordButton()
            }
        }
    }
}
