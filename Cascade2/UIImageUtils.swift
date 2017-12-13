//
//  UIImageUtils.swift
//  Cascade2
//
//  Created by Tony Monckton on 01/12/2017.
//  Copyright © 2017 WeCreate! digital design. All rights reserved.
//

import Foundation
import UIKit


class UIImageUtils
{
    func resizeImage(image: UIImage, withSize: CGSize) -> UIImage {
        var actualHeight: CGFloat   = image.size.height
        var actualWidth: CGFloat    = image.size.width
        let maxHeight: CGFloat      = withSize.width
        let maxWidth: CGFloat       = withSize.height
        var imgRatio: CGFloat       = actualWidth/actualHeight
        let maxRatio: CGFloat       = maxWidth/maxHeight
        let compressionQuality      = 0.5//50 percent compression
        
        if (actualHeight > maxHeight || actualWidth > maxWidth) {
            if(imgRatio < maxRatio) {
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if(imgRatio > maxRatio) {
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect: CGRect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
            image.draw(in: rect)
            let image: UIImage  = UIGraphicsGetImageFromCurrentImageContext()!
            let imageData       = UIImageJPEGRepresentation(image, CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        
        let resizedImage = UIImage(data: imageData!)
        return resizedImage!
    }
}
