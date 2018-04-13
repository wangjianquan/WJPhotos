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
        
        
        _ = presentImagePicker(maxSelected: 3, completeHandler: { (assets) in
            print("共选择了\(assets.count)张图片，分别如下：")
            for asset in assets {
                print(asset)
            }
        })
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


