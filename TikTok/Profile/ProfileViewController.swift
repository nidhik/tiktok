
//
//  ViewController.swift
//  Texture
//
//  Copyright (c) Facebook, Inc. and its affiliates.  All rights reserved.
//  Changes after 4/13/2017 are: Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

import UIKit
import AsyncDisplayKit

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
    }
}

class ProfileViewController: ASViewController<ASCollectionNode>, ASCollectionDelegate, ASCollectionDataSource {
    let itemCount = 1000

    let itemSize: CGSize
    let padding: CGFloat
    var collectionNode: ASCollectionNode {
        return node!
    }

    init() {
        let layout = UICollectionViewFlowLayout()
        (padding, itemSize) = ProfileViewController.computeLayoutSizesForMainScreen()
        layout.minimumInteritemSpacing = padding
        layout.minimumLineSpacing = padding
        super.init(node: ASCollectionNode(collectionViewLayout: layout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Color", style: .plain, target: self, action: #selector(didTapColorsButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Layout", style: .plain, target: self, action: #selector(didTapLayoutButton))
        collectionNode.delegate = self
        collectionNode.dataSource = self
        title = "Background Updating"
    }
    
    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        (padding, itemSize) = ProfileViewController.computeLayoutSizesForMainScreen()
        layout.minimumInteritemSpacing = padding
        layout.minimumLineSpacing = padding
        super.init(node: ASCollectionNode(collectionViewLayout: layout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Color", style: .plain, target: self, action: #selector(didTapColorsButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Layout", style: .plain, target: self, action: #selector(didTapLayoutButton))
        collectionNode.delegate = self
        collectionNode.dataSource = self
        title = "Background Updating"
    }
    
    // MARK: ASCollectionDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }

    func collectionView(_ collectionView: ASCollectionView, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let node = DemoCellNode()
            node.backgroundColor = UIColor.random()
            node.childA.backgroundColor = UIColor.random()
            node.childB.backgroundColor = UIColor.random()
            return node
        }
    }

    func collectionView(_collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: NSIndexPath) -> ASSizeRange {
        return ASSizeRangeMake(itemSize, itemSize)
    }

    // MARK: Action Handling

    @objc private func didTapColorsButton() {
        let currentlyVisibleNodes = collectionNode.visibleNodes
        let queue = DispatchQueue.global()
        queue.async() {
            for case let node as DemoCellNode in currentlyVisibleNodes {
                node.backgroundColor = UIColor.random()
            }
        }
    }

    @objc private func didTapLayoutButton() {
        let currentlyVisibleNodes = collectionNode.visibleNodes
        let queue = DispatchQueue.global()
        queue.async() {
            for case let node as DemoCellNode in currentlyVisibleNodes {
                node.state.advance()
                node.setNeedsLayout()
            }
        }
    }

    // MARK: Static

    static func computeLayoutSizesForMainScreen() -> (padding: CGFloat, itemSize: CGSize) {
        let numberOfColumns = 4
        let screen = UIScreen.main
        let scale = screen.scale
        let screenWidth = Int(screen.bounds.width * screen.scale)
        let itemWidthPx = (screenWidth - (numberOfColumns - 1)) / numberOfColumns
        let leftover = screenWidth - itemWidthPx * numberOfColumns
        let paddingPx = leftover / (numberOfColumns - 1)
        let itemDimension = CGFloat(itemWidthPx) / scale
        let padding = CGFloat(paddingPx) / scale
        return (padding: padding, itemSize: CGSize(width: itemDimension, height: itemDimension))
    }
}
