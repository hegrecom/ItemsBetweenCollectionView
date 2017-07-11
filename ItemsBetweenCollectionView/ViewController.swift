//
//  ViewController.swift
//  ItemsBetweenCollectionView
//
//  Created by TKang on 2017. 7. 11..
//  Copyright © 2017년 Practice. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    var label: UILabel!
    var tapPoint: CGPoint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    func customInit(){
        label = UILabel()
        label.frame = self.bounds
        label.textAlignment = .center
        self.contentView.addSubview(label)
    }
}

enum CellOrientation {
    case A, B
}

class ViewController: UIViewController {
    @IBOutlet weak var collectionViewA: UICollectionView!
    @IBOutlet weak var collectionViewB: UICollectionView!
    var dataA = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    var dataB = [21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]
    override var prefersStatusBarHidden: Bool {
        return true
    }
    var movingCellIndexPath: IndexPath!
    var movingCellImageView: UIImageView!
    var movingCellTappedPoint: CGPoint!
    var movingCellFrom: CellOrientation!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let panGestureForA = UILongPressGestureRecognizer(target: self, action: #selector(moveItemsFromA(_:)))
        panGestureForA.minimumPressDuration = 0.2
        collectionViewA.addGestureRecognizer(panGestureForA)
        let panGestureForB = UILongPressGestureRecognizer(target: self, action: #selector(moveItemsFromB(_:)))
        panGestureForB.minimumPressDuration = 0.2
        collectionViewB.addGestureRecognizer(panGestureForB)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ViewController:UICollectionViewDelegate {
    func moveItemsFromA(_ gesture: UILongPressGestureRecognizer){
        let point = gesture.location(in: gesture.view)
        switch gesture.state{
        case .began:
            guard let indexPath = collectionViewA.indexPathForItem(at: point) else {return}
            movingCellIndexPath = indexPath
            movingCellFrom = .A
            let cell = collectionViewA.cellForItem(at: indexPath)
            movingCellImageView = captureCells(cell: cell)!
            movingCellImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            let pointInView = self.view.convert(point, from: collectionViewA)
            movingCellTappedPoint = cell?.convert(point, from: collectionViewA)
            movingCellImageView.frame = CGRect(origin: CGPoint(x:pointInView.x-movingCellTappedPoint.x, y:pointInView.y-movingCellTappedPoint.y), size: movingCellImageView.frame.size)
            self.view.addSubview(movingCellImageView)
            cell?.alpha = 0.0
        case .changed:
            let pointInView = self.view.convert(point, from: collectionViewA)
            movingCellImageView.frame = CGRect(origin: CGPoint(x:pointInView.x-movingCellTappedPoint.x ,y:pointInView.y-movingCellTappedPoint.y), size: movingCellImageView.frame.size)
            if collectionViewA.frame.contains(pointInView) {
                let destIndexPath = collectionViewA.indexPathForItem(at: point)
                if destIndexPath != nil {
                    if movingCellFrom == .A {
                        dataA.insert(dataA.remove(at: movingCellIndexPath.row), at: destIndexPath!.row)
                        collectionViewA.moveItem(at: movingCellIndexPath, to: destIndexPath!)
                        movingCellIndexPath = destIndexPath
                        let cell = collectionViewA.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    } else {
                        let data = dataB.remove(at: movingCellIndexPath.row)
                        collectionViewB.deleteItems(at: [movingCellIndexPath])
                        dataA.insert(data, at: destIndexPath!.row)
                        collectionViewA.insertItems(at: [destIndexPath!])
                        movingCellIndexPath = destIndexPath
                        movingCellFrom = .A
                        let cell = collectionViewA.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    }
                }
            } else if collectionViewB.frame.contains(pointInView) {
                let pointInB = collectionViewA.convert(point, to: collectionViewB)
                let destIndexPath = collectionViewB.indexPathForItem(at: pointInB)
                if destIndexPath != nil {
                    if movingCellFrom == .A {
                        let data = dataA.remove(at: movingCellIndexPath.row)
                        collectionViewA.deleteItems(at: [movingCellIndexPath])
                        dataB.insert(data, at: destIndexPath!.row)
                        collectionViewB.insertItems(at: [destIndexPath!])
                        movingCellIndexPath = destIndexPath
                        movingCellFrom = .B
                        let cell = collectionViewB.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    } else {
                        dataB.insert(dataB.remove(at: movingCellIndexPath.row), at: destIndexPath!.row)
                        collectionViewB.moveItem(at: movingCellIndexPath, to: destIndexPath!)
                        movingCellIndexPath = destIndexPath
                        let cell = collectionViewB.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    }
                }
            }
        case .ended:
            movingCellImageView.removeFromSuperview()
            if movingCellFrom == .A {
                let cell = collectionViewA.cellForItem(at: movingCellIndexPath)
                cell?.alpha = 1.0
            } else {
                let cell = collectionViewB.cellForItem(at: movingCellIndexPath)
                cell?.alpha = 1.0
            }
        default:
            movingCellImageView.removeFromSuperview()
            if movingCellFrom == .A {
                let cell = collectionViewA.cellForItem(at: movingCellIndexPath)
                cell?.alpha = 1.0
            } else {
                let cell = collectionViewB.cellForItem(at: movingCellIndexPath)
                cell?.alpha = 1.0
            }
        }
    }
    
    func moveItemsFromB(_ gesture: UIPanGestureRecognizer){
        let point = gesture.location(in: gesture.view)
        switch gesture.state{
        case .began:
            guard let indexPath = collectionViewB.indexPathForItem(at: point) else {return}
            movingCellIndexPath = indexPath
            movingCellFrom = .B
            let cell = collectionViewB.cellForItem(at: indexPath)
            movingCellImageView = captureCells(cell: cell)!
            movingCellImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            let pointInView = self.view.convert(point, from: collectionViewB)
            movingCellTappedPoint = cell?.convert(point, from: collectionViewB)
            movingCellImageView.frame = CGRect(origin: CGPoint(x:pointInView.x-movingCellTappedPoint.x, y:pointInView.y-movingCellTappedPoint.y), size: movingCellImageView.frame.size)
            self.view.addSubview(movingCellImageView)
            cell?.alpha = 0.0
        case .changed:
            let pointInView = self.view.convert(point, from: collectionViewB)
            movingCellImageView.frame = CGRect(origin: CGPoint(x:pointInView.x-movingCellTappedPoint.x ,y:pointInView.y-movingCellTappedPoint.y), size: movingCellImageView.frame.size)
            if collectionViewB.frame.contains(pointInView) {
                let destIndexPath = collectionViewB.indexPathForItem(at: point)
                
                if destIndexPath != nil {
                    if movingCellFrom == .B {
                        dataB.insert(dataB.remove(at: movingCellIndexPath.row), at: destIndexPath!.row)
                        collectionViewB.moveItem(at: movingCellIndexPath, to: destIndexPath!)
                        movingCellIndexPath = destIndexPath
                        let cell = collectionViewB.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    } else {
                        let data = dataA.remove(at: movingCellIndexPath.row)
                        collectionViewA.deleteItems(at: [movingCellIndexPath])
                        dataB.insert(data, at: destIndexPath!.row)
                        collectionViewB.insertItems(at: [destIndexPath!])
                        movingCellIndexPath = destIndexPath
                        movingCellFrom = .B
                        let cell = collectionViewB.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    }
                }
            } else if collectionViewA.frame.contains(pointInView) {
                let pointInA = collectionViewB.convert(point, to: collectionViewA)
                let destIndexPath = collectionViewA.indexPathForItem(at: pointInA)
                if destIndexPath != nil {
                    if movingCellFrom == .B {
                        let data = dataB.remove(at: movingCellIndexPath.row)
                        collectionViewB.deleteItems(at: [movingCellIndexPath])
                        dataA.insert(data, at: destIndexPath!.row)
                        collectionViewA.insertItems(at: [destIndexPath!])
                        movingCellIndexPath = destIndexPath
                        movingCellFrom = .A
                        let cell = collectionViewB.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    } else {
                        dataA.insert(dataA.remove(at: movingCellIndexPath.row), at: destIndexPath!.row)
                        collectionViewA.moveItem(at: movingCellIndexPath, to: destIndexPath!)
                        movingCellIndexPath = destIndexPath
                        let cell = collectionViewA.cellForItem(at: movingCellIndexPath)
                        cell?.alpha = 0.0
                    }
                }
            }
        case .ended:
            movingCellImageView.removeFromSuperview()
            if movingCellFrom == .B {
                let cell = collectionViewB.cellForItem(at: movingCellIndexPath)
                cell?.alpha = 1.0
            } else {
                let cell = collectionViewA.cellForItem(at: movingCellIndexPath)
                cell?.alpha = 1.0
            }
        default:
            movingCellImageView.removeFromSuperview()
            if movingCellFrom == .B {
                let cell = collectionViewB.cellForItem(at: movingCellIndexPath)
                cell?.alpha = 1.0
            } else {
                let cell = collectionViewA.cellForItem(at: movingCellIndexPath)
                cell?.alpha = 1.0
            }
        }
    }
    
    func captureCells(cell: UICollectionViewCell?) -> UIImageView? {
        guard cell != nil else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(cell!.frame.size, true, 0)
        cell!.drawHierarchy(in: cell!.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = cell!.frame
        
        return imageView
    }
}


extension ViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewA {
            return dataA.count
        } else {
            return dataB.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewA {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellA", for: indexPath) as! CollectionViewCell
            cell.backgroundColor = UIColor.black
            cell.label.text = dataA[indexPath.row].description
            cell.label.textColor = UIColor.white
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellB", for: indexPath) as! CollectionViewCell
            cell.backgroundColor = UIColor.white
            cell.label.textColor = UIColor.black
            cell.label.text = dataB[indexPath.row].description
            return cell
        }
    }
}

