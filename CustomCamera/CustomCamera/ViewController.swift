//
//  ViewController.swift
//  CustomCamera
//
//  Created by Guilherme Gatto on 04/08/17.
//  Copyright © 2017 mackmobile. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    let captureSession = AVCaptureSession()
    let capturePhotoOutput = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    var cameraflag = true
    
    var imageView: UIImageView?
    var img: UIImage = #imageLiteral(resourceName: "overlay")
    
    @IBOutlet weak var previewView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDevice()

    }

    
    @IBAction func capture(_ sender: Any) {
        
        if let _ = capturePhotoOutput.connection(withMediaType: AVMediaTypeVideo) {
            let settings = AVCapturePhotoSettings()
            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                 kCVPixelBufferWidthKey as String: 160,
                                 kCVPixelBufferHeightKey as String: 160]
            settings.previewPhotoFormat = previewFormat
            capturePhotoOutput.capturePhoto(with: settings, delegate: self)
        }

        
    }
    
    @IBAction func changeCamera(_ sender: Any) {
        cameraflag = !cameraflag
        endSession()
        setDevice()
    }
    
    func endSession(){
        captureSession.removeInput(captureSession.inputs[0] as! AVCaptureDeviceInput )
    }

    
    
    func beginSession() {
        
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            
            if captureSession.canAddOutput(capturePhotoOutput) {
                captureSession.addOutput(capturePhotoOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                if let pl = previewLayer {
                    self.previewView.layer.addSublayer(pl)
                }
            }
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
    }

    
    func setDevice(){
        
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh

        guard let devices = AVCaptureDeviceDiscoverySession.init(deviceTypes: [.builtInTelephotoCamera,.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified).devices else {
            print("Não encontrou a camera")
            return
        }
        
        for device in devices {
            if self.cameraflag {
                if device.position == AVCaptureDevicePosition.back {
                    captureDevice = device
                    beginSession()
                    break
                }
            }else{
                if device.position == AVCaptureDevicePosition.front {
                    captureDevice = device
                    beginSession()
                    break
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureSession.startRunning()
        previewLayer?.frame = self.previewView.bounds
        // ajusta o overlay na view
        imageView = UIImageView(image: img)
        imageView?.contentMode = .scaleToFill
        
        imageView?.frame = CGRect(x: Double(self.previewView.center.x - self.previewView.frame.width / 4 ), y: Double(self.previewView.center.y - self.previewView.frame.height / 8), width: Double(self.previewView.frame.width / 2 ), height: Double(self.previewView.frame.height / 4))
        // adiciona o overlay na view
        self.previewView.addSubview(imageView!)
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(UIImage(data: dataImage)?.size ?? "?")
        }
    }

    
    
}

