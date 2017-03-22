//
//  ViewController.swift
//  Hybird(UIWebView&WKWebView)
//
//  Created by 安然 on 17/3/22.
//  Copyright © 2017年 安然. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func WKWebViewAction(_ sender: UIButton) {
        let controller = ARAWebViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func UIWebViewAction(_ sender: UIButton) {
        let controller = ARAWKWebViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = "主页"
        let str = "这个例子只适用于简单的,JS与Native的交互,要是更加复杂的就要使用其他的第三方,这个在之后的学习中我会继续写一些心得,供给大家参考;如果你喜欢的话,就给个星星✨吧"
        let range = (str as NSString).range(of: "简单的,JS与Native的交互,要是更加复杂的就要使用其他的第三方")
        let attributeString = NSMutableAttributedString(string:str)
        attributeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red,range: range)
        contentLabel.attributedText = attributeString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

