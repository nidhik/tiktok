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
    
    func createUploadUrlForAsset(completion: @escaping (URL?, Error?) -> Void) {
        let parameters = [
            "new_asset_settings":[
                "playback_policies":["public"]
            ]
        ]
        let username = "9ffe0382-a562-4c1c-abcb-848eccd00505"
        let password = "+tynuWL/H2/QNcVbSy/MkeFfEOjY6P0/IiYaI8n3ZqhGeyjZQYlC+U97VoySaGDS7iJNmPEPK0Z"
        let credentialData = "\(username):\(password)".data(using: .utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        
        AF.request("https://api.mux.com/video/v1/uploads", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: HTTPHeaders(headers))
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    let result = json as! Dictionary<String, Any>
                    guard let data = result["data"] as? Dictionary<String, Any>,
                        let location = data["url"] as? String else {
                            completion(nil, NSError(domain: "com.nidhi.tiktok", code: 400, userInfo: nil))
                            return
                    }
                    completion(URL(string:  location), nil)
                case let .failure(error):
                    completion(nil, error)
                }
        }
    }
    
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
    
    func uploadFileToMux(fileURL: URL) {
        createUploadUrlForAsset(completion: {(url, error) in
            if (error == nil) {
                AF.upload(fileURL, to: url!, method: .put).responseJSON { response in
                    debugPrint(response)
                }
            } else {
                print("Could not create direct upload url: \(String(describing: error))")
            }
        })
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
