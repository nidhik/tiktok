//
//  FeedViewController.swift
//  TikTok
//
//  Created by Nidhi Kulkarni on 3/11/20.
//  Copyright © 2020 Nidhi Kulkarni. All rights reserved.
//

import UIKit
import AVFoundation
import Parse
import AlamofireImage
import AsyncDisplayKit

class FeedViewController: UIViewController {
    
    var tableNode: ASTableNode!
    var posts : [PFObject] = []
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.title = "Feed"
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
        loadPosts()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubnode(tableNode)
        self.applyStyle()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableNode.frame = self.view.bounds;
    }

    
    func applyStyle() {
        self.view.backgroundColor = .systemPink
        self.tableNode.view.separatorStyle = .singleLine
        
    }
    
    func wireDelegates() {
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
    }
    
    func loadPosts() {
        let query = PFQuery(className:"Post")
        query.order(byDescending: "createdAt")
        query.includeKey("asset")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let objects = objects {
                print("Successfully retrieved \(objects.count) posts.")
                self.posts = objects
                self.tableNode.reloadData()
            }
        }
    }
}

extension FeedViewController: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        return {
            return PostNode(with: post)
        }
    }
    
}

extension FeedViewController: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let width = UIScreen.main.bounds.size.width;
        let min = CGSize(width: width, height: (UIScreen.main.bounds.size.height/3) * 2);
        let max = CGSize(width: width, height: .infinity);
        return ASSizeRangeMake(min, max);
    }
}
