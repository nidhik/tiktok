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
    var videoNode: ASVideoNode
    var gradientNode: GradientNode
    
    init(with post: PFObject) {
        self.post = post
        self.backgroundImageNode = ASNetworkImageNode()
        self.gradientNode = GradientNode()
        self.videoNode = ASVideoNode()
        
        super.init()
        self.backgroundImageNode.url = self.getThumbnailURL(post: post)
        self.backgroundImageNode.contentMode = .scaleAspectFill
        
        self.gradientNode.isLayerBacked = true;
        self.gradientNode.isOpaque = false;
        
        self.videoNode.url = self.getThumbnailURL(post: post)
        self.videoNode.shouldAutoplay = false
        self.videoNode.shouldAutorepeat = true
        self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue;
    
        DispatchQueue.main.async() {
            self.videoNode.asset = AVAsset(url: self.getVideoURL(post: post)!)
        }
        
        self.addSubnode(self.videoNode)
        self.addSubnode(self.gradientNode)
        
        DispatchQueue.main.async() {
            let socialControlsView = SocialControlsView()
            socialControlsView.frame = CGRect(origin: CGPoint(x:300, y:280), size: CGSize(width: 83, height: 320))
            self.view.addSubview(socialControlsView)
            
            let postDetailsView = PostDetails()
            postDetailsView.frame =
                CGRect(origin: CGPoint(x:0, y:600), size: CGSize(width: 414, height: 120))
            self.view.addSubview(postDetailsView)
            
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        //        let ratio = (constrainedSize.min.height)/constrainedSize.max.width;
        let ratio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
        
        let ratioSpec = ASRatioLayoutSpec(ratio:ratio, child:self.videoNode);
        
        //        // Layout all nodes absolute in a static layout spec
        //        videoNode.style.layoutPosition = CGPoint(x: 0, y: 0);
        //        videoNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height);
        //        let absoluteSpec = ASAbsoluteLayoutSpec(children: [self.videoNode])
        
        let gradientOverlaySpec = ASOverlayLayoutSpec(child:ratioSpec, overlay:self.gradientNode)
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
    
    func getVideoURL(post: PFObject) -> URL? {
        if let src = post["videoSrc"] as? String {
            return URL(string: src)
        }
        guard let asset = post["asset"] as? [String: Any],
            let playbackIds = asset["playback_ids"] as? [[String: Any]],
            let id = playbackIds[0]["id"] as? String else {
                
                print("cannot get playback id from post")
                return nil
        }
        
        let urlString = String(format: "https://stream.mux.com/%@.m3u8", id)
        return URL(string: urlString)
    }
    
    func mute() {
        self.videoNode.muted = true
    }
    
    func unmute() {
           self.videoNode.muted = false
    }
}
