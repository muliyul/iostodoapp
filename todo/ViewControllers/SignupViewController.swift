//
//  SignupViewController.swift
//  todo
//
//  Created by Muli Yulzary on 16/07/2016.
//  Copyright © 2016 Muli Yulzary. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SignupViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var password2TF: UITextField!
    @IBOutlet weak var profileImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.profileImage.image = image
    }
    
    @IBAction func choosePicture(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        let alert = UIAlertController(title: "Choose profile picture", message: "Choose from", preferredStyle: .ActionSheet)
        let options = [
            UIAlertAction(title: "Camera", style: .Default) { (action) -> Void in
                picker.sourceType = .Camera
                self.presentViewController(picker, animated: true, completion: nil)
            },
            UIAlertAction(title: "Photo Library", style: .Default) { (action) -> Void in
                picker.sourceType = .PhotoLibrary
                self.presentViewController(picker, animated: true, completion: nil)
            },
            UIAlertAction(title: "Photo Album", style: .Default) { (action) -> Void in
                picker.sourceType = .SavedPhotosAlbum
                self.presentViewController(picker, animated: true, completion: nil)
            },
            UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
        ]
        for option in options {
            alert.addAction(option)
        }
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func signupBtnTapped(sender: UIButton) {
        guard passwordTF?.text != nil && passwordTF?.text == password2TF?.text
            && emailTF?.text != nil else {
            let alert = UIAlertController(title: "Oops...", message: "Check your fields!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        var data : NSData? = nil
        if let image = profileImage?.image {
            data = UIImageJPEGRepresentation(image, 0.8)
        }
        
        NetworkingService.sharedInstance().signUp(usernameTF.text!, email: emailTF.text!, password: passwordTF.text!, data: data) { (user, error) in
                guard error == nil else {
                    return
                }
                let taskListVC = self.storyboard!.instantiateViewControllerWithIdentifier("nav")
                self.presentViewController(taskListVC, animated: true, completion: nil)
            }
    }
    
}
