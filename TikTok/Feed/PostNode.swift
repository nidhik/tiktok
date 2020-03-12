//
//  PostNode.swift
//  TikTok
//
//  Created by Nidhi Kulkarni on 3/11/20.
//  Copyright © 2020 Nidhi Kulkarni. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Parse

class PostNode: ASCellNode {
    var post: PFObject
    var backgroundImageNode: ASNetworkImageNode
    var gradientNode: GradientNode
    
    init(with post: PFObject) {
        self.post = post
        self.backgroundImageNode = ASNetworkImageNode()
        self.gradientNode = GradientNode()
        
        super.init()
        self.backgroundImageNode.url = self.getThumbnailURL(post: post)
        self.backgroundImageNode.contentMode = .scaleAspectFill
        
        self.gradientNode.isLayerBacked = true;
        self.gradientNode.isOpaque = false;
        
        self.addSubnode(self.backgroundImageNode)
        self.addSubnode(self.gradientNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let ratio = (constrainedSize.min.height)/constrainedSize.max.width
        let imageRatioSpec = ASRatioLayoutSpec(ratio:ratio, child:self.backgroundImageNode);
        let gradientOverlaySpec = ASOverlayLayoutSpec(child:imageRatioSpec, overlay:self.gradientNode)
        return gradientOverlaySpec
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
