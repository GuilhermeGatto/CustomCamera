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

    }

    
    @IBAction func capture(_ sender: Any) {
    }
    
    @IBAction func changeCamera(_ sender: Any) {
    }

}

