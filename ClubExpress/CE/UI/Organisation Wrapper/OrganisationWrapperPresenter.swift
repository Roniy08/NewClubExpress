//
//  OrganisationWrapperPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

protocol OrganisationWrapperView: class {
    func openMenuSegue()
    func changePage(to: activePage)
    func setSelectedMenuEntry(menuEntry: NavigationEntry?)
    func clearSelectedMenuEntry()
    func changeToOrganisationsVC()
    func changeToLoginVC()
    func changeToLoginVCAuthError()
    func showLogoutOverlay()
    func removeLogoutOverlay()
    func showSwapOrgConfirmPopup()
    func closeMenu(animated: Bool)
    func selectMenuItemFromUrl(url: String)
    func setMenuBarButton(count: Int)
    func changeToNotifOrgSwitcher(notification: ReceivedNotification)
}

class OrganisationWrapperPresenter {
    weak var view: OrganisationWrapperView?
    var interactor: OrganisationWrapperInteractor
    fileprivate let navigationUtil = NavigationUtil()
    var deferredReceivedNotification: ReceivedNotification?
    var landingPageWebContentItem: WebContentItem?
    var appDidReturnFromBackground = false
    
    init(interactor: OrganisationWrapperInteractor) {
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        setupAuthErrorNotification()
        setupInitialBasketCount()
        setupInitialUnreadNotificationsCount()
        setupUnreadNotificationsCountDidChangeNotification()
        setupAppReturnedFromBackgroundNotification()
        connectToAbly()
        
        getLandingPageContent().done { [weak self] (success) in
            guard let weakSelf = self else { return }
            if weakSelf.deferredReceivedNotification == nil {
                weakSelf.setPageToLandingPage()
            }
        }.catch { (error) in
            print(error)
        }
        

        if let deferredReceivedNotification = deferredReceivedNotification {
            handleReceivedNotification(notification: deferredReceivedNotification)
        }
    }
    
    func handleReceivedNotification(notification: ReceivedNotification) {
        let selectedOrganisationID = interactor.getCurrentOrganisationID()
        let orgID = notification.orgID
        
        if orgID == selectedOrganisationID {
            //open web view
            let url = notification.navigateUrl
            let contentItem = WebContentItem(title: "", url: url, content: nil)
            let webPage = activePage.webview(contentItem: contentItem)
            view?.changePage(to: webPage)
            
            //Sync badge count from notification
            let unreadCounts = notification.orgUnreadCounts
            saveUnreadNotificationsCount(unreadCounts: unreadCounts)
        } else {
            //switch org first
            print("need to switch org: \(orgID) vs \(selectedOrganisationID)")
            view?.changeToNotifOrgSwitcher(notification: notification)
        }
    }
    
    func getLandingPageContent() -> Promise<Bool> {
        return Promise { seal in
            interactor.getHomeContent().done { [weak self] response in
                guard let weakSelf = self else { return }
                let homeContent = response.body
                let homeUrl = response.homeUrl
                let contentItem = WebContentItem(title: "Landing Page", url: homeUrl, content: homeContent)
                weakSelf.landingPageWebContentItem = contentItem
                seal.fulfill(true)
            }.catch { error in
                print(error)
                seal.reject(error)
            }
        }
    }
    
    func setPageToLandingPage() {
        if let landingPageWebContentItem = self.landingPageWebContentItem {
            view?.changePage(to: activePage.webview(contentItem: landingPageWebContentItem))
        } else {
            getLandingPageContent().done { [weak self] (success) in
                guard let weakSelf = self else { return }
                weakSelf.setPageToLandingPage()
            }.catch { (error) in
                print(error)
            }
        }
    }
    
    func openMenu() {
        view?.openMenuSegue()
    }
    
    func openNavigationEntry(menuEntry: NavigationEntry) {
        view?.setSelectedMenuEntry(menuEntry: menuEntry)
        
        let newActivePage = navigationUtil.getPage(menuEntry: menuEntry)
        view?.changePage(to: newActivePage)
    }
    
    func openSettings() {
        view?.clearSelectedMenuEntry()

        let newActivePage = activePage.settings
        view?.changePage(to: newActivePage)
    }
    
    func swapOrgPressed() {
        if interactor.hasSwitchOrganisationPopupShown() == true {
            swapOrgConfirmed()
        } else {
            view?.showSwapOrgConfirmPopup()
            
            interactor.setShownSwitchOrganisationPopup()
        }
    }
    
    func swapOrgConfirmed() {
        view?.closeMenu(animated: false)
        
        interactor.clearSelectedOrganisationData()
        
        view?.changeToOrganisationsVC()
    }
    
    func logout() {
        view?.showLogoutOverlay()
        
        interactor.logoutUser().done { response in
            }.catch { error in
            }.finally { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.view?.removeLogoutOverlay()
                weakSelf.view?.changeToLoginVC()
        }
    }
    
    func openLinkToNativePage(url: String) {
        if url.contains("pos/")
        {
            print("open link",url)
            let endpoint = navigationUtil.getEndpointAfterScheme(url: url)
            if let page = navigationUtil.getNativePageFromEndpoint(endpoint: endpoint) {
                view?.changePage(to: page)
            }
            view?.selectMenuItemFromUrl(url: url)
        }
        else
        {
            let endpoint = navigationUtil.getEndpointAfterScheme(url: url)
            if let page = navigationUtil.getNativePageFromEndpoint(endpoint: endpoint) {
                view?.changePage(to: page)
            }
            view?.selectMenuItemFromUrl(url: url)
        }
       
        
       
    }
    
    func wrapperDeinit() {
        interactor.unsubscribeFromBasketUpdates()

        removeAuthErrorNotification()
        removeUnreadNotificationsCountDidChangeNotifications()
        removeAppReturnedFromBackgroundNotification()
    }
    
    fileprivate func setupAuthErrorNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(receivedAuthError), name: Notification.Name.init(rawValue: "AuthInvalidNotification"), object: nil)
    }
    
    fileprivate func removeAuthErrorNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init(rawValue: "AuthInvalidNotification"), object: nil)
    }
    
    @objc func receivedAuthError(notification: Notification) {
        forceLogout()
    }
    
    fileprivate func setupAppReturnedFromBackgroundNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    fileprivate func removeAppReturnedFromBackgroundNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func appWillEnterForeground(notification: Notification) {
        appDidReturnFromBackground = true
    }
    
    @objc func appDidBecomeActive(notification: Notification) {
        if appDidReturnFromBackground {
            //TODO get the right amount of notifications
            refreshUnreadCount()
            refreshCurrentOrgUnreadCount()
        }
        appDidReturnFromBackground = false
    }
    
    func saveUnreadNotificationsCount(unreadCounts: Dictionary<String, String>) {
        let selectedOrganisationID = interactor.getCurrentOrganisationID()
        if let selectedOrgUnreadCount = unreadCounts[selectedOrganisationID] {
            if let unreadCountInt = Int(selectedOrgUnreadCount) {
                interactor.setUnreadOrgNotificationsCount(count: unreadCountInt)
            }
        }
    }
    
    fileprivate func setupUnreadNotificationsCountDidChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(unreadNotificationsCountDidChange), name: Notification.Name.init("UnreadNotificationsCountDidChange"), object: nil)
    }
    
    fileprivate func removeUnreadNotificationsCountDidChangeNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("UnreadNotificationsCountDidChange"), object: nil)
    }
    
    @objc func unreadNotificationsCountDidChange(notification: Notification) {
        buildMenuBarButton()
    }
    
    fileprivate func setupInitialBasketCount() {
        interactor.setInitialBasketCount()
    }
    
    fileprivate func setupInitialUnreadNotificationsCount() {
        interactor.setInitialUnreadOrgNotificationsCount()
    }
    
    fileprivate func connectToAbly() {
        interactor.connectToAbly()
    }
    
    func gotoCart() {
        view?.clearSelectedMenuEntry()

        let checkoutUrl = interactor.getCheckoutUrl()
        let contentItem = WebContentItem(title: "Checkout", url: checkoutUrl, content: nil)
        let webViewPage = activePage.webview(contentItem: contentItem)
        view?.changePage(to: webViewPage)
    }
    
    func pageChangedToForceLogout() {
        forceLogout()
    }
    func newWebviewpage(urlposId: String) {
        print("here start new page")
        let contentItem = WebContentItem(title: "", url: urlposId, content: nil)
        let webViewPage = activePage.webview(contentItem: contentItem)
        view?.changePage(to: webViewPage)
    }
    
    fileprivate func forceLogout() {
        //Clear app data and force to login vc
        interactor.clearAppData()
        DispatchQueue.main.async {
            self.view?.changeToLoginVCAuthError()
        }
    }
    
    func gotoLandingPage() {
        setPageToLandingPage()
    }
    
    func buildMenuBarButton() {
        let count = interactor.getRemoteOrgNotificationsCount()
    
        view?.setMenuBarButton(count: count)
    }
    
    func refreshUnreadCount() {
        interactor.refreshUnreadCount().done { [weak self] unreadCount in
             guard let weakSelf = self else { return }
            var orgCounts = weakSelf.interactor.sessionRepository.getSession()?.userInfo?.orgUnreadCounts
            var currentAppNotificatinoCount = Int(weakSelf.interactor.sessionRepository.getSession()?.userInfo?.unreadOrgNotifications ?? "0")
            
            var badgeCount = unreadCount
            
//            UserDefaults.standard.set("\(badgeCount - currentAppNotificatinoCount!)", forKey: "otherAppUnreadCount")
            UserDefaults.standard.set("\(unreadCount)", forKey: "UpdateCount")
            UIApplication.shared.applicationIconBadgeNumber = unreadCount
            
            let otherAppNotificationDict:[String: Int] = ["count": badgeCount - currentAppNotificatinoCount!]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "totalCount"), object: nil, userInfo: otherAppNotificationDict)
            
            let totalAppNotificationCountDict:[String: Int] = ["count": unreadCount]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCount"), object: nil, userInfo: totalAppNotificationCountDict)
            weakSelf.interactor.setUnreadOrgNotificationsCount(count: unreadCount)
        }.catch { error in
            print(error)
        }
    }
    
    func refreshCurrentOrgUnreadCount() {
        interactor.refreshCurrentOrgUnreadCount().done { [weak self] currentUnreadOrgCount in
             guard let weakSelf = self else { return }
            
            var totalNum = Int(UserDefaults.standard.string(forKey: "UpdateCount") ?? "0")
            
            let otherAppNotifCount:[String: Int] = ["count": totalNum! - currentUnreadOrgCount]
            UserDefaults.standard.set("\(totalNum! - currentUnreadOrgCount)", forKey: "otherAppUnreadCount")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "otherAppUnreadCount"), object: nil, userInfo: otherAppNotifCount)
        }.catch { error in
            print(error)
        }
    }
    
    func clearSelectedMenuEntry() {
        view?.setSelectedMenuEntry(menuEntry: nil)
    }
    
    func gotoWebContentFromCalendar(url: String) {
        view?.clearSelectedMenuEntry()

        let contentItem = WebContentItem(title: "", url: url, content: nil)
        let webViewPage = activePage.webview(contentItem: contentItem)
        view?.changePage(to: webViewPage)
    }
    
    func gotoWebContentFromDirectory(url: String) {
        view?.clearSelectedMenuEntry()
        
        let contentItem = WebContentItem(title: "", url: url, content: nil)
        let webViewPage = activePage.webview(contentItem: contentItem)
        view?.changePage(to: webViewPage)
    }
}
