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
                        moveCellInsideOfCollectionView(collectionView: self, destIndexPath: destIndexPath!)
                    } else {
                        moveCellAcrossTheCollectionView(sourceCollectionView: pairCollectionView, destCollectionView: self, destIndexPath: destIndexPath!)
                    }
                } else {
                    if movingCellFrom == self {
                        let destIndexPath = IndexPath(row: collectionViewDataSource.count-1, section: 0)
                        moveCellInsideOfCollectionView(collectionView: self, destIndexPath: destIndexPath)
                    } else {
                        let destIndexPath = IndexPath(row: collectionViewDataSource.count, section: 0)
                        moveCellAcrossTheCollectionView(sourceCollectionView: pairCollectionView, destCollectionView: self, destIndexPath: destIndexPath)
                    }
                }
            } else if pairCollectionView.frame.contains(pointInView) {
                let pointInB = self.convert(point, to: pairCollectionView)
                let destIndexPath = pairCollectionView.indexPathForItem(at: pointInB)
                if destIndexPath != nil {
                    if movingCellFrom == self {
                        moveCellAcrossTheCollectionView(sourceCollectionView: self, destCollectionView: pairCollectionView, destIndexPath: destIndexPath!)
                    } else {
                        moveCellInsideOfCollectionView(collectionView: pairCollectionView, destIndexPath: destIndexPath!)
                    }
                } else {
                    if movingCellFrom == self {
                        let destIndexPath = IndexPath(row: pairCollectionView.collectionViewDataSource.count, section: 0)
                        moveCellAcrossTheCollectionView(sourceCollectionView: self, destCollectionView: pairCollectionView, destIndexPath: destIndexPath)
                    } else {
                        let destIndexPath = IndexPath(row: pairCollectionView.collectionViewDataSource.count-1, section: 0)
                        moveCellInsideOfCollectionView(collectionView: pairCollectionView, destIndexPath: destIndexPath)
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
    
    func moveCellInsideOfCollectionView(collectionView:BetweenCollectionView, destIndexPath: IndexPath){
        collectionView.collectionViewDataSource.insert(collectionView.collectionViewDataSource.remove(at: movingCellIndexPath.row), at: destIndexPath.row)
        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: collectionView, syncDataSource: collectionView.collectionViewDataSource)
        collectionView.moveItem(at: movingCellIndexPath, to: destIndexPath)
        movingCellIndexPath = destIndexPath
        let cell = collectionView.cellForItem(at: movingCellIndexPath)
        cell?.alpha = 0.0
    }
    
    func moveCellAcrossTheCollectionView(sourceCollectionView:BetweenCollectionView, destCollectionView: BetweenCollectionView, destIndexPath: IndexPath) {
        let data = sourceCollectionView.collectionViewDataSource.remove(at: movingCellIndexPath.row)
        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: sourceCollectionView, syncDataSource: sourceCollectionView.collectionViewDataSource)
        sourceCollectionView.deleteItems(at: [movingCellIndexPath])
        destCollectionView.collectionViewDataSource.insert(data, at: destIndexPath.row)
        betweenCollectionViewDelegate?.betweenCollectionView(collectionView: destCollectionView, syncDataSource: destCollectionView.collectionViewDataSource)
        destCollectionView.insertItems(at: [destIndexPath])
        movingCellIndexPath = destIndexPath
        movingCellFrom = destCollectionView
        let cell = destCollectionView.cellForItem(at: movingCellIndexPath)
        cell?.alpha = 0.0
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
