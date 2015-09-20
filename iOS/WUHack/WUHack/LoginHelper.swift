//
//  LoginHelper.swift
//  WUHack
//
//  Created by Calvin on 9/19/15.
//  Copyright (c) 2015 Calvin. All rights reserved.
//

import Foundation
import Parse
import Bolts

class LoginHelper
{
    init(){}
    
    func registerUser(username : String, password : String, phonenumber : String, completionHandler: (Bool!, NSError!) -> Void)
    {
        var user = PFUser()
        user.username = username
        user.password = password
        user.setObject(phonenumber, forKey: "phonenumber")
        
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo?["error"] as? NSString
                // Show the errorString somewhere and let the user try again.
                completionHandler(false, error)
            } else {
                // Hooray! Let them use the app now.
                var channels = PFObject(className: "UserChannels")
                channels.setObject(PFUser.currentUser()!.objectId!, forKey: "user")
                channels.setObject(phonenumber, forKey: "phonenumber")
                channels.save()
                completionHandler(true, nil)
            }
        }
        
    }
    
    
    func login(username : String, password: String, completionHandler: (Bool!, NSError!) -> Void)
    {
        PFUser.logInWithUsernameInBackground(username, password: password) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                // Do stuff after successful login.
                completionHandler(true, nil)
            } else {
                // The login failed. Check error to see why.
                completionHandler(false, error)
            }
        }
    }
}