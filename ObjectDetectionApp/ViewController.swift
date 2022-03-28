//
//  ViewController.swift
//  ObjectDetectionApp
//
//  Created by Khayrul on 3/27/22.
//

import UIKit

class ViewController: UIViewController {
    
    private var modelDataHandler: ModelDataHandler? =
      ModelDataHandler(modelFileInfo: MobileNetSSD.modelInfo, labelsFileInfo: MobileNetSSD.labelsInfo)
    var imageNumber: Int = 2
    var imageCount: Int = 1
    @IBOutlet var textField: UITextView!
    @IBOutlet var imageView: UIImageView!

    @IBAction func nextButton(_ sender: Any) {
        textField.text = ""
        if imageCount>=imageNumber {
            imageCount = 1
        }else {
            imageCount += 1
        }
        imageView.image = UIImage(named: String(imageCount))
    }
    @IBAction func detectObject(_ sender: Any) {
        textField.text = ""
        doInference()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private func doInference() {
        if let imageAnalysis = imageView?.image {
            sceneLabel(forImage: imageAnalysis)
        }
    }
    
    private func sceneLabel(forImage image:UIImage) {
        if let pixelBuffer = buffer(from: image) {
            guard let result = self.modelDataHandler?.runModel(onFrame: pixelBuffer) else {
                return
            }
            
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)

            DispatchQueue.main.async {
                
              // Draws the bounding boxes and displays class names and confidence scores.
              //self.drawAfterPerformingCalculations(onInferences: result.inferences, withImageSize: CGSize(width: CGFloat(width), height: CGFloat(height)))
            }
            //print(result.inferences.count)
            let inference = result.inferences
            for i in 0...(inference.count)-1 {
                textField.text! += String(i + 1) + "." + inference[i].className
                textField.text! += "\n"
                print(inference[i].rect.midX, inference[i].rect.midY, inference[i].rect.height, inference[i].rect.width)
                
            }
        }
    }
    
    


}

func buffer(from image: UIImage) -> CVPixelBuffer? {
  let attrs = [
    kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
    kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
  ] as CFDictionary

  var pixelBuffer: CVPixelBuffer?
  let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                   Int(image.size.width),
                                   Int(image.size.height),
                                   kCVPixelFormatType_32BGRA,
                                   attrs,
                                   &pixelBuffer)

  guard let buffer = pixelBuffer, status == kCVReturnSuccess else {
    return nil
  }

  CVPixelBufferLockBaseAddress(buffer, [])
  defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
  let pixelData = CVPixelBufferGetBaseAddress(buffer)

  let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
  guard let context = CGContext(data: pixelData,
                                width: Int(image.size.width),
                                height: Int(image.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
    return nil
  }

  context.translateBy(x: 0, y: image.size.height)
  context.scaleBy(x: 1.0, y: -1.0)

  UIGraphicsPushContext(context)
  image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
  UIGraphicsPopContext()

  return pixelBuffer
}

