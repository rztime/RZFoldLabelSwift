//
//  ViewController.swift
//  RZFoldLabelSwift
//
//  Created by rztime on 2020/6/20.
//  Copyright © 2020 rztime. All rights reserved.
//

import UIKit
import SnapKit
import RZColorfulSwift

class ViewController: UIViewController {

    private let textLabel = RZFoldLabel.init()
    
    private let textFont = UIFont.systemFont(ofSize: 17)
    
    private let textColor = UIColor.init(white: 0.1, alpha: 0.8)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(textLabel)
        
        textLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(20)
            make.center.equalToSuperview()
        }
        textLabel.backgroundColor = .gray
        textLabel.numberOfLines = 3
        textLabel.preferredMaxLayoutWidth = self.view.frame.size.width - 40
        
        
        textLabel.showAllText = NSAttributedString.rz_colorfulConfer(confer: {
            $0.text("...")?.font(textFont).textColor(textColor)
            $0.text("全文")?.font(textFont).textColor(.red).tapAction("show")
        })
        
        textLabel.foldText = NSAttributedString.rz_colorfulConfer(confer: {
            $0.text("...")?.font(textFont).textColor(textColor)
            $0.text("收起")?.font(textFont).textColor(.red).tapAction("close")
        })
        
        textLabel.rzDidTapView = {(tap, label) in
            switch tap {
                case "show":
                    label?.isFold = false
                case "close":
                    label?.isFold = true
                default:
                    break
            }
        }
        
        textLabel.attributedText = NSAttributedString.rz_colorfulConfer(confer: {
            $0.text("文本文本文本12312文本文本文本12312文本文本文本12312文本文本文本12312文本文本文本12312文本文本文本12312文本文本文本12312文本文本文本12312文本文本文本12312文本文本文本12312文本文本文本12312")?.textColor(textColor).font(textFont)
        })
    } 
}

