//
//  WJAssetGridViewController.swift
//  WJPhotos
//
//  Created by ulinix on 2018-04-11.
//  Copyright © 2018 wjq. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}


class WJAssetGridViewController: UICollectionViewController {

    
    var fetchResult: PHFetchResult<PHAsset>!
    
    fileprivate let cachingImageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero

    lazy var selectedAssets: [PHAsset] = []

    //每次最多可选择的照片数量
    var maxSelected:Int = Int.max
    //照片选择完毕后的回调
    var completeHandler:((_ assets:[PHAsset])->())?
    
    //按钮的默认尺寸
    let collectionViewDefaultFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 44)
    
    //完成按钮
    lazy var completeButton: CompleteButton =  CompleteButton(frame: CGRect(x: 0, y: collectionViewDefaultFrame.height, width: screen_width, height: 44))
    
    
    
    
    init(){
        let viewWidth = UIScreen.main.bounds.size.width
        let desiredItemWidth: CGFloat = 100
        let columns: CGFloat = max(floor(viewWidth/desiredItemWidth), 4)
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)

        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = itemSize
        layout.minimumInteritemSpacing = padding
        layout.minimumLineSpacing = padding
        
        //从PHCachingImageManager请求的缩略图的大小。
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
        super.init(collectionViewLayout: layout )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        resetCachedAssets()
        collectionView?.frame = collectionViewDefaultFrame
        collectionView?.backgroundColor = UIColor.white
        collectionView?.allowsMultipleSelection = true // 多选
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        collectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        
        completeButton.addTarget(target: self, action: #selector(finishSelect))
        completeButton.isEnabled = false
        completeButton.previewBtn.addTarget(self, action: #selector(previewButtonClick), for: .touchUpInside)
        self.view.addSubview(completeButton)
        
        collectionView?.reloadData()
    }
    
    //取消按钮点击
    @objc func cancel() {
        //退出当前视图控制器
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //MARK: -- "浏览"按钮事件
    @objc func previewButtonClick()  {
       pushControllWithType(0)
    }
    
    //MARK: -- "完成"按钮事件
    @objc func finishSelect() {
        pushControllWithType()
    }
   
    fileprivate func pushControllWithType(_ type: NSInteger? = nil ) {
        //已选图片资源
        if let indexPatchs = collectionView?.indexPathsForSelectedItems {
            for index in indexPatchs {
                selectedAssets.append(fetchResult[index.row])
            }
        }
        if selectedAssets.count == 0 {
            presentAlert()
        }else{
            
            if type == 0 { //
                print("图片浏览")
                let controll = PhotoBrowseController()
                controll.selectedAssets = selectedAssets
                navigationController?.pushViewController(controll, animated: true)
            } else {
                self.navigationController?.dismiss(animated: true, completion: {
                    self.completeHandler!(self.selectedAssets)
                })
            }
        }
    }
    
    fileprivate func presentAlert() {
        let alert = UIAlertController(title: "请选择照片", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "我知道了", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }

    // MARK: Asset Caching (缓存)
    fileprivate func resetCachedAssets() {
        cachingImageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        //只有当视图可见时才更新
        guard isViewLoaded && view.window != nil else { return }
        
        //预加载窗口是可见矩形的两倍高。
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        //仅当可见区域与最后一个预热区域有显著差异时才更新。
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        cachingImageManager.startCachingImages(for: addedAssets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        cachingImageManager.stopCachingImages(for: removedAssets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        previousPreheatRect = preheatRect
        
        
        
    }
    
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }

}

extension WJAssetGridViewController {
    
    //获取已选择个数
    func selectedCount() -> Int {
        return collectionView!.indexPathsForSelectedItems?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! ImageCollectionViewCell
        
        let asset = fetchResult[indexPath.row]
        
        cell.representedAssetIdentifier = asset.localIdentifier
        cachingImageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, info) in
            if cell.representedAssetIdentifier == asset.localIdentifier && image != nil{
                cell.thumbnailImage = image
            }
        }
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            //获取选中的数量
            let count = selectedCount()
            
            if count > maxSelected {
                //设置为不选中状态
                collectionView.deselectItem(at: indexPath, animated: false)
                //弹出提示
                let title = "你最多只能选择\(self.maxSelected)张照片"
                let alertController = UIAlertController(title: title, message: nil,
                                                        preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title:"我知道了", style: .cancel,
                                                 handler:nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                
                completeButton.num = count
                if count > 0 && !self.completeButton.isEnabled {
                    completeButton.isEnabled = true
                }
                 cell.playAnimate()
            }
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath)
            as? ImageCollectionViewCell{
            //获取选中的数量
            let count = self.selectedCount()
            completeButton.num = count
            //改变完成按钮数字，并播放动画
            if count == 0{
                completeButton.isEnabled = false
            }
            cell.playAnimate()
        }
    }
    
    
}



let collectionCell = "ImageCollectionViewCell"
class ImageCollectionViewCell: UICollectionViewCell {
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    //显示缩略图
    lazy var  imageView: UIImageView = {
        let imageview = UIImageView(frame: contentView.bounds)
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFill
        return imageview
    }()
    
    //显示选中状态的图标
   fileprivate lazy var selectedIcon:UIImageView = {
        let imageview = UIImageView(frame: CGRect(x: contentView.bounds.width-30, y: 0, width: 30, height: 30))
        imageview.image = UIImage(named: "hg_image_not_selected")
        return imageview
    }()
    
    override var isSelected: Bool{
        didSet{
            if isSelected {
                selectedIcon.image = UIImage(named: "hg_image_selected")
            }else{
                selectedIcon.image = UIImage(named: "hg_image_not_selected")
            }
        }
    }
    
    //播放动画，是否选中的图标改变时使用
    func playAnimate() {
        //图标先缩小，再放大
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2,
                                                       animations: {
                                                        self.selectedIcon.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4,
                                                       animations: {
                                                        self.selectedIcon.transform = CGAffineTransform.identity
                                    })
        }, completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame:CGRect){
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI()  {
        self.addSubview(imageView)
        imageView.addSubview(selectedIcon)
    }
    
}


