//
//  WJPhotosList.swift
//  WJPhotos
//
//  Created by ulinix on 2018-04-09.
//  Copyright © 2018 wjq. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class WJPhotosList: UITableViewController {
 
    lazy var photoTool = WJPhotosTool()
    var allPhotos: PHFetchResult<PHAsset>!
    var smartAlbums: PHFetchResult<PHAssetCollection>!
    var userCollections: PHFetchResult<PHCollection>!
    
    //每次最多可选择的照片数量
    var maxSelected:Int = Int.max
    //照片选择完毕后的回调
    var completeHandler:((_ assets:[PHAsset])->())?
    
    //相簿列表项集合
    var items:[WJImageAlbumItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.tableFooterView = UIView()
        
        let rightBarItem = UIBarButtonItem(title: "取消", style: .plain, target: self,
                                           action:#selector(cancel) )
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        PHPhotoLibrary.requestAuthorization { (status) in
            if status != .authorized {
                return
            }
            self.items = self.photoTool.fetchAllSystemAblum()
            self.items = self.photoTool.fetchAllUserCreatedAlbum()
            self.items.sort(by: { (item1, item2) -> Bool in
                return item1.fetchResult.count > item2.fetchResult.count
            })
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                let controll = WJAssetGridViewController()
                controll.title = self.items.first?.title
                controll.fetchResult = self.items.first?.fetchResult
                controll.maxSelected = self.maxSelected
                controll.completeHandler = self.completeHandler
                self.navigationController?.pushViewController(controll, animated: false)
            }
        }

        
    }
    
    @objc fileprivate func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let data = self.items[indexPath.row]
        cell.textLabel?.text = data.title! + " (\(data.fetchResult.count))"
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //获取选中的相簿信息
        let fetchResult = self.items[indexPath.row].fetchResult
        
        let layout = UICollectionViewFlowLayout()
        let controll = WJAssetGridViewController()
        
        controll.fetchResult = fetchResult
        controll.maxSelected = self.maxSelected
        controll.completeHandler = self.completeHandler
        self.navigationController?.pushViewController(controll, animated: false)
    }
}

extension UIViewController {
    //HGImagePicker提供给外部调用的接口，同于显示图片选择页面
    func presentImagePicker(maxSelected:Int = Int.max,
                            completeHandler:((_ assets:[PHAsset])->())?) -> WJPhotosList?{
        //获取图片选择视图控制器
        let vc = WJPhotosList()
        //设置选择完毕后的回调
        vc.completeHandler = completeHandler
        //设置图片最多选择的数量
        vc.maxSelected = maxSelected
        // 将图片选择视图控制器外添加个导航控制器，并显示
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
        return vc
    }
}


