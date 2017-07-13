//
//  BetweenCollectionView.swift
//  ItemsBetweenCollectionView
//
//  Created by TKang on 2017. 7. 12..
//  Copyright © 2017년 Practice. All rights reserved.
//

import UIKit

protocol BetweenCollectionViewDelegate: class {
    func betweenCollectionView(collectionView: BetweenCollectionView, syncDataSource: [Any])
}

class BetweenCollectionView: UICollectionView {
    var movingCellIndexPath: IndexPath!
    var movingCellImageView: UIImageView!
    var movingCellTappedPoint: CGPoint!
    var movingCellFrom: BetweenCollectionView!
    
    var collectionViewDataSource: [Any]!
    var pairCollectionView: BetweenCollectionView!
    
    weak var betweenCollectionViewDelegate:BetweenCollectionViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        customInit()
    }
    
    func customInit() {
        let longPressGestureForMovingCells = UILongPressGestureRecognizer(target: self, action: #selector(movingCell(_:)))
        longPressGestureForMovingCells.minimumPressDuration = 0.15
        self.addGestureRecognizer(longPressGestureForMovingCells)
    }
    
    func movingCell(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: self)
        switch gesture.state{
        case .began:
            guard let indexPath = self.indexPathForItem(at: point) else {
                gesture.isEnabled = false
                gesture.isEnabled = true
                return
            }
            movingCellIndexPath = indexPath
            movingCellFrom = self
            let cell = self.cellForItem(at: indexPath)
            movingCellImageView = captureCells(cell: cell)!
            movingCellImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            let pointInView = superview!.convert(point, from: self)
            movingCellTappedPoint = cell?.convert(point, from: self)
            movingCellImageView.frame = CGRect(origin: CGPoint(x:pointInView.x-movingCellTappedPoint.x, y:pointInView.y-movingCellTappedPoint.y), size: movingCellImageView.frame.size)
            superview!.addSubview(movingCellImageView)
            cell?.alpha = 0.0
        case .changed:
            let pointInView = superview!.convert(point, from: self)
            movingCellImageView.frame = CGRect(origin: CGPoint(x:pointInView.x-movingCellTappedPoint.x ,y:pointInView.y-movingCellTappedPoint.y), size: movingCellImageView.frame.size)
            if self.frame.contains(pointInView) {
                let destIndexPath = self.indexPathForItem(at: point)
                if destIndexPath != nil {
                    if movingCellFrom == self {
                        collectionViewDataSource.insert(collectionViewDataSource.remove(at: movingCellIndexPath.row), at: destIndexPath!.row)
                        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: self, syncDataSource: collectionViewDataSource)
                        self.moveItem(at: movingCellIndexPath, to: destIndexPath!)
                        movingCellIndexPath = destIndexPath
                        let cell = self.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    } else {
                        let data = pairCollectionView.collectionViewDataSource.remove(at: movingCellIndexPath.row)
                        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: pairCollectionView, syncDataSource: pairCollectionView.collectionViewDataSource)
                        pairCollectionView.deleteItems(at: [movingCellIndexPath])
                        collectionViewDataSource.insert(data, at: destIndexPath!.row)
                        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: self, syncDataSource: collectionViewDataSource)
                        self.insertItems(at: [destIndexPath!])
                        movingCellIndexPath = destIndexPath
                        movingCellFrom = self
                        let cell = self.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    }
                } else {
                    if movingCellFrom == self {
                        let destIndexPath = IndexPath(row: collectionViewDataSource.count-1, section: 0)
                        collectionViewDataSource.insert(collectionViewDataSource.remove(at: movingCellIndexPath.row), at: destIndexPath.row)
                        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: self, syncDataSource: collectionViewDataSource)
                        self.moveItem(at: movingCellIndexPath, to: destIndexPath)
                        movingCellIndexPath = destIndexPath
                        let cell = self.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    } else {
                        let destIndexPath = IndexPath(row: collectionViewDataSource.count, section: 0)
                        let data = pairCollectionView.collectionViewDataSource.remove(at: movingCellIndexPath.row)
                        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: pairCollectionView, syncDataSource: pairCollectionView.collectionViewDataSource)
                        pairCollectionView.deleteItems(at: [movingCellIndexPath])
                        collectionViewDataSource.insert(data, at: destIndexPath.row)
                        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: self, syncDataSource: collectionViewDataSource)
                        self.insertItems(at: [destIndexPath])
                        movingCellIndexPath = destIndexPath
                        movingCellFrom = self
                        let cell = self.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    }
                }
            } else if pairCollectionView.frame.contains(pointInView) {
                let pointInB = self.convert(point, to: pairCollectionView)
                let destIndexPath = pairCollectionView.indexPathForItem(at: pointInB)
                if destIndexPath != nil {
                    if movingCellFrom == self {
                        let data = collectionViewDataSource.remove(at: movingCellIndexPath.row)
                        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: self, syncDataSource: collectionViewDataSource)
                        self.deleteItems(at: [movingCellIndexPath])
                        pairCollectionView.collectionViewDataSource.insert(data, at: destIndexPath!.row)
                        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: pairCollectionView, syncDataSource: pairCollectionView.collectionViewDataSource)
                        pairCollectionView.insertItems(at: [destIndexPath!])
                        movingCellIndexPath = destIndexPath
                        movingCellFrom = pairCollectionView
                        let cell = pairCollectionView.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    } else {
                        pairCollectionView.collectionViewDataSource.insert(pairCollectionView.collectionViewDataSource.remove(at: movingCellIndexPath.row), at: destIndexPath!.row)
                        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: pairCollectionView, syncDataSource: pairCollectionView.collectionViewDataSource)
                        pairCollectionView.moveItem(at: movingCellIndexPath, to: destIndexPath!)
                        movingCellIndexPath = destIndexPath
                        let cell = pairCollectionView.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    }
                } else {
                    if movingCellFrom == self {
                        let destIndexPath = IndexPath(row: pairCollectionView.collectionViewDataSource.count, section: 0)
                        let data = collectionViewDataSource.remove(at: movingCellIndexPath.row)
                        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: self, syncDataSource: collectionViewDataSource)
                        self.deleteItems(at: [movingCellIndexPath])
                        pairCollectionView.collectionViewDataSource.insert(data, at: destIndexPath.row)
                        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: pairCollectionView, syncDataSource: pairCollectionView.collectionViewDataSource)
                        pairCollectionView.insertItems(at: [destIndexPath])
                        movingCellIndexPath = destIndexPath
                        movingCellFrom = pairCollectionView
                        let cell = pairCollectionView.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    } else {
                        let destIndexPath = IndexPath(row: pairCollectionView.collectionViewDataSource.count-1, section: 0)
                        pairCollectionView.collectionViewDataSource.insert(pairCollectionView.collectionViewDataSource.remove(at: movingCellIndexPath.row), at: destIndexPath.row)
                        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: pairCollectionView, syncDataSource: pairCollectionView.collectionViewDataSource)
                        pairCollectionView.moveItem(at: movingCellIndexPath, to: destIndexPath)
                        movingCellIndexPath = destIndexPath
                        let cell = pairCollectionView.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    }
                }
            }
        case .ended:
            print("ended")
            movingCellImageView.removeFromSuperview()
            movingCellImageView = nil
            if movingCellFrom == self {
                let cell = self.cellForItem(at: movingCellIndexPath)
                cell?.alpha = 1.0
            } else {
                let cell = pairCollectionView.cellForItem(at: movingCellIndexPath)
                cell?.alpha = 1.0
            }
        default:
            break
        }
    }
    
    func captureCells(cell: UICollectionViewCell?) -> UIImageView? {
        guard cell != nil else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(cell!.frame.size, true, 0)
        cell!.drawHierarchy(in: cell!.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = cell!.frame
        
        return imageView
    }
}
