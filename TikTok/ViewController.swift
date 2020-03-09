//
//  ViewController.swift
//  TikTok
//
//  Created by Nidhi Kulkarni on 3/9/20.
//  Copyright © 2020 Nidhi Kulkarni. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet var captureView: UIView!
    var captureSession: AVCaptureSession!
    var captureOutput: AVCaptureMovieFileOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
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
        } else {
            print("Error saving movie to disk: \(String(describing: error))")
        }
    }

    @IBAction func tappedRecord(_ sender: Any) {
        // TODO
        if self.captureOutput.isRecording {
            self.captureOutput.stopRecording()
        } else {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileURL = paths[0].appendingPathComponent("tiktok_output.mov")
            try? FileManager.default.removeItem(at: fileURL)
            self.captureOutput.startRecording(to: fileURL, recordingDelegate: self)
        }
    }
    
    @IBAction func tappedFlipCamera(_ sender: Any) {
        // TODO: flip the camera
        print("Flip camera tapped")
    }
}
