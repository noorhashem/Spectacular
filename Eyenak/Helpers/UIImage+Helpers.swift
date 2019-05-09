//
//  UIImage+Helpers.swift
//  Eyenak
//
//  Created by Noor on 6/27/18.
//  Copyright © 2019 Noor. All rights reserved.
//

import UIKit

extension UIImage {

    func resize(toWidth targetWidth: CGFloat, opaque: Bool, scale: CGFloat) -> UIImage {

        let newSize = CGSize(width: targetWidth, height: size.height * (targetWidth / size.width))
        return resize(toSize: newSize, opaque: opaque, scale: scale)
    }

    func resize(toSize targetSize: CGSize, opaque: Bool, scale: CGFloat) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(targetSize, opaque, scale)
        draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
