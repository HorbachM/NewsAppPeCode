//
//  WebViewViewController.swift
//  NewsAppPeCode
//
//  Created by Horbach on 8/26/19.
//  Copyright © 2019 Horbach. All rights reserved.
//

import UIKit

class WebViewViewController: UIViewController {

    @IBOutlet weak var webview: UIWebView!
    var url:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.loadRequest(URLRequest(url: URL(string: url!)!))
    }
}
