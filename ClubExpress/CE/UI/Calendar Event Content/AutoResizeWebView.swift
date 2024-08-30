//
//  AutoResizeWebView.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 25/02/2019.
//  
//

import UIKit
import WebKit

protocol AutoResizeWebViewDelegate: class {
    func webViewDidFinishLoadingHeight(webView: WKWebView)
    func webViewLinkClicked(webView: WKWebView, url: String)
}

class AutoResizeWebView: WKWebView {
    
    weak var delegate: AutoResizeWebViewDelegate?
    
    init(frame: CGRect) {
        let configuration = WKWebViewConfiguration()
        super.init(frame: frame, configuration: configuration)
        self.navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return self.scrollView.contentSize
    }
    
    func updateIntrinsicContentSize() {
        self.evaluateJavaScript("document.readyState", completionHandler: { (_, _) in
            self.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
            print(self.scrollView.contentSize.height)
        })
    }
}

extension AutoResizeWebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateIntrinsicContentSize()
            self.delegate?.webViewDidFinishLoadingHeight(webView: self)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            let url = navigationAction.request.url?.absoluteString ?? ""
            delegate?.webViewLinkClicked(webView: self, url: url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
        return
    }
    
}
