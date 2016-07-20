//
//  ProfileViewController.swift
//  todo
//
//  Created by Muli Yulzary on 17/07/2016.
//  Copyright © 2016 Muli Yulzary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var password2TF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        guard let user = FIRAuth.auth()?.currentUser else {return}
        
        emailTF.text = user.email
        
        guard let photoUrl = user.photoURL?.absoluteString else {
            return
        }
        
        profilePicture.downloadedFrom(photoUrl)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        guard let _ = FIRAuth.auth()?.currentUser else {
            let loginVC = storyboard?.instantiateViewControllerWithIdentifier("login") as! LoginViewController
            presentViewController(loginVC, animated: true, completion: nil)
            return
        }
        super.viewWillAppear(animated)
    }
    
    @IBAction func updateProfileTapped(sender: AnyObject) {
        guard let user = FIRAuth.auth()?.currentUser else{
            return
        }
        
        guard passwordTF.text == password2TF.text else {
            return
        }
        
        let password = passwordTF.text!
        
        
        if user.email != emailTF.text {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            user.updateEmail(emailTF.text!) { e in
                guard e == nil else {
                    debugPrint(e!.localizedDescription)
                    return
                }
                
                self.updatePassword(password) { e in
                    
                }
            }
        } else {
            updatePassword(password) { e in
                
            }
        }
        
    }
    
    func updatePassword(password: String, completion: ((NSError?)->())? = nil) {
        guard let user = FIRAuth.auth()?.currentUser else{
            return
        }
        
        guard password != "" else {return}
        
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            user.updatePassword(password, completion: { (e) in
                guard e == nil else {
                    debugPrint(e?.localizedDescription)
                    completion?(e)
                    return
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion?(nil)
            })
        }
    
    @IBAction func logoutBtnTapped(sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
        let loginVC = storyboard!.instantiateViewControllerWithIdentifier("login")
        presentViewController(loginVC, animated: true, completion: nil)
    }
}
