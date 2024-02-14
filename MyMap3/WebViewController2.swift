import Foundation
import WebKit
import OpenAI
import OpenAISwift
import PythonKit
import SwiftUI
class WebViewController2 :UIViewController,WKNavigationDelegate{
    var webView2: WKWebView!
    override func loadView() {
        webView2 = WKWebView()
        webView2.navigationDelegate = self
        view = webView2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ipAddress = "192.168.1.104:5501/th?t=20.90"
               
               // 拼接完整的URL
               if let url = URL(string: "http://\(ipAddress)") {
                   
                   // 使用UIApplication打開URL
                   if UIApplication.shared.canOpenURL(url) {
                       UIApplication.shared.open(url, options: [:], completionHandler: nil)
                   } else {
                       print("無法打開URL")
                   }
               }
        
    }
    
    
    
}
