//
//  ViewController.swift
//  SimpleCoreMLDemo
//
//  Created by Chamin Morikawa on 2020/05/18.
//  Copyright © 2020 Chamin Morikawa. All rights reserved.
//

import UIKit

// we need to import CoreML framework
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgViewPhoto: UIImageView!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // using the MobileNet V2 model, because it is fast
    let model = MobileNetV2()
    
    var selectedPhoto:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // if a sample has been selected, classify it
        if (selectedPhoto != nil) {
            // set image
            imgViewPhoto.image = selectedPhoto
            // start classification in background
            labelInfo.text = "Analyzing Image..."
            activityIndicator.startAnimating()
            
            DispatchQueue.global(qos: .background).async {
                self.classifyImage(img: self.selectedPhoto)
            }
        }
    }
    
    // use camera to take a photo for classification
    @IBAction func cameraButtonTapped(_ sender: Any) {
        // cannot take photos on simulator
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        // clear previous sample, if any
        selectedPhoto = nil
        
        // open camera
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = true
        
        present(cameraPicker, animated: true)
    }
    
    //MARK: Image Picker Delegate
    
    // show the selected photo and perform classification
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        // set image
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        imgViewPhoto.image = image
        
        // start classification in background
        labelInfo.text = "Analyzing Image..."
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .background).async {
            self.classifyImage(img: image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // dod not pick a photo
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Classification
    func classifyImage(img:UIImage) {
        // conversion to the correct input size,
        // and get the image data to a pixel buffer
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 224, height: 224), true, 2.0)
        img.draw(in: CGRect(x: 0, y: 0, width: 224, height: 224))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        // forward pass with time measurement
        let start = DispatchTime.now()
        guard let prediction = try? model.prediction(image: pixelBuffer!) else {
            return
        }
        let end = DispatchTime.now()
        
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // processing time in nano seconds (UInt64)
        let timeInterval = Double(nanoTime) / 1_000_000 // convert to milliseconds, for ease of reading
        
        var resultString: String = "AI thinks this is a \(prediction.classLabel)."
        resultString += String(format:"\n(%f milliseconds)", timeInterval)
        
        // update results on main thread
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.labelInfo.text = resultString
        }
    }
    
    //MARK: Select Sample
    func setSelectedPhoto(img:UIImage) {
        selectedPhoto = img
    }

    // that's all, folks!
}
