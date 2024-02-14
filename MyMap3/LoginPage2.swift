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
        
        let url = URL(string: "http://192.168.1.104:8088/Demo")!

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    
    
    
}
