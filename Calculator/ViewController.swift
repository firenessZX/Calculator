//
//  ViewController.swift
//  Calculator
//
//  Created by 云联 on 2026/5/7.
//

import UIKit
import SnapKit
class ViewController: UIViewController,KeyBoardInputDelegate {
    
     let keyBoard = KeyBoardView()
     let screen = ScreenBoardView()
    let calculator = CalculatorEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        keyBoard.delegate = self
        view.addSubview(keyBoard)
        view.addSubview(screen)
        keyBoard.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(view.snp.height).multipliedBy(2.0 / 3.0)
        }
        
        screen.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(keyBoard.snp.top)
        }
        
    }
    
    
    func boardInputClick(content: String) {
        //如果是这些功能按钮，则进行功能逻辑处理
        if content == "AC" || content == "Del" || content == "=" {
            switch content {
            case "AC":
                screen.reloadHistory()
                screen.clearContent()
            case "Del":
                screen.deleteInput()
            case "=":
                let result = calculator.caculatEquation(equation: screen.inputString)
                screen.reloadHistory()
                screen.clearContent()
                screen.inputContent(content: String(result))
            default: break
                
            }
        
            
        }else {
            screen.inputContent(content: content)
        }
        
    }

    

}
