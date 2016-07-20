//
//  NetworkingService.swift
//  todo
//
//  Created by Muli Yulzary on 16/07/2016.
//  Copyright © 2016 Muli Yulzary. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

typealias FirebaseCallback = (FIRUser?, NSError?)->Void

class NetworkingService{
    private static let _sharedInstance = NetworkingService()
    private let databaseRef = FIRDatabase.database().reference()
    private let storageRef = FIRStorage.storage().reference()
    var tasks = [Todo]()
    
    static func sharedInstance() -> NetworkingService {
        return _sharedInstance
    }
    
    private init(){
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) -> Void in
            if let user = user {
                debugPrint("User \(user.email!) state changed")
            }
        })
    }
    
    private func saveUserInfo(username: String, password: String) {
        guard let user = FIRAuth.auth()?.currentUser else {
            debugPrint("Tried to write to Firebase without user")
            return
        }
        
        let userData = [
            "username": username,
            "email": user.email!,
            "photoUrl": String(user.photoURL)
        ]
        
        let userRef = databaseRef.child("users")
                                 .child(user.uid)
        
        userRef.setValue(userData)
    }
    
    func signIn(email: String, password: String, completion: FirebaseCallback? = nil){
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) -> Void in
            guard error == nil else {
                debugPrint(error?.localizedDescription)
                return
            }
            completion?(user, error)
        })
    }
    
    private func setUserInfo(username: String, password: String, data: NSData?, completion: FirebaseCallback? = nil){
        guard let user = FIRAuth.auth()?.currentUser else {
            debugPrint("Tried to write to Firebase without user")
            return
        }
        if let imgData = data {
            let imgRef = storageRef.child("users")
                .child(user.uid)
                .child("profileImage.jpg")
            
            let meta = FIRStorageMetadata()
            meta.contentType = "image/jpeg"
            
            imgRef.putData(imgData, metadata: meta) { [weak self] (meta, error) -> Void in
                guard error == nil else {
                    debugPrint(error?.localizedDescription)
                    return
                }
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = username
                changeRequest.photoURL = meta!.downloadURL()
                changeRequest.commitChangesWithCompletion({ (error) -> Void in
                    guard error == nil else {
                        debugPrint(error?.localizedDescription)
                        return
                    }
                    
                    self?.saveUserInfo(username, password: password)
                    completion?(user, nil)
                })
            }

        }else{
            saveUserInfo(username, password: password)
            completion?(user, nil)
        }
    }
    
    func signUp(username: String, email: String, password: String, data: NSData? = nil, completion: FirebaseCallback? = nil){
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { [weak self] (user, error) -> Void in
            guard error == nil else {
                debugPrint(error?.localizedDescription)
                return
            }
            self?.setUserInfo(username, password: password, data: data)
            completion?(user,error)
        })
    }
    
    func signIn(facebookToken: String, completion: FirebaseCallback? = nil){
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(facebookToken)
        if let signedInUser = FIRAuth.auth()?.currentUser {
            signedInUser.linkWithCredential(credential, completion: completion)
        } else {
            FIRAuth.auth()?.signInWithCredential(credential, completion: completion)
        }
    }
    
    func link(facebookToken: String, completion: FirebaseCallback?=nil){
        guard let signedInUser = FIRAuth.auth()?.currentUser else {
            return
        }
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(facebookToken)
        
        signedInUser.linkWithCredential(credential) { (user, error) in
            completion?(user, error)
            guard error == nil else {
                debugPrint(error?.localizedDescription)
                return
            }
        }
    }
    
    func addTodo(task: Todo){
        guard let user = FIRAuth.auth()?.currentUser else {
            debugPrint("Trying to post without user")
            return
        }
        let taskRef = databaseRef.child("users")
                    .child(user.uid)
                    .child("tasks")
                    .childByAutoId()
        taskRef.setValue(task.asDictionary)
    }
}