//
//  ViewController.swift
//  WJPhotos
//
//  Created by ulinix on 2018-04-09.
//  Copyright © 2018 wjq. All rights reserved.
//

import UIKit
import PhotosUI
import Photos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    @IBAction func action(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "WJPhotos", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "imagePickerVC")
            as? WJPhotosList{
            //                //设置选择完毕后的回调
            //                vc.completeHandler = completeHandler
            //                //设置图片最多选择的数量
            //                vc.maxSelected = maxSelected
            //将图片选择视图控制器外添加个导航控制器，并显示
            //                let nav = UINavigationController(rootViewController: vc)
            self.present(vc, animated: true, completion: nil)
        }
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UIViewController {
    //HGImagePicker提供给外部调用的接口，同于显示图片选择页面
    func presentImagePicker(maxSelected:Int = Int.max,
                              completeHandler:((_ assets:[PHAsset])->())?)
        -> WJPhotosList?{
            //获取图片选择视图控制器
            if let vc = UIStoryboard(name: "WJPhotos", bundle: Bundle.main)
                .instantiateViewController(withIdentifier: "imagePickerVC")
                as? WJPhotosList{
//                //设置选择完毕后的回调
//                vc.completeHandler = completeHandler
//                //设置图片最多选择的数量
//                vc.maxSelected = maxSelected
                //将图片选择视图控制器外添加个导航控制器，并显示
//                let nav = UINavigationController(rootViewController: vc)
                self.present(vc, animated: true, completion: nil)
                return vc
            }
            return nil
    }
}
