//
//  ViewController.swift
//  CustomCamera
//
//  Created by Guilherme Gatto on 04/08/17.
//  Copyright © 2017 mackmobile. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let captureSession = AVCaptureSession()
    let capturePhotoOutput = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    var cameraflag = true
    
    @IBOutlet weak var previewView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDevice()

    }

    
    @IBAction func capture(_ sender: Any) {
    }
    
    @IBAction func changeCamera(_ sender: Any) {
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

}

