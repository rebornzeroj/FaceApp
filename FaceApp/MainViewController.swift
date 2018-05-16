//
//  MainViewController.swift
//  FaceApp
//
//  Created by Arco on 2018/5/7.
//  Copyright © 2018 c. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class MainViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var shutterBtn: UIButton?
    var faceImg: UIImage?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let previewView = UIView()
        self.view.addSubview(previewView)
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let controlPanel = UIVisualEffectView(effect: blurEffect)
        self.view.addSubview(controlPanel)
        
        let btnImage = UIImage(named: "trigger")
        let triggerButton = UIButton()
        self.shutterBtn = triggerButton
        triggerButton.setImage(btnImage, for: .normal)
        triggerButton.contentMode = .scaleToFill
        
        controlPanel.addSubview(triggerButton)
        
        let albumImage = UIImage(named: "album")
        let albumBtn = UIButton()
        albumBtn.setImage(albumImage, for: .normal)
        albumBtn.contentMode = .scaleToFill
        
        controlPanel.addSubview(albumBtn)
        
        previewView.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.view)
            make.width.equalTo(self.view)
            make.height.equalTo(self.view)
        }

        controlPanel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.view)
            make.width.equalTo(self.view)
            make.height.equalTo(self.view).multipliedBy(0.13)
        }
        
        triggerButton.snp.makeConstraints{ (make) -> Void in
            make.width.equalTo(controlPanel.snp.height).multipliedBy(0.9)
            make.height.equalTo(triggerButton.snp.width)
            make.center.equalTo(controlPanel)
        }
        
        triggerButton.addTarget(self, action: #selector(shutter), for: .touchUpInside)
        
        albumBtn.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(triggerButton)
            make.left.equalTo(controlPanel).offset(10)
            make.width.equalTo(controlPanel.snp.height).multipliedBy(0.9)
            make.height.equalTo(albumBtn.snp.width)
        }
        
        albumBtn.addTarget(self, action: #selector(checkPhotos), for: .touchUpInside)
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
            
            // Get an instance of ACCapturePhotoOutput class
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            // Set the output on the capture session
            captureSession?.addOutput(capturePhotoOutput!)
        } catch {
            print(error)
        }
        

    }

    override func viewDidAppear(_ animated: Bool) {
        self.shutterBtn?.isEnabled = true
    }
    @objc func shutter(){
        // Make sure capturePhotoOutput is valid
        self.shutterBtn?.isEnabled = false
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        // Call capturePhoto method by passing our photo settings and a
        // delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)

    }
    
    @objc func checkPhotos(){
        print("albumbtn clicked")
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let processViewController = ProcessViewController()
            processViewController.faceImg = pickedImage
            self.navigationController?.pushViewController(processViewController, animated: true)
        }
        
        dismiss(animated: true, completion: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        // get captured image
        // Make sure we get some photo sample buffer
        guard error == nil, let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }
        // Convert photo same buffer to a jpeg image data by using // AVCapturePhotoOutput
        guard let imageData =
            AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
                return
        }
        // Initialise a UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        self.faceImg = capturedImage
        let processViewController = ProcessViewController()
        processViewController.faceImg = capturedImage
        self.navigationController?.pushViewController(processViewController, animated: true)
//        if let image = capturedImage {
//            // Save our captured image to photos album
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//        }
    }
}
