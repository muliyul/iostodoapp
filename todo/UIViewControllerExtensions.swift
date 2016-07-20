//
//  UIViewControllerExtensions.swift
//  todo
//
//  Created by Muli Yulzary on 20/07/2016.
//  Copyright © 2016 Muli Yulzary. All rights reserved.
//

import UIKit

extension UIViewController {
    func displayNavBarActivity() {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        indicator.startAnimating()
        let item = UIBarButtonItem(customView: indicator)
        navigationItem.leftBarButtonItem = item
    }
    
    func dismissNavbarActivity() {
        navigationItem.leftBarButtonItem = nil
    }
}
