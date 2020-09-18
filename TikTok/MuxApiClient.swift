//
//  MuxApiClient.swift
//  TikTok
//
//  Created by Nidhi Kulkarni on 3/9/20.
//  Copyright © 2020 Nidhi Kulkarni. All rights reserved.
//

import UIKit
import Alamofire
import Parse

class MuxApiClient: NSObject {
    
    func uploadFileToParse(fileURL: URL) {
        do {
            let file = try PFFileObject(name: "myvideo.mp4", contentsAtPath: fileURL.path)
            let post = PFObject(className: "Post")
            post["videoFile"] = file
            post.saveInBackground { (success, error) in
                if (error == nil) {
                    print("success!")
                } else {
                    print("Failed to save video file to parse \(String(describing: error))")
                }
            }
            
        } catch (let error) {
            print(error)
        }
    }
    
    func uploadVideo(fileURL: URL) {
        PFCloud.callFunction(inBackground: "upload", withParameters: ["foo": "bar"], block: { (result, error) in
            if (error == nil) {
                print("direct upload info: \(String(describing: result))")
                guard
                    let result = result as? Dictionary<String, Any>,
                    let muxUploadURL = result["url"] as? String else  {
                        print("did not get mux direct upload url")
                        return
                }
                AF.upload(fileURL, to: muxUploadURL, method: .put).response { response in
                    debugPrint(response)
                }
            } else {
                print(error ?? "error calling upload cloud function")
            }
        })
    }
    
}
