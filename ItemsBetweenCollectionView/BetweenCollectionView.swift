//
//  BetweenCollectionView.swift
//  ItemsBetweenCollectionView
//
//  Created by TKang on 2017. 7. 12..
//  Copyright © 2017년 Practice. All rights reserved.
//

import UIKit

@objc protocol BetweenCollectionViewDelegate: class {
    func betweenCollectionView(collectionView: BetweenCollectionView, syncDataSource: [Any])
    @objc optional func betweenCollectionView(collectionView: BetweenCollectionView, didStartMoving itemAt:IndexPath)
    @objc optional func betweenCollectionView(collectionView: BetweenCollectionView, didEndMoving itemAt:IndexPath)
}

class BetweenCollectionView: UICollectionView {
    var isMovingCellAllowed: Bool = true {
        didSet {
            if isMovingCellAllowed == true {
                gestureRecognizerForMovingCells.isEnabled = true
            } else {
                gestureRecognizerForMovingCells.isEnabled = false
            }
        }
    }
    
    var movingCellIndexPath: IndexPath!
    var movingCellImageView: UIImageView!
    var movingCellTappedPoint: CGPoint!
    var movingCellFrom: BetweenCollectionView!
    var gestureRecognizerForMovingCells: UILongPressGestureRecognizer!
    
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
        gestureRecognizerForMovingCells = UILongPressGestureRecognizer(target: self, action: #selector(movingCell(_:)))
        gestureRecognizerForMovingCells.minimumPressDuration = 0.15
        self.addGestureRecognizer(gestureRecognizerForMovingCells)
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
            animatePickingUpCell(cell: cell!, point: point)
            betweenCollectionViewDelegate?.betweenCollectionView?(collectionView: self, didStartMoving: indexPath)
        case .changed:
            let pointInView = superview!.convert(point, from: self)
            movingCellImageView.frame = CGRect(origin: CGPoint(x:pointInView.x-movingCellTappedPoint.x*1.3 ,y:pointInView.y-movingCellTappedPoint.y*1.3), size: movingCellImageView.frame.size)
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
            var cell : UICollectionViewCell!
            if movingCellFrom == self {
                cell = self.cellForItem(at: movingCellIndexPath)
            } else {
                cell = pairCollectionView.cellForItem(at: movingCellIndexPath)
            }
            animatePuttingDownCells(cell: cell, collectionView:movingCellFrom)
            betweenCollectionViewDelegate?.betweenCollectionView?(collectionView: movingCellFrom, didEndMoving: movingCellIndexPath)
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
    
    func animatePickingUpCell(cell: UICollectionViewCell, point: CGPoint) {
        movingCellImageView = captureCells(cell: cell)!
        let pointInView = superview!.convert(point, from: self)
        movingCellTappedPoint = cell.convert(point, from: self)
        movingCellImageView.frame = CGRect(origin: CGPoint(x:pointInView.x-movingCellTappedPoint.x, y:pointInView.y-movingCellTappedPoint.y), size: movingCellImageView.frame.size)
        superview!.addSubview(movingCellImageView)
        cell.alpha = 0.0
        
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 4/5, animations: {
                self.movingCellImageView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            })
            UIView.addKeyframe(withRelativeStartTime: 4/5, relativeDuration: 1/5, animations: {
                self.movingCellImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            })
        }, completion: nil)
    }
    
    func animatePuttingDownCells(cell: UICollectionViewCell?, collectionView: BetweenCollectionView){
        var cellFrameInSuperView:CGRect?
        if cell == nil {
            cellFrameInSuperView = self.superview?.convert(CGRect(x:collectionView.contentSize.width, y:collectionView.contentSize.height, width:movingCellImageView.frame.width, height:movingCellImageView.frame.height), from: collectionView)
        } else {
            cellFrameInSuperView = self.superview?.convert((cell?.frame)!, from: collectionView)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.movingCellImageView.frame = cellFrameInSuperView!
            self.movingCellImageView.transform = CGAffineTransform.identity
        }) { (finished) in
            self.movingCellImageView.removeFromSuperview()
            self.movingCellImageView = nil
            cell?.alpha = 1.0
        }
    }
    
    func startWiggling(){
        let cells = self.visibleCells
        for cell in cells {
            guard cell.layer.animation(forKey: "wiggle") == nil else {return}
            guard cell.layer.animation(forKey: "bounce") == nil else {return}
            
            let angle = 0.04
            
            let wiggle = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            wiggle.values = [-angle, angle]
            wiggle.autoreverses = true
            wiggle.duration = randomInterval(0.1, variance: 0.025)
            wiggle.repeatCount = Float.infinity
            cell.layer.add(wiggle, forKey: "wiggle")
            
            let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
            bounce.values = [4.0, 0.0]
            bounce.autoreverses = true
            bounce.duration = randomInterval(0.12, variance: 0.025)
            bounce.repeatCount = Float.infinity
            cell.layer.add(bounce, forKey: "bounce")
        }
    }
    
    func stopWiggling(){
        let cells = self.visibleCells
        for cell in cells {
            cell.layer.removeAllAnimations()
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
    
    func randomInterval(_ interval: TimeInterval, variance: Double) -> TimeInterval {
        return interval + variance * Double((Double(arc4random_uniform(1000)) - 500.0) / 500.0)
    }
 
}
