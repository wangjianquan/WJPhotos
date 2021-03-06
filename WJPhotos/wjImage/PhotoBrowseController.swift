//
//  PhotoBrowseController.swift
//  WJPhotos
//
//  Created by ulinix on 2018-04-13.
//  Copyright © 2018 wjq. All rights reserved.
//

import UIKit

import Photos
import PhotosUI

class PhotoBrowseController: UICollectionViewController {

    var selectedAssets : [PHAsset] = []
    fileprivate let cachingImageManager = PHCachingImageManager()
    
    let scale = UIScreen.main.scale
    fileprivate var thumbnailSize: CGSize!

    //按钮的默认尺寸
    let collectionViewDefaultFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        super.init(collectionViewLayout: layout)
        
        layout.itemSize = (collectionView?.bounds.size)!
        collectionView.bounces = false
        collectionView?.isPagingEnabled = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
//        view.bounds.size.width += 20
        thumbnailSize = CGSize(width: view.bounds.size.width * scale, height: view.bounds.size.height * scale)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.frame = collectionViewDefaultFrame
        collectionView?.backgroundColor = UIColor.white


        self.collectionView!.register(PhotoBrowseImageCell.self, forCellWithReuseIdentifier: photoBrowseCell)
        self.collectionView?.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedAssets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoBrowseCell, for: indexPath) as! PhotoBrowseImageCell
    
        let asset = self.selectedAssets[indexPath.row]
        cell.representedAssetIdentifier = asset.localIdentifier
        cachingImageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, info) in
            if cell.representedAssetIdentifier == asset.localIdentifier && image != nil{
                cell.thumbnailImage = image
            }
        }
        
        return cell
    }
    
}

fileprivate let photoBrowseCell = "PhotoBrowseImageCell"

class PhotoBrowseImageCell: UICollectionViewCell {
    //显示缩略图
    lazy var  imageView: UIImageView = {
        let imageview = UIImageView(frame: .zero)
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFill
        return imageview
    }()
    
    var representedAssetIdentifier: String!

    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpUI()
    }
    
    fileprivate func setUpUI() {
        self.backgroundColor = UIColor.init(white: 0, alpha: 1)
        self.addSubview(imageView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 10, y: 0, width: contentView.frame.size.width - 20, height: contentView.frame.size.height)
    }
}





