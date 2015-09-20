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

class DataViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var entityLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        var query = PFQuery(className: "Channel")
//        var channel = query.getFirstObject()
//        var object = PFObject(className: "Poll")
//        object.setObject(true, forKey: "open")
//        object.setObject(channel!, forKey: "channel")
//        object.setObject("is joseph dumb?", forKey: "topic")
//        object.setObject(PFUser.currentUser()!, forKey: "submitter")
//        object.save()
//
        
//         PFUser.currentUser()!.addObject(channel!.objectId!, forKey: "Channels")
//         PFUser.currentUser()!.save()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        loadQuestion({
            (entity, alchemy, error) -> Void in
            if error == nil
            {
                var question : String = alchemy!.objectForKey("body") as! String
                self.questionLabel.text = question
                
                var entityName : String = entity!.objectForKey("name") as! String
                var entityScore : Double = (entity!.objectForKey("score") as! NSString).doubleValue
                
                
                self.entityLabel.text = self.entitySummary(entityName, score: entityScore)
            }
        })
    }

    func entitySummary(name: String, score: Double) -> String
    {
        var scoreDescription : String = ""
        
        if score < -0.75
        {
            scoreDescription = "terrible"
        }
        else if score < -0.4
        {
            scoreDescription = "bad"
        }
        else if score < -0.1
        {
            scoreDescription = "meh, dubious"
        }
        else if score < 0.1
        {
            scoreDescription = "neutral"
        }
        else if score < 0.4
        {
            scoreDescription = "meh, ok"
        }
        else if score < 0.75
        {
            scoreDescription = "good"
        }
        else
        {
            scoreDescription = "ecstatic"
        }
        
        return "Attitude towards \(name) is \(scoreDescription)."
    }
    
    func loadQuestion(completion: (PFObject?, PFObject?, NSError?) -> Void)
    {
        var query = PFQuery(className: "Entities")
        query.orderByDescending("createdAt")
        query.getFirstObjectInBackgroundWithBlock({
            (object, error) -> Void in
            if error == nil
            {
                if object != nil
                {
                    var alchemyId : String = object!.objectForKey("Alchemy") as! String
                    var alchemyQuery : PFQuery = PFQuery(className: "Alchemy")
                    var alchemy : PFObject? = alchemyQuery.getObjectWithId(alchemyId)
                    
                    completion(object, alchemy, nil)
                }
                else
                {
                    println()
                    completion(nil, nil, nil)
                }
            }
            else
            {
                completion(nil, nil, nil)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

