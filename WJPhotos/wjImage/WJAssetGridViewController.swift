//
//  WJAssetGridViewController.swift
//  WJPhotos
//
//  Created by ulinix on 2018-04-11.
//  Copyright © 2018 wjq. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class WJAssetGridViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


class ImageCollectionViewCell: UICollectionViewCell {
    
    //显示缩略图
    @IBOutlet weak var imageView:UIImageView!
    //显示选中状态的图标
    @IBOutlet weak var selectedIcon:UIImageView!
    
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
    
}


