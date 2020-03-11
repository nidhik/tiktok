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

//extension UIImageView {
//    func load(_ urlString: String) {
//        guard let url = URL(string: urlString) else { return }
//        DispatchQueue.global().async { [weak self] in
//            if let data = try? Data(contentsOf: url) {
//                if let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self?.image = image
//                    }
//                }
//            }
//        }
//    }
//}

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var posts: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPosts()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = posts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func addVideoPlayer(videoUrl: URL, to view: UIView) {
        let player = AVPlayer(url: videoUrl)
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        view.layer.sublayers?
            .filter { $0 is AVPlayerLayer }
            .forEach { $0.removeFromSuperlayer() }
        view.layer.addSublayer(layer)
        player.play()
    }
    
    
    func getPosts() {
        let query = PFQuery(className:"Post")
        query.order(byDescending: "createdAt")
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
                    self.posts.append(id)
                }
                print(self.posts)
                let videoURL = String(format: "https://stream.mux.com/%@.m3u8", self.posts.first!)
                self.addVideoPlayer(videoUrl: URL(string: videoURL)!, to: self.topView)
                self.tableView.reloadData()
                
            }
        }
    }
}
