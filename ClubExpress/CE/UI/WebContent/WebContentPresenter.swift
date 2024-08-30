//
//  WebContentPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import WebKit
import UIKit


protocol WebContentView: AnyObject {
    func loadUrl(urlString: String)
    func loadLoginScreen(urlString: String)
    func loadHtmlContent(content: String)
    func setTitle(title: String)
    func toggleLoadingIndicator(show: Bool)
    func setTitleFromWebView()
    func openLinkToNativePage(url: String)
    func setupBasketButton(count: Int)
    func gotoCart()
    func openSafari(urlString: String)
    func closePopup()
    func showLoadingErrorPopup()
}

class WebContentPresenter {
    weak var view: WebContentView?
    fileprivate var interactor: WebContentInteractor
    fileprivate var splashInteractors: SplashInteractor?
    fileprivate var InteractorLocationId: LocationIdInteractor?
    fileprivate var footerUrl = ""
    var webContentEntry: WebContentItem?
    weak var viewSplash: SplashView?
    var organisationColours: OrganisationColours!
    fileprivate var preparedUrl: String?
    fileprivate let navigationUtil = NavigationUtil()
    var showCartBtn = true
    fileprivate var viewVisible = false
    var isUrlWhileLoggedOut = false
    var htmlContent = ""
    let navigationController = UINavigationController()
    var baseUrlFilter : String = ""
    init(interactor: WebContentInteractor) {
        self.interactor = interactor
//        self.InteractorLocationId = interactorLocationId
    }
    
    func viewDidLoad() {
        setTitle()
        loadWebViewContent()
        if showCartBtn {
            getInitialBasketCount()
            listenForBasketCountChanges()
        }
    }
   
    func viewIsVisible(visible: Bool) {
        self.viewVisible = visible
    }
    
    fileprivate func setTitle() {
        guard let webContentEntry = self.webContentEntry else { return }
        let title = webContentEntry.title
        view?.setTitle(title: title)
    }
    
    fileprivate func loadWebViewContent() {
        view?.toggleLoadingIndicator(show: true)

        guard let webContentEntry = self.webContentEntry else { return }
        if let url = webContentEntry.url {
            let isNativeUrl = navigationUtil.isNativePage(url: url)
            if isNativeUrl {
                view?.openLinkToNativePage(url: url)
            } else {
//                let isPDFUrl = isUrlPDF(url: url)
//                let isUrlInternalDomain = isUrlAnInternalDomain(url: url)

//                if isPDFUrl || !isUrlInternalDomain {
//                    view?.openSafari(urlString: url)
//                    view?.toggleLoadingIndicator(show: false)
//                } else {
//                    if isUrlWhileLoggedOut {
//                        view?.loadUrl(urlString: url)
//                    } 
//                    else {
//                        baseUrlFilter = url
//                        let urlString = interactor.buildWebUrl(endpoint: url)
//                        MembershipAPIRouter.serverRouteURL = url
                
//                    }
//                }
                if url.contains("mtkapp:logout")
                {
                    self.clearUserDefaults()
                }
                else
                {
                    view?.loadUrl(urlString: url)

                }

            }
        } else if let htmlContent = webContentEntry.content {
            view?.loadHtmlContent(content: htmlContent)
        }

    }
     func loadWebViewContentHome(urlHome:String) {
        view?.toggleLoadingIndicator(show: true)
        view?.loadUrl(urlString: urlHome)
    }
    func didStartLoadingUrl() {
        view?.toggleLoadingIndicator(show: true)
    }
    
    func didFinishLoadingUrl() {
        view?.toggleLoadingIndicator(show: false)
        view?.setTitleFromWebView()
    }

    func didFailLoadingUrl() {
        view?.toggleLoadingIndicator(show: false)
        if viewVisible {
//            view?.showLoadingErrorPopup()
        }
    }
    func clearUserDefaults() {
        
        viewSplash?.setupNavigationFlow(state: .login, isAdmin: false)
        interactor.removeLocalDataSessions()
        
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            UserDefaults.standard.synchronize()
        }
        
    }
    func handleLinkActivated(url: String) -> Bool {
//        let isNativeUrl = navigationUtil.isNativePage(url: url)
//        if isNativeUrl {
        
//            view?.openLinkToNativePage(url: url)
//            return true
//        }
        if url.contains("mtkapp:logout")
        {
            view?.loadLoginScreen(urlString: url)
        }
        else
        {
            view?.loadUrl(urlString: url)
            print(url)
        }
//        let isOtherScheme = isUrlOtherScheme(url: url)
//        if isOtherScheme {
//            view?.openSafari(urlString: url)
//            return false
//        }
//        let isPDFUrl = isUrlPDF(url: url)
//        if isPDFUrl {
//            view?.openSafari(urlString: url)
//            return false
//        }
//        let isUrlInternalDomain = isUrlAnInternalDomain(url: url)
//        if isUrlInternalDomain {
//            return true
//        } else {
//            view?.openSafari(urlString: url)
            return false
//        }
    }
    
    func handleUrlChange(url: String) -> Bool {
        print(url)
        let isNativeUrl = navigationUtil.isNativePage(url: url)
        if isNativeUrl {
            view?.openLinkToNativePage(url: url)
            return false
        }
        return true
    }
    
    fileprivate func listenForBasketCountChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(basketCountChanged), name: Notification.Name.init("BasketCountChange"), object: nil)
    }
    
    @objc func basketCountChanged(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let basketCount = userInfo["basketCount"] as? Int {
                view?.setupBasketButton(count: basketCount)
            }
        }
    }
    
    fileprivate func getInitialBasketCount() {
        let basketCount = interactor.getBasketCount()
        view?.setupBasketButton(count: basketCount)
    }

    func basketButtonPressed() {
        view?.gotoCart()
    }
    
    fileprivate func isUrlAnInternalDomain(url: String) -> Bool {
        if isUrlWhileLoggedOut { return true }
        
        let internalDomains = interactor.getInternalDomains()
        for internalDomain in internalDomains {
            if url.contains(internalDomain) {
                return true
            }
        }
        return false
    }
    
    fileprivate func isUrlOtherScheme(url: String) -> Bool {
        let otherSchemes = ["mailto:", "tel:", "telprompt:", "sms:"]
        for otherScheme in otherSchemes {
            if url.hasPrefix(otherScheme) {
                return true
            }
        }
        return false
    }
    
    fileprivate func isUrlPDF(url: String) -> Bool {
        return url.lowercased().contains(".pdf")
    }
    
    func dismissBtnPressed() {
        view?.closePopup()
    }
}
