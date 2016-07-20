//
//  UIImageViewExtension.swift
//  todo
//
//  Created by Muli Yulzary on 20/07/2016.
//  Copyright © 2016 Muli Yulzary. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .ScaleAspectFit) {
        guard let url = NSURL(string: link) else { return }
        contentMode = mode
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.image = image
            })
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
}