//
//  KeyBoardView.swift
//  Calculator
//
//  Created by 云联 on 2026/5/7.
//

import UIKit
import SnapKit

protocol KeyBoardInputDelegate {
    func boardInputClick(content: String)
}

class KeyBoardView: UIView {
    
    var delegate: KeyBoardInputDelegate?
    
    //首先在这个类中提供一个数组属性，用于存放操作面板上所有功能按钮的标题
    var dataArray = ["0",".","%","=",
                     "1","2","3","+",
                     "4","5","6","-",
                     "7","8","9","*",
                     "AC","Del","^","/"
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        installUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func installUI() {
        //创建一个变量，用于保存当前布局按钮的上一个按钮
        var previousButton:FuncButton!
        //进行功能按钮的循环创建
        for index in 0..<dataArray.count {
            //创建一个功能按钮
            let btn = FuncButton()
            
            self .addSubview(btn)
            
            //添加约束
            btn.snp.makeConstraints { make in
                //当按钮为每一行的第一个时，父视图左侧摆放
                if index % 4 == 0 {
                    make.left.equalTo(0)
                    
                }else {
                    //否则将按钮的左边靠其上一个按钮的右侧摆放
                    make.left.equalTo(previousButton.snp.right)
                }
                //当按钮为第一行时，将其靠父视图底部摆放
                if index/4 == 0 {
                    make.bottom.equalTo(self)
                }else if index % 4 == 0{
                    //当按钮不在第一行且为每行第一个时，将其底部与上一个按钮的顶部对齐
                    make.bottom.equalTo(previousButton.snp.top)
                }else {
                    //否则将其底部与上一个按钮的底部对齐
                    make.bottom.equalTo(previousButton.snp.bottom)
                }
                //约束宽度为俯视图宽度的0.25倍
                make.width.equalTo(self.snp.width).multipliedBy(0.25)
                //约束高度为父视图宽度的0.2倍
                make.height.equalTo(self.snp.height).multipliedBy(0.2)
            }
            
            //标记一个tag
            btn.tag = index + 100
            
            //添加点击事件
            btn.addTarget(self, action: #selector(handlerButtonAction), for: .touchUpInside)
            
            btn.setTitle(dataArray[index], for: .normal)
            
            //对上一个按钮进行更新保存
            previousButton = btn
            
        }
        
    }
    
    @objc func handlerButtonAction(_ button: FuncButton) {
        
        delegate?.boardInputClick(content: button.currentTitle!)
        
    }

}
