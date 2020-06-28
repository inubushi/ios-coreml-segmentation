//
//  DeepLabUtils.swift
//  SimpleCoreMLDemo
//
//  Created by Chamin Morikawa on 2020/06/21.
//  Copyright © 2020 Chamin Morikawa. All rights reserved.
//

import Foundation
import UIKit
import CoreML

// input image size and segment colors are declared here
// the colors are selected by me, somewhat lazily ;-)
// the order of colors is BGRA
struct Constants {
    static let deepLabInputWidth = 513
    static let deepLabInputHeight = 513
    
   static  let deepLabSegmentColors: [[UInt8]] = [
        [0, 0, 0, 255], // background is black
        
        [0, 0, 127, 255],        // aeroplane
        [0, 0, 255, 255],       // bicycle
        [0, 127, 255, 255],       // bird
        [0, 127, 127, 255],       // boat
        [0, 127, 0, 255],      // bottle
        
        [0, 255, 0, 255],     // bus
        [0, 255, 127, 255],     // car
        [0, 255, 255, 255],     // cat
        [127, 255, 255, 255],    // chair
        [255, 255, 255, 255],   // cow
        
        [255, 255, 127, 255],   // dining table
        [255, 255, 0, 255],   // dog
        [255, 127, 0, 255],   // horse
        [255, 0, 0, 255],   // motorbike
        [255, 0, 127, 255],    // person
        
        [255, 0, 255, 255],     // poted plant
        [127, 0, 255, 255], // sheep
        [0, 0, 255, 255], // sofa
        [127, 127, 255, 255],  // train
        [127, 127, 127, 255]    // tv
        
    ]
}

func getDeepLabV3Labels()->[String] {
    // I am doing it this way for readability
    var labels: [String] = []
    
    labels.append("Background")
    
    labels.append("Aeroplane")
    labels.append("Bicycle")
    labels.append("Bird")
    labels.append("Boat")
    labels.append("Bottle")
    
    labels.append("Bus")
    labels.append("Car")
    labels.append("Cat")
    labels.append("Chair")
    labels.append("Cow")
    
    labels.append("Dining table")
    labels.append("Dog")
    labels.append("Horse")
    labels.append("Motorbike")
    labels.append("Person")
    
    labels.append("Potted plant")
    labels.append("Sheep")
    labels.append("Sofa")
    labels.append("Train")
    labels.append("TV")
    
    // done
    return labels
}

func getDeepLabUIColorForSegmentIndex(i: Int) -> UIColor {
    let pixelVals: [UInt8] = (Constants.deepLabSegmentColors)[i]
    return (UIColor(red: CGFloat(Double(pixelVals[2])/255.0),
                    green: CGFloat(Double(pixelVals[1])/255.0),
                    blue: CGFloat(Double(pixelVals[0])/255.0),
                    alpha: CGFloat(Double(pixelVals[3])/255.0)))
}

func getDeepLabPixelColorForIndex(i: Int) -> [UInt8] {
    return Constants.deepLabSegmentColors[i]
}

func getDeepLabV3ResultImage(result:MLMultiArray) -> UIImage {
    // convert segment IDs to pixel values
    var bytes: [UInt8] = []
    
    for i in 0...result.count {
        let pixelVal:[UInt8] = getDeepLabPixelColorForIndex(i: Int(truncating: result[i]))
        for j in 0...3 {
            bytes.append(pixelVal[j])
        }
    }
    
    // UIImage conversion
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        .union(.byteOrder32Little)
    let bitsPerComponent:Int = 8
    let bitsPerPixel:Int = 32
    
    var data = bytes
    let providerRef = CGDataProvider(data: NSData(bytes: &data, length: data.count))
    
    let cgim = CGImage(
        width: Constants.deepLabInputWidth,
        height: Constants.deepLabInputHeight,
        bitsPerComponent: bitsPerComponent,
        bitsPerPixel: bitsPerPixel,
        bytesPerRow: Constants.deepLabInputWidth * 4,
        space: rgbColorSpace,
        bitmapInfo: bitmapInfo,
        provider: providerRef!,
        decode: nil,
        shouldInterpolate: true,
        intent: .defaultIntent
    )
    return UIImage(cgImage: cgim!)
    // for now
    //return UIImage(named: "lion.jpg")!
}
