//
//  RegisterViewController.swift
//  WUHack
//
//  Created by Calvin on 9/19/15.
//  Copyright (c) 2015 Calvin. All rights reserved.
//

import Foundation
import UIKit

class RegisterViewController : UIViewController, UITextFieldDelegate
{

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var phone: UITextField!
    
    var helper = LoginHelper()
    
    var activetextfield : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.tag = 0
        password.tag = 1
        phone.tag = 2

        username.delegate = self
        password.delegate = self
        phone.delegate = self
    }
    
    @IBAction func createUser(sender: AnyObject)
    {
        helper.registerUser(username.text, password: password.text, phonenumber: phone.text, completionHandler: {
            (success: Bool!, error: NSError!) -> Void in
            if success == true
            {
                self.performSegueWithIdentifier("SegueFromRegister", sender: self)
            }
            else
            {
                let alert = UIAlertController(title: "Oops!", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
                let alertAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
                alert.addAction(alertAction)
                self.presentViewController(alert, animated: true) { () -> Void in }
            }
        })
    }

    
    //begin delegates
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activetextfield = textField
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        switch(textField.tag)
        {
        case 0:
            password.becomeFirstResponder()
        case 1:
            phone.becomeFirstResponder()
        default:
            closeKeyboard()
            createUser(self)
        }
        return true
    }
    
    func closeKeyboard()
    {
        if(self.activetextfield != nil) {
            self.activetextfield.resignFirstResponder()
            self.activetextfield = nil
        }
    }
    
}