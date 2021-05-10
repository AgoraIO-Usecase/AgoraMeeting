//
//  BrowserVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/26.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit
import WebKit

class BrowserVC: BaseViewController {

    let webView = WKWebView()
    var contentType: ContentType!
    
    
    init(contentType: ContentType) {
        self.contentType = contentType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        commonInit()
    }
    
    func setup() {
        webView.frame = view.bounds
        view.addSubview(webView)
    }
    
    func commonInit() {
        switch contentType! {
        case .disclaimer:
            title = NSLocalizedString("ab_t1", comment: "")
            let name = NSLocalizedString("ab_t1", comment: "") == "免责声明" ? "disclaimer_cn" : "disclaimer_en"
            guard let url = Bundle.main.url(forResource: name, withExtension: "html") else {
                return
            }
            webView.loadFileURL(url, allowingReadAccessTo: Bundle.main.bundleURL)
            break
        case .privacyPolicy:
            title = NSLocalizedString("ab_t4", comment: "")
            let string = NSLocalizedString("ab_t4", comment: "") == "Agora隐私政策" ? "https://www.agora.io/cn/privacy-policy/" : "https://www.agora.io/en/privacy-policy/"
            webView.load(URLRequest(url: URL(string: string)!))
            break
        }
    }
    
    enum ContentType {
        case disclaimer
        case privacyPolicy
    }
    
    
}
