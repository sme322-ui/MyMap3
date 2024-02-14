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
class THViewController :UIViewController,WKNavigationDelegate{
    var webView: WKWebView!
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "http://192.168.x.x:8088/Demo")! //url <- Demo IP位址

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil) 
        } else {
            UIApplication.shared.openURL(url) //開啟:/sme322-ui/Demo 專案,顯示圖表資訊
        }
        
    }
    
    
    
}
