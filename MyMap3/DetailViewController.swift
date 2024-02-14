//
//  DetailViewController.swift
//  Swift-TableView-Example
//
//  Created by Bilal ARSLAN on 12/10/14.
//  Copyright (c) 2014 Bilal ARSLAN. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var prepTime: UILabel!

    var recipe: Recipe?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let recipe = recipe {
            navigationItem.title = recipe.name
            imageView.image = UIImage(named: recipe.thumbnails)
            nameLabel.text = recipe.name
            prepTime.text = "Prep Time: " + recipe.prepTime
        }
       
        let ipAddress = "192.168.1.104:8089/M/"
               
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
