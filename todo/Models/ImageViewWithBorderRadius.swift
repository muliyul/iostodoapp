//
//  ImageViewWithBorderRadius.swift
//  todo
//
//  Created by Muli Yulzary on 16/07/2016.
//  Copyright © 2016 Muli Yulzary. All rights reserved.
//

import UIKit

@IBDesignable class ImageViewWithBorderRadius: UIImageView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: CGColor? = UIColor.blackColor().CGColor {
        didSet {
            layer.borderColor = borderColor
        }
    }

}
