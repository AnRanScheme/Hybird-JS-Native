//
//  ARAWKWebViewController.swift
//  Hybird(UIWebView&WKWebView)
//
//  Created by 安然 on 17/3/22.
//  Copyright © 2017年 安然. All rights reserved.
//

import UIKit
import WebKit

class ARAWKWebViewController: UIViewController {
    
    lazy var webView: WKWebView = {[unowned self] in
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.minimumFontSize = 30.0
        configuration.preferences = preferences
        let view = WKWebView(frame: self.view.frame, configuration: configuration)
        let urlStr = Bundle.main.path(forResource: "anran.html", ofType: nil)
        let fileURL = URL(fileURLWithPath: urlStr!)
        view.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
        view.navigationDelegate = self
        view.uiDelegate = self
        return view
    }()
    
    lazy var progressView: UIProgressView = {
        let view = UIProgressView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 2))
        view.backgroundColor = UIColor.blue
        view.trackTintColor = UIColor.lightGray
        view.tintColor = UIColor.red
        return view
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WKWebView"
        view.addSubview(webView)
        view.addSubview(progressView)
        webView.addObserver(self,
                            forKeyPath: "estimatedProgress",
                            options: .new,
                            context: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("\(self.debugDescription) --- 销毁")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    
    // MARK: - 处理URL然后调用方法
    func handleCustomAction(url: URL) {
        
        let host = url.host
        
        if host == "scanClick" {
            print("点我干什么")
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
        webView.evaluateJavaScript(jsStr) { (result, error) in
            print("\(result)")
        }
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
        
        webView.evaluateJavaScript(jsStr) { (result, error) in
            print("\(result)")
        }
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
        
        webView.evaluateJavaScript(jsStr) { (result, error) in
            print("\(result)")
        }
    }
    
    func sharedAction() {
        print("分享")
    }
    
    func goBack() {
        webView.goBack()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            if let newProgress = change?[.newKey] as? Float{
                if newProgress == 1.0 {
                    progressView.setProgress(1.0, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * 0.7 )) / Double(NSEC_PER_SEC), execute: {
                        self.progressView.isHidden = true
                        self.progressView.setProgress(0, animated: false)
                    })
                } else {
                    progressView.isHidden = false
                    progressView.setProgress(newProgress, animated: true)
                }
            }
        }
    }


}

extension ARAWKWebViewController: WKNavigationDelegate,WKUIDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        let scheme = url?.scheme
        
        if let URL = url, scheme == "anranaction" {
            self.handleCustomAction(url: URL)
            // 一定要实现否则会崩溃
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: "提醒", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道", style: .cancel, handler: { (action) in
            completionHandler()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}
