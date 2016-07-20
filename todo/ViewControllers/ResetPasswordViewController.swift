//
//  ResetPasswordViewController.swift
//  todo
//
//  Created by Muli Yulzary on 16/07/2016.
//  Copyright © 2016 Muli Yulzary. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var emailTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetBtnTapped(sender: UIButton) {
        guard emailTF.text != "" else {
            return
        }
        
        FIRAuth.auth()?.sendPasswordResetWithEmail(emailTF.text!, completion: { (e) in
            guard e == nil else{
                debugPrint(e?.localizedDescription)
                return
            }
            
            let alert = UIAlertController(title: "Yo!", message: "Check your inbox for further instructions!", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "Ok", style: .Default, handler: { [weak self] (action) in
                self?.dismissViewControllerAnimated(true, completion: { [weak self] in
                    let login = self?.storyboard?.instantiateViewControllerWithIdentifier("login")
                    self?.presentViewController(login!, animated: true, completion: nil)
                })
            })
            
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
