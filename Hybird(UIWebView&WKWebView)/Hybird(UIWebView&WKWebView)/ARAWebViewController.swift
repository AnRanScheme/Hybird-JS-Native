//
//  ARAWebViewController.swift
//  Hybird(UIWebView&WKWebView)
//
//  Created by 安然 on 17/3/22.
//  Copyright © 2017年 安然. All rights reserved.
//

import UIKit

class ARAWebViewController: UIViewController {
    
    lazy var webView: UIWebView = {[unowned self] in
        let view     = UIWebView(frame: self.view.bounds)
        let htmlURL  = Bundle.main.url(forResource: "anran.html", withExtension: nil)
        let request  = URLRequest(url: htmlURL!)
        let request1 =  URLRequest(url: URL(string: "https://www.baidu.com")!)
        view.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        view.loadRequest(request)
        view.scrollView.bounces = false
        view.delegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIWebView"
        view.addSubview(webView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("\(self.debugDescription) --- 销毁")
    }

    
    // MARK: - 处理URL然后调用方法
    func handleCustomAction(url: URL) {
        
        let host = url.host
        
        if host == "scanClick" {
        
        } else if host == "shareClick" {
            share(url: url)
        } else if host == "getLocation" {
            getLocation()
        } else if host == "setColor" {
            ChangeColor(url: url)
        } else if host == "payAction" {
            payAction(url: url)
        } else if host == "shake" {
            sharedAction()
        } else if host == "back" {
            goBack()
        }
        
    }
    
    
    func getLocation() {
        let jsStr = "setLocation('\("杭州市拱墅区下沙中国计量学院")')"
        webView.stringByEvaluatingJavaScript(from: jsStr)
    }
    
    func share(url: URL) {
       
        guard let params = url.query?.components(separatedBy: "&") else { return }
       
        var tempDic = [String:Any]()
        for paramStr in params {
            let dicArray = paramStr.components(separatedBy: "=")
            if dicArray.count > 1 {
                guard let str = dicArray[1].removingPercentEncoding else { return }
                tempDic[dicArray[0]] = str
            }
        }
    
        let title = tempDic["title"]
        let content = tempDic["content"]
        let url = tempDic["url"]

        let jsStr = "shareResult('\(title ?? "")','\(content ?? "")','\(url ?? "")')"
        
        webView.stringByEvaluatingJavaScript(from: jsStr)
    }
    
    
    func ChangeColor(url: URL) {
        guard let params = url.query?.components(separatedBy: "&") else { return }
        
        var tempDic = [String:Any]()
        for paramStr in params {
            let dicArray = paramStr.components(separatedBy: "=")
            if dicArray.count > 1 {
                guard let str = dicArray[1].removingPercentEncoding else { return }
                tempDic[dicArray[0]] = str
                print("\(str)")
            }
        }
        let r = (tempDic["r"] as! NSString).floatValue
        let g = (tempDic["g"] as! NSString).floatValue
        let b = (tempDic["b"] as! NSString).floatValue
        let a = (tempDic["a"] as! NSString).floatValue
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.backgroundColor = UIColor(colorLiteralRed: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    func payAction(url: URL) {
        guard let params = url.query?.components(separatedBy: "&") else { return }
        
        var tempDic = [String:Any]()
        for paramStr in params {
            let dicArray = paramStr.components(separatedBy: "=")
            if dicArray.count > 1 {
                guard let str = dicArray[1].removingPercentEncoding else { return }
                tempDic[dicArray[0]] = str
            }
        }
        
        let jsStr = "payResult('支付成功',\(1))"
        
        webView.stringByEvaluatingJavaScript(from: jsStr)
    }
    
    func sharedAction() {
        print("分享")
    }
    
    func goBack() {
        webView.goBack()
    }

}

extension ARAWebViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let url = request.url
        let scheme = url?.scheme
        
        if let URL = url, scheme == "anranaction" {
            self.handleCustomAction(url: URL)
            return false
        }
        
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webView加载完成然后调用")
    }
    
}
