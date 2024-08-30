//
//  OrganisationWrapperViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit
import PromiseKit

protocol MenuActionDelegate: class {
    func openNavigationEntry(menuEntry: NavigationEntry)
    func gotoSettings()
    func swapOrgPressed()
    func saveOpenMenuSections(openEntries: Set<NavigationEntry>)
    func gotoCart()
    func gotoLandingPage()
    func clearSelectedMenuEntry()
}

protocol SettingsDelegate: class {
    func swapOrgPressed()
    func gotoCart()
    func openLinkToNativePage(url: String)
    func gotoLogout()
    func forceLogoutForServer()
}

protocol CalendarDelegate: class {
    func gotoWebContent(url: String)
}

protocol DirectoryDelegate: class {
    func gotoWebContentFromDirectory(url: String)
}

protocol WebContentDelegate: class {
    func openLinkToNativePage(url: String)
    func gotoCart()
}

enum activePage {
    case empty
    case calendar
    case directory
    case webview(contentItem: WebContentItem)
    case settings
    case forceLogout
    case POSPage
    case forceLogoutServer
}

class OrganisationWrapperViewController: UIViewController {

    var organisationColours: OrganisationColours!
    var posStoreUrl = ""
    var presenter: OrganisationWrapperPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    fileprivate let menuState = MenuState()
    fileprivate var organisationContentNC: OrganisationNavigationController?
    fileprivate var selectedNavigationEntry: NavigationEntry?
    fileprivate var selectedActivePage: activePage = .empty
    fileprivate var openEntries = Set<NavigationEntry>()
    fileprivate var logoutOverlayView: OverlayView?
    fileprivate var selectMenuItemFromUrl: String?
    fileprivate var menuIconView: MenuIconView?
    var deferredReceivedNotification: ReceivedNotification? {
        didSet {
            presenter?.deferredReceivedNotification = deferredReceivedNotification
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
    }
    
    deinit {
        presenter?.wrapperDeinit()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let organisationContentNC = segue.destination as? OrganisationNavigationController {
            organisationContentNC.delegate = self
            self.organisationContentNC = organisationContentNC
        } else if let menuVC = segue.destination as? MenuViewController {
            menuVC.transitioningDelegate = self
            menuVC.menuState = menuState
            menuVC.menuActionDelegate = self
            menuVC.selectedMenuEntry = self.selectedNavigationEntry
            if let selectMenuItemFromUrl = self.selectMenuItemFromUrl {
                //send url clicked from web view to mark selected item in menu
                menuVC.selectMenuItemFromUrl = selectMenuItemFromUrl                
                self.selectMenuItemFromUrl = nil
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        closeMenu(animated: false)
    }
    
    func handleReceivedNotification(notification: ReceivedNotification) {
        presenter?.handleReceivedNotification(notification: notification)
    }
    
    func saveUnreadNotificationsCount(unreadCounts: Dictionary<String, String>) {
        presenter?.saveUnreadNotificationsCount(unreadCounts: unreadCounts)
    }
}

extension OrganisationWrapperViewController: MenuActionDelegate {
    func saveOpenMenuSections(openEntries: Set<NavigationEntry>) {
        self.openEntries = openEntries
    }
    
    func openNavigationEntry(menuEntry: NavigationEntry) {
        presenter?.openNavigationEntry(menuEntry: menuEntry)
    }
    
    func gotoSettings() {        
        presenter?.openSettings()
    }
    
    func swapOrgPressed() {
        presenter?.swapOrgPressed()
    }
    
    func gotoLandingPage() {
        presenter?.gotoLandingPage()
    }
    
    func clearSelectedMenuEntry() {
        presenter?.clearSelectedMenuEntry()
    }
}

extension OrganisationWrapperViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return menuState.hasStarted ? menuState : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return menuState.hasStarted ? menuState : nil
    }
}

extension OrganisationWrapperViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}

extension OrganisationWrapperViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch organisationColours.statusBarStyle {
        case .light:
            return .lightContent
        case .dark:
            return .default
        }
    }
}

extension OrganisationWrapperViewController: OrganisationWrapperView {
    func openMenuSegue() {
        performSegue(withIdentifier: "openMenu", sender: nil)
    }
    
    func closeMenu(animated: Bool) {
        if let menuVC = presentedViewController as? MenuViewController {
            menuVC.dismiss(animated: animated, completion: nil)
        }
        if animated == false {
            view.layoutIfNeeded()
        }
    }
    
    func changePage(to: activePage) {
        switch to {
        case .calendar:
            if let calendarVC = storyboard?.instantiateViewController(withIdentifier: "calendarVC") as? CalendarViewController {
                calendarVC.delegate = self
                calendarVC.hidesBottomBarWhenPushed = true
                organisationContentNC?.setViewControllers([calendarVC], animated: false)
            }
        case .directory:
            if let directoryVC = storyboard?.instantiateViewController(withIdentifier: "directoryVC") as? DirectoryViewController {
                directoryVC.delegate = self
                directoryVC.hidesBottomBarWhenPushed = true
                organisationContentNC?.setViewControllers([directoryVC], animated: false)
            }
        case .webview(let contentItem):
            if contentItem.url! != ""
            {
                if let webContentVC = storyboard?.instantiateViewController(withIdentifier: "webContentVC") as? WebContentViewController {
                    webContentVC.webContentEntry = contentItem
                    webContentVC.delegate = self
                    organisationContentNC?.setViewControllers([webContentVC], animated: false)
                }
            }
            else
            {
                
            }
           
        case .settings:
            if let settingsVC = storyboard?.instantiateViewController(withIdentifier: "settingsVC") as? SettingsViewController {
                settingsVC.delegate = self
                settingsVC.hidesBottomBarWhenPushed = true
                organisationContentNC?.setViewControllers([settingsVC], animated: false)
            }
        case .empty:
            organisationContentNC?.setViewControllers([], animated: false)
        case .forceLogout:
            presenter?.pageChangedToForceLogout()
        case .POSPage:
            presenter?.newWebviewpage(urlposId: "")
        case .forceLogoutServer:
            presenter?.pageChangedToForceLogout()
        }

        selectedActivePage = to
        
        presenter?.buildMenuBarButton()
        addScreenEdgeGesture()
        
        closeMenu(animated: true)
    }
    
    func setSelectedMenuEntry(menuEntry: NavigationEntry?) {
        self.selectedNavigationEntry = menuEntry
    }
    
    func setMenuBarButton(count: Int) {
        let tintColour = organisationColours.tintColour
        self.menuIconView = MenuIconView(count: count, tintColour: tintColour, menuPressed: { [weak self] () in
            guard let weakSelf = self else { return }
            weakSelf.presenter?.openMenu()
        })
        
        let menuBarButtonItem = UIBarButtonItem(customView: self.menuIconView!)
        organisationContentNC?.viewControllers.first?.navigationItem.leftBarButtonItem = menuBarButtonItem
    }
    
    func addScreenEdgeGesture() {
        let storeApiUrl = MembershipAPIRouter.storeURL
        if ((storeApiUrl?.contains("_pos/")) != nil) {
            DispatchQueue.main.async {
                let screenEdgePanGesure = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.screenEdgeSwiped))
                screenEdgePanGesure.edges = []
                self.organisationContentNC?.viewControllers.first?.view.addGestureRecognizer(screenEdgePanGesure)
            }
        }
        else{
            DispatchQueue.main.async {
                let screenEdgePanGesure = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.screenEdgeSwiped))
                screenEdgePanGesure.edges = UIRectEdge.left
                self.organisationContentNC?.viewControllers.first?.view.addGestureRecognizer(screenEdgePanGesure)
            }
        }
    }
    
    @objc func screenEdgeSwiped(gesture: UIScreenEdgePanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translation, viewBounds: view.bounds, direction: .right)
        
        MenuHelper.mapGestureStateToInteractor(
            gesture.state,
            progress: progress,
            menuState: menuState){
                self.openMenuSegue()
        }
    }
    
    func changeToOrganisationsVC() {
        guard let loginNC = storyboard?.instantiateViewController(withIdentifier: "loginNC") as? LoginNavigationController else { return }
        guard let organisationsVC = storyboard?.instantiateViewController(withIdentifier: "organisationsVC") as? OrganisationsViewController else { return }
        
        organisationsVC.switchingOrganisation = true
        
        loginNC.setViewControllers([organisationsVC], animated: false)
        
        guard let appDelegate = UIApplication.shared.delegate else { return }
        
        loginNC.view.layoutIfNeeded()
        
        UIView.transition(with: appDelegate.window!!, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: {
            appDelegate.window??.rootViewController = loginNC
            appDelegate.window??.makeKeyAndVisible()
        }, completion: nil)
    }
    
    func changeToLoginVC() {
        guard let loginNC = storyboard?.instantiateViewController(withIdentifier: "loginNC") as? LoginNavigationController else { return }
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginViewController else { return }
        
        loginNC.setViewControllers([loginVC], animated: false)
        
        guard let appDelegate = UIApplication.shared.delegate else { return }
        
        loginNC.view.layoutIfNeeded()
        
        UIView.transition(with: appDelegate.window!!, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: {
            appDelegate.window??.rootViewController = loginNC
            appDelegate.window??.makeKeyAndVisible()
        }, completion: nil)
    }
    
    func changeToLoginVCAuthError() {
        guard let loginNC = storyboard?.instantiateViewController(withIdentifier: "loginNC") as? LoginNavigationController else { return }
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginViewController else { return }
        
        loginNC.setViewControllers([loginVC], animated: false)
        
        guard let appDelegate = UIApplication.shared.delegate else { return }
        appDelegate.window??.rootViewController = loginNC
        appDelegate.window??.makeKeyAndVisible()
       
        loginNC.view.layoutIfNeeded()
        
        let alertVC = UIAlertController(title: "Login Error", message: "There was an error. Please try and login again.", preferredStyle: .alert)
        let okayBtn = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertVC.addAction(okayBtn)
        
        loginNC.present(alertVC, animated: true, completion: nil)
    }
    
    func showLogoutOverlay() {
        if logoutOverlayView == nil {
            logoutOverlayView = OverlayView()
            logoutOverlayView?.message = "Logging out..."
            logoutOverlayView!.frame = view.frame
            logoutOverlayView?.translatesAutoresizingMaskIntoConstraints = false
            
            view.window?.addSubview(logoutOverlayView!)
            
            logoutOverlayView!.constraintToSuperView(superView: view)
        }
    }
    
    func removeLogoutOverlay() {
        logoutOverlayView?.removeFromSuperview()
        logoutOverlayView = nil
    }
    
    func showSwapOrgConfirmPopup() {
        let alertVC = UIAlertController(title: "Swap Organization", message: "Are you sure you want to swap organization?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.presenter?.swapOrgConfirmed()
        }
        let no = UIAlertAction(title: "No", style: .cancel) { (action) in
            
        }
        alertVC.addAction(yes)
        alertVC.addAction(no)
        alertVC.preferredAction = no
        
        var topVC: UIViewController = self
        if let presentedVC = presentedViewController {
            topVC = presentedVC
        }
        topVC.present(alertVC, animated: true, completion: nil)
    }
    
    func selectMenuItemFromUrl(url: String) {
        //save url ready for next time menu is opened to mark item from loaded url
        selectMenuItemFromUrl = url
    }
    
    func changeToNotifOrgSwitcher(notification: ReceivedNotification) {
        guard let appDelegate = UIApplication.shared.delegate else { return }

        if let notifOrgSwticherVC = storyboard?.instantiateViewController(withIdentifier: "notifOrgSwitcherVC") as? NotifOrgSwitcherViewController {
            notifOrgSwticherVC.receivedNotification = notification
            appDelegate.window??.rootViewController = notifOrgSwticherVC
        }
    }
}

extension activePage {
    static func ==(lhs: activePage, rhs: activePage) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.calendar, .calendar):
            return true
        case (.directory, .directory):
            return true
        case (.webview(let navigationEntryA), .webview(let navigationEntryB)):
            let urlA = navigationEntryA.url ?? ""
            let urlB = navigationEntryB.url ?? ""
            return urlA == urlB
        default:
            return false
        }
    }
}

extension OrganisationWrapperViewController: SettingsDelegate {
    func gotoLogout() {
        presenter?.logout()
    }
    func forceLogoutForServer()
    {
        presenter?.pageChangedToForceLogout()
    }
}

extension OrganisationWrapperViewController: WebContentDelegate {
    // here we should get url and change it here to pass inside the webview.
    func openLinkToNativePage(url: String) {
        
        if url.contains("pos/")
        {
            let mainApiUrl = MembershipAPIRouter.serverRouteURL!
            if #available(iOS 16.0, *) {
                if let separatorRange = mainApiUrl.range(of: "//"),
                   let domainRange = mainApiUrl.range(of: "/", range: separatorRange.upperBound..<mainApiUrl.endIndex) {

                    let domain = mainApiUrl[separatorRange.upperBound..<domainRange.lowerBound]
//                    let restOfUrl = mainApiUrl[domainRange.lowerBound..<mainApiUrl.endIndex]
                    print(domain)
//                    print(restOfUrl)

                    if let range = url.range(of: "pos/") {
                        let finalId = url[range.upperBound...]
                        var prefixUrlstring = "\(domain)/_pos/\(finalId)"
                        
                        if !prefixUrlstring.hasPrefix("https://") {
                            prefixUrlstring = "https://" + prefixUrlstring
                        }
                        MembershipAPIRouter.storeURL = url
                        presenter?.newWebviewpage(urlposId: prefixUrlstring)
                        posStoreUrl = prefixUrlstring
                    }
                }
            } else {
                if let separatorRange = mainApiUrl.range(of: "//"),
                   let domainRange = mainApiUrl.range(of: "/", options: [], range: separatorRange.upperBound..<mainApiUrl.endIndex) {
                    
                    let domain = String(mainApiUrl[separatorRange.upperBound..<domainRange.lowerBound])
                    let restOfUrl = String(mainApiUrl[domainRange.lowerBound..<mainApiUrl.endIndex])
                    
                    if let range = url.range(of: "pos/") {
                        let finalId = url[range.upperBound...]
                        var prefixUrlstring = "\(domain)/_pos/\(finalId)"
                        
                        if !prefixUrlstring.hasPrefix("https://") {
                            prefixUrlstring = "https://" + prefixUrlstring
                        }
                        MembershipAPIRouter.storeURL = url
                        presenter?.newWebviewpage(urlposId: prefixUrlstring)
                        posStoreUrl = prefixUrlstring
                    }
                }
            }
        }
        else
        {
            presenter?.openLinkToNativePage(url: url)

        }
    }
    
    func gotoCart() {
        presenter?.gotoCart()
    }
}

extension OrganisationWrapperViewController: CalendarDelegate {
    func gotoWebContent(url: String) {
        presenter?.gotoWebContentFromCalendar(url: url)
    }
}

extension OrganisationWrapperViewController: DirectoryDelegate {
    func gotoWebContentFromDirectory(url: String) {
        presenter?.gotoWebContentFromDirectory(url: url)
    }
}
