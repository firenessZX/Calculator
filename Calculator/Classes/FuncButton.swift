//
//  FuncButton.swift
//  Calculator
//
//  Created by 云联 on 2026/5/7.
//

import UIKit

class FuncButton: UIButton {

    init() {
        super.init(frame: .zero)
        //为按钮添加边框
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(red:219/255,green: 219/255,blue: 219/255,alpha: 1).cgColor
        //设置字体与字体颜色
        setTitleColor(.orange, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 25)
        setTitleColor(.black, for: .highlighted)
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
