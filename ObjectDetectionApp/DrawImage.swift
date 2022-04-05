//
//  DrawImage.swift
//  ObjectDetectionApp
//
//  Created by Khayrul on 4/5/22.
//

import Foundation
import UIKit

struct Detection {
    let confidence: Float
    let label: String?
    let box: CGRect
    let color: UIColor
}

func drawDetectionsOnImage(_ detections: [Detection], _ image: UIImage) -> UIImage? {
    let imageSize = image.size
    let scale: CGFloat = 0.0
    UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)

    image.draw(at: CGPoint.zero)
    let ctx = UIGraphicsGetCurrentContext()
    var rects:[CGRect] = []
    for detection in detections {
        rects.append(detection.box)
        if let labelText = detection.label {
        let text = "\(labelText) : \(round(detection.confidence*100))"
            let textRect  = CGRect(x: detection.box.minX + imageSize.width * 0.01, y: detection.box.minY + imageSize.width * 0.01, width: detection.box.width, height: detection.box.height)
                    
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                    
        let textFontAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: textRect.width * 0.1, weight: .bold),
            NSAttributedString.Key.foregroundColor: detection.color,
            NSAttributedString.Key.paragraphStyle: textStyle
        ]
                    
        text.draw(in: textRect, withAttributes: textFontAttributes)
        ctx?.addRect(detection.box)
        ctx?.setStrokeColor(detection.color.cgColor)
        ctx?.setLineWidth(9.0)
        ctx?.strokePath()
        }
    }

    guard let drawnImage = UIGraphicsGetImageFromCurrentImageContext() else {
        fatalError()
    }

    UIGraphicsEndImageContext()
    return drawnImage
}
