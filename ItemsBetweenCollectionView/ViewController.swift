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

class ViewController: UIViewController {
    @IBOutlet weak var collectionViewA: BetweenCollectionView!
    @IBOutlet weak var collectionViewB: BetweenCollectionView!
    var dataA = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    var dataB = [21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionViewA.collectionViewDataSource = dataA
        collectionViewB.collectionViewDataSource = dataB
        
        collectionViewA.pairCollectionView = collectionViewB
        collectionViewB.pairCollectionView = collectionViewA
        
        collectionViewA.betweenCollectionViewDelegate = self
        collectionViewB.betweenCollectionViewDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ViewController:UICollectionViewDelegate {

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

extension ViewController:BetweenCollectionViewDelegate {
    func betweenCollectionView(collectionView: BetweenCollectionView, syncDataSource: [Any]) {
        if collectionView == collectionViewA {
            dataA = syncDataSource as! [Int]
        } else {
            dataB = syncDataSource as! [Int]
        }
    }
}

