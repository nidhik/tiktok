//
//  FeedViewController.swift
//  TikTok
//
//  Created by Nidhi Kulkarni on 3/11/20.
//  Copyright © 2020 Nidhi Kulkarni. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        getPosts()
        
    }
    func getPosts() {
        let query = PFQuery(className:"Post")
        query.order(byAscending: "createdAt")
        query.includeKey("asset")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                print("Successfully retrieved \(objects.count) posts.")
                // Do something with the found objects
                for post in objects {
                    guard
                        let asset = post["asset"] as? [String: Any],
                        let playbackIds = asset["playback_ids"] as? [[String: Any]],
                        let id = playbackIds[0]["id"] as? String else {
                            print("cannot get playback id from post")
                            continue
                    }
                    let thumbnailURL = String(format: "https://image.mux.com/%@/thumbnail.jpg", id)
                    print(thumbnailURL)
                    
                }
            }
        }
    }
}
