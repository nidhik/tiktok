//
//  PhotoTableNodeCell.swift
//  Texture
//
//  Copyright (c) Facebook, Inc. and its affiliates.  All rights reserved.
//  Changes after 4/13/2017 are: Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import AsyncDisplayKit
import Parse
import AVFoundation

class PostTableNodeCell: UITableViewCell {

    var model: PFObject?
    var rootNode: ASDisplayNode
    var hlsVideoNode: ASVideoNode
    
    
    required init?(coder: NSCoder) {
        
        rootNode = ASDisplayNode()
        hlsVideoNode = ASVideoNode()
        
        super.init(coder: coder)
        rootNode.frame = self.contentView.bounds;
        rootNode.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .systemPink
        
        hlsVideoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        hlsVideoNode.backgroundColor = .systemPink
        hlsVideoNode.shouldAutorepeat = true;
        hlsVideoNode.shouldAutoplay = true;
        hlsVideoNode.muted = true;
        
        rootNode.layoutSpecBlock = { node, constrainedSize in
            self.hlsVideoNode.style.preferredSize = self.contentView.bounds.size
            self.hlsVideoNode.style.layoutPosition = CGPoint(x: 0, y: 0)
            return ASAbsoluteLayoutSpec(children:[self.hlsVideoNode]);
        }
        
        self.contentView.addSubnode(rootNode)
    }
    
    func updateModel(model: PFObject) {
        self.model = model
        hlsVideoNode.frame = self.contentView.frame
        let url = getVideoURL(post: self.model!)!
        print(url)
        hlsVideoNode.asset = AVAsset(url: url)
        hlsVideoNode.play()
    }
    
    // MARK: Lifecycle
    
    func getVideoURL(post: PFObject) -> URL? {
        guard let asset = post["asset"] as? [String: Any],
        let playbackIds = asset["playback_ids"] as? [[String: Any]],
        let id = playbackIds[0]["id"] as? String else {
            print("cannot get playback id from post")
            return nil
        }
        
        let urlString = String(format: "https://stream.mux.com/%@.m3u8", id)
        return URL(string: urlString)
    }
    
    func getThumbnailURL(post: PFObject) -> URL? {
           guard let asset = post["asset"] as? [String: Any],
           let playbackIds = asset["playback_ids"] as? [[String: Any]],
           let id = playbackIds[0]["id"] as? String else {
               print("cannot get playback id from post")
               return nil
           }
           
           let urlString = String(format: "https://image.mux.com/%@/thumbnail.jpg", id)
           return URL(string: urlString)
    }
}
