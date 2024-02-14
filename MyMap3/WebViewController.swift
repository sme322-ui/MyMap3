//
//  WebViewController.swift
//  MyMap4
//
//  Created by Mongyan on 2023/5/1.
//

import Foundation
import WebKit
import OpenAI
import OpenAISwift
import PythonKit
import SwiftUI
class WebViewController :UIViewController,WKNavigationDelegate{
    var webView: WKWebView!
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ipAddress = "192.168.x.x" //連上Arduino溫度感測頁面
               
               // 拼接完整的URL
               if let url = URL(string: "http://\(ipAddress)") {
                   
                   // 使用UIApplication打開URL
                   if UIApplication.shared.canOpenURL(url) {
                       UIApplication.shared.open(url, options: [:], completionHandler: nil)
                       print("打開URL")
                   } else {
                       print("無法打開URL")
                   }
               }
        
    }
    
    
    
}
