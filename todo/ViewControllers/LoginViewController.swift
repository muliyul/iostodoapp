//
//  LoginViewController.swift
//  todo
//
//  Created by Muli Yulzary on 16/07/2016.
//  Copyright © 2016 Muli Yulzary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate{
    @IBOutlet weak var fbLoginBtn: FBSDKLoginButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginBtn.readPermissions = ["email"]
    }
    
    @IBAction func unwindForSegue(unwindSegue: UIStoryboardSegue) {
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        NetworkingService.sharedInstance().signIn(FBSDKAccessToken.currentAccessToken().tokenString) { (user, error) in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.presentViewController(self.storyboard!.instantiateViewControllerWithIdentifier("nav"), animated: true, completion: nil)            
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        try! FIRAuth.auth()?.signOut()
    }

}
