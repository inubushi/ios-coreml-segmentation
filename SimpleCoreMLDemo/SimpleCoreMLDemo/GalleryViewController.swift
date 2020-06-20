//
//  GalleryViewController.swift
//  SimpleCoreMLDemo
//
//  Created by Chamin Morikawa on 2020/05/18.
//  Copyright © 2020 Chamin Morikawa. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var colViewSamples: UICollectionView!
    var selectedPhoto:UIImage!
    
    var sampleList:[String] = []
    
    override func viewDidLoad() {
        // load image filenames
        sampleList.append("leopard.jpg")
        sampleList.append("lion.jpg")
        sampleList.append("siamese_cat.jpg")
        sampleList.append("tabby_cat.jpg")
        
        // done
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // load photos
        colViewSamples.reloadData()
    }
    
    //MARK: Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sampleList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // for each cell, load an image lited in the array
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPhoto", for: indexPath)
        let imgViewPhoto: UIImageView = cell.viewWithTag(100) as! UIImageView
        imgViewPhoto.image = UIImage.init(named: sampleList[indexPath.row])
        imgViewPhoto.contentMode = .scaleAspectFill
        return cell
    }
    
    // when a photo is selected, go back with it
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // set image
        selectedPhoto = UIImage.init(named: sampleList[indexPath.row])
        
        // set photo at parent
        let parentVC = self.navigationController?.viewControllers[0] as! ViewController
        parentVC.setSelectedPhoto(img: selectedPhoto)
        
        // go back
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destController: ViewController = segue.destination as! ViewController
        destController.setSelectedPhoto(img: self.selectedPhoto)
    }
    
   // that's all, folks!
}
