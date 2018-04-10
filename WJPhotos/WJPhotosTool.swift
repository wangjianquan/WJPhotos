//
//  WJPhotosTool.swift
//  WJPhotos
//
//  Created by ulinix on 2018-04-09.
//  Copyright © 2018 wjq. All rights reserved.
//

import UIKit
import PhotosUI
import Photos

//相簿列表项
struct WJImageAlbumItem {
    //相簿名称
    var title:String?
    //相簿内的资源
    var fetchResult:PHFetchResult<PHAsset>
}

public enum MediaType : Int {
    case unknown
    case image
    case video
    case audio
}

class WJPhotosTool: NSObject {
    
    static let instance = WJPhotosTool()
    
//    var allPhotos: PHFetchResult<PHAsset>!
    var smartAlbums: PHFetchResult<PHAssetCollection>!
    var userCollections: PHFetchResult<PHCollection>!
    
    //相簿列表项集合
    fileprivate var items:[WJImageAlbumItem] = []
    
    //MARK: -- 获取所有照片
    public func getAllSourceCollection() -> PHFetchResult<PHAsset> {
        let fetchOptions: PHFetchOptions = requestPHFetchOptions(nil)
        let allPhotos = PHAsset.fetchAssets(with: fetchOptions)
        return allPhotos
    }
    
    //MARK: -- 智能相册列表
    public func fetchAllSystemAblum() -> [WJImageAlbumItem] {
        let fetchOptions: PHFetchOptions = requestPHFetchOptions(MediaType.image)
        
        let smartAlbums:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        //smartAlbums中保存的是各个智能相册对应的PHAssetCollection
        for i in 0..<smartAlbums.count {
            //获取一个相册(PHAssetCollection)
            let collection = smartAlbums[i]
            if collection.isKind(of: PHAssetCollection.classForCoder()) {
                //赋值
                let assetCollection = collection
                //从每一个智能相册获取到的PHFetchResult中包含的才是真正的资源(PHAsset)
                let assetsFetchResults:PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
                assetsFetchResults.enumerateObjects({ (asset, i, nil) in })
                if assetsFetchResults.count > 0 {
                    items.append(WJImageAlbumItem(title: assetCollection.localizedTitle, fetchResult: assetsFetchResults))
                }
            }
        }
        return items
    }
    
    //MARK: -- 用户创建的相册
    public func fetchAllUserCreatedAlbum() -> [WJImageAlbumItem] {
        let fetchOptions: PHFetchOptions = requestPHFetchOptions(MediaType.image)
        
        let topLevelUserCollections:PHFetchResult = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        for i in 0...topLevelUserCollections.count {
            //获取一个相册(PHAssetCollection)
            let collection = topLevelUserCollections[i]
            if collection.isKind(of: PHAssetCollection.classForCoder()) {
                //类型强制转换
                let assetCollection = collection as! PHAssetCollection
                //从每一个智能相册中获取到的PHFetchResult中包含的才是真正的资源(PHAsset)
                let assetsFetchResults:PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
                assetsFetchResults.enumerateObjects({ (asset, i, nil) in })
                if assetsFetchResults.count > 0 {
                    items.append(WJImageAlbumItem(title: assetCollection.localizedTitle, fetchResult: assetsFetchResults))
                }
            }
        }
        return items
    }
    
   
    //MARK: -- 筛选条件
    public func requestPHFetchOptions(_ mediaType: MediaType?) -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        switch mediaType {
        case MediaType.unknown?:
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.unknown.rawValue)
        case MediaType.video?:
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        case MediaType.audio?:
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.audio.rawValue)
        default:
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        }
        return fetchOptions
    }
    

}
