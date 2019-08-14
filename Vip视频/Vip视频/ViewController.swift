//
//  ViewController.swift
//  Vip视频
//
//  Created by Ethon.Z on 2019/8/14.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    // 进度条
    lazy var progressView:UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor.orange
        progress.trackTintColor = .clear
        progress.frame = CGRect(x:0,y:UIApplication.shared.statusBarFrame.size.height + 44.0,width:self.view.frame.size.width,height:2)
        
        return progress
    }()
    //返回按钮
    lazy var leftItem = { () -> UIBarButtonItem in
        let btn = UIButton(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        btn.setTitle("返回", for: .normal)
        btn.addTarget(self, action: #selector(clickBackBtn), for: .touchUpInside)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.setTitleColor(.lightGray, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        let item = UIBarButtonItem(customView: btn)
        return item
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.progressView.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.progressView.progress = 0.0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(progressView)
        loadRequest()
        
    }
    @objc func clickBackBtn(){
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    func loadRequest(){
        webView.uiDelegate = self
        webView.navigationDelegate = self
        //视频播放地址
        let urlStr = "https://www.lazyman.vip/2018/11/24/%E5%85%A8%E7%BD%91VIP%E8%A7%86%E9%A2%91%E8%A7%A3%E6%9E%90%E6%8E%A5%E5%8F%A3/"
        
        guard let url = URL(string: urlStr) else {
            print("视频地址有误");
            showAlert()
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
        
    }
    func showAlert(){
        let alertVC = UIAlertController(title: "视频地址有误", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
        }
        let conformAction = UIAlertAction(title: "知道了", style: .destructive) { (action) in
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(conformAction)
        let vc = UIApplication.shared.keyWindow?.rootViewController
        vc?.present(alertVC, animated: true, completion: nil)
    }
}

 //MARK: - WKNavigationDelegate
extension ViewController:WKNavigationDelegate{
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        print("didStartProvisionalNavigation");
        self.navigationItem.title = "加载中..."
        /// 获取网页的progress
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = Float(self.webView.estimatedProgress)
        }
    }
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        print("didCommit");

    }
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        print("didFinish");
        
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = 1.0
            self.progressView.isHidden = true
        }
        /// 获取网页title
        let titleStr = self.webView.title
        guard let titleName = titleStr else {
            return
        }
        self.title = titleName

        if titleName.count >= 5 {
            let titleName = titleName.prefix(5)
            self.title = String(titleName)
        }
        if webView.canGoBack {
            self.navigationItem.leftBarButtonItem = self.leftItem;
        }else{
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        print("didFail",error);

        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = 0.0
            self.progressView.isHidden = true
        }
        /// 弹出提示框点击确定返回
        let alertView = UIAlertController.init(title: "提示", message: "加载失败", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title:"确定", style: .default) { okAction in
            _=self.navigationController?.popViewController(animated: true)
        }
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
        
    }

}
//MARK: - WKUIDelegate
extension ViewController:WKUIDelegate{
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("createWebViewWithConfiguration");
        //假如是重新打开窗口的话
        let targetFrame = navigationAction.targetFrame
        if targetFrame == nil  {
            webView.load(navigationAction.request)
        }
    
        return nil;
    }
}
