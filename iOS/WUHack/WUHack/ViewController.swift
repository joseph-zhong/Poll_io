//
//  ViewController.swift
//  WUHack
//
//  Created by Calvin on 9/19/15.
//  Copyright (c) 2015 Calvin. All rights reserved.
//

import UIKit
import Parse
import Bolts

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var query = PFQuery(className: "Channel")
        var channel = query.getFirstObject()
        var object = PFObject(className: "Poll")
        object.setObject(true, forKey: "open")
        object.setObject(channel!, forKey: "channel")
        object.setObject("is joseph dumb?", forKey: "topic")
        object.setObject(PFUser.currentUser()!, forKey: "submitter")
        object.save()
        
        
//         PFUser.currentUser()!.addObject(channel!.objectId!, forKey: "Channels")
//         PFUser.currentUser()!.save()
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

