//
//  CompleteButton.swift
//  WJPhotos
//
//  Created by ulinix on 2018-04-13.
//  Copyright © 2018 wjq. All rights reserved.
//

import UIKit
import Photos

let screen_width = UIScreen.main.bounds.size.width

class CompleteButton: UIView {
    //MARK: -- "预览"按钮
//    lazy var previewLabel: UILabel = {
//        let previewLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 66, height: self.frame.size.height))
//        previewLabel.text = "预览"
//        previewLabel.textAlignment = .center
//        previewLabel.font = UIFont.systemFont(ofSize: 15)
//        previewLabel.textColor = titleColor
//        previewLabel.backgroundColor = UIColor.blue
//        return previewLabel
//    }()

    lazy var previewBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 66, height: self.frame.size.height))
        btn.setTitle("预览", for: .normal)
        btn.setTitleColor(UIColor.darkGray, for: .normal)
        btn.titleLabel?.textAlignment = .center
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return btn
    }()
    
   
    //MARK: -- 按钮标题标签“完成”
    lazy var titleLabel: UILabel = {
       let titleLabel = UILabel(frame:CGRect(x: self.frame.size.width - 66 , y: 0, width: 66,
                                          height: self.frame.size.height))
        titleLabel.text = "完成"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = titleColor
        
        return titleLabel
    }()
    //MARK: -- 已选照片数量标签
    lazy var numLabel: UILabel = {
        let numLabel = UILabel(frame:CGRect(x: self.titleLabel.frame.origin.x - 20 , y: (self.frame.size.height - 20)/2 , width: 20, height: 20))
        numLabel.backgroundColor = titleColor
        numLabel.layer.cornerRadius = 10
        numLabel.layer.masksToBounds = true
        numLabel.textAlignment = .center
        numLabel.font = UIFont.systemFont(ofSize: 15)
        numLabel.textColor = UIColor.white
        numLabel.isHidden = true
        return numLabel
    }()
   
    //按钮的默认尺寸
    let defaultFrame = CGRect(x:0, y:0, width:70, height:20)
    
    //文字颜色（同时也是数字背景颜色）
    let titleColor = UIColor(red: 0x09/255, green: 0xbb/255, blue: 0x07/255, alpha: 1)
    
    //点击点击手势
    var tapFinishSingle:UITapGestureRecognizer?
    
    //设置数量
    var num:Int = 0{
        didSet{
            if num == 0{
                numLabel.isHidden = true
            }else{
                numLabel.isHidden = false
                numLabel.text = "\(num)"
                playAnimate()
            }
        }
    }
    
    //是否可用
    var isEnabled:Bool = true {
        didSet{
            if isEnabled {
                
                tapFinishSingle?.isEnabled = true
                titleLabel.textColor = titleColor
//                previewLabel.textColor = UIColor.titleColor
                previewBtn.titleLabel?.textColor = titleColor
            }else{
//                tapFinishSingle?.isEnabled = false
                titleLabel.textColor = UIColor.darkGray
//                previewLabel.textColor = UIColor.darkGray
                previewBtn.titleLabel?.textColor = UIColor.darkGray
                
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.groupTableViewBackground

        self.addSubview(previewBtn)
        self.addSubview(titleLabel)
        self.addSubview(numLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //用户数字改变时播放的动画
    func playAnimate() {
        //从小变大，且有弹性效果
        self.numLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5, options: UIViewAnimationOptions(),
                       animations: {
                        self.numLabel.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    //添加事件响应
    func addTarget(target: Any?, action: Selector?) {
        //单击监听
        tapFinishSingle = UITapGestureRecognizer(target:target,action:action)
        tapFinishSingle!.numberOfTapsRequired = 1
        tapFinishSingle!.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapFinishSingle!)
    }
    
}
