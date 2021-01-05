//
//  DetailViewController.swift
//  First01
//
//  Created by 北田菜穂 on 2020/12/31.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var data: (name:String, link:URL)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        guard let webData = data else {
//            return
//        }
//        let myURL = URL(string: webData.link)
//        let myRequest = URLRequest(url: myURL!)
//        webView.load(myRequest)
    }
}
