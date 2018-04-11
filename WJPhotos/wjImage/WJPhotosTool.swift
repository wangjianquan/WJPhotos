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
        let smartAlbums:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        return convertCollection(assetCollection: smartAlbums)
    }
    
    //MARK: -- 用户创建的相册
    public func fetchAllUserCreatedAlbum() -> [WJImageAlbumItem] {
        let topLevelUserCollections:PHFetchResult = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        return convertCollection(assetCollection: topLevelUserCollections as! PHFetchResult<PHAssetCollection>)
    }
    //转化处理获取到的相簿
    public func convertCollection(assetCollection:PHFetchResult<PHAssetCollection>) -> [WJImageAlbumItem] {
        let fetchOptions: PHFetchOptions = requestPHFetchOptions(MediaType.image)
        
        for i in 0..<assetCollection.count{
            let collection = assetCollection[i]
            if collection.isKind(of: PHAssetCollection.classForCoder()) {
                //赋值
                let assetCollection = collection
                //从每一个智能相册获取到的PHFetchResult中包含的才是真正的资源(PHAsset)
                let assetsFetchResults = requestFetchAssets(assetCollection, fetchOptions)
                if assetsFetchResults.count > 0 {
                    items.append(WJImageAlbumItem(title: assetCollection.localizedTitle, fetchResult: assetsFetchResults))
                }
            }
        }
        return items
    }

    
    
    
    public func requestFetchAssets(_ assetCollection: PHAssetCollection, _ options: PHFetchOptions?) -> PHFetchResult<PHAsset> {
        let assetsFetchResults:PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
        return assetsFetchResults
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
