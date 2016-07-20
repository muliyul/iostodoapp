//
//  TextFieldWithBorderRadius.swift
//  todo
//
//  Created by Muli Yulzary on 16/07/2016.
//  Copyright © 2016 Muli Yulzary. All rights reserved.
//

import UIKit

@IBDesignable class TextFieldWithBorderRadius: UITextField {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }

}
