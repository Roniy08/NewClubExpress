//
//  SplashViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit
import SwinjectStoryboard

class SplashViewController: UIViewController, WebContentDelegate{
    func openLinkToNativePage(url: String) {
        
    }
    
    func gotoCart() {
        
    }
    
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorTitle: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryBtn: LoginButton!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoutBtn: UIButton!
    weak var viewLogin: LoginView?
    weak var viewOrgLists: WebContentPresenter?
    var presenter: SplashPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        presenter?.viewDidLoad()
        view.backgroundColor = UIColor.mtBrightWhite
    }
    
    func setupView() {
        view.backgroundColor = UIColor.mtBrightWhite
        errorTitle.font = UIFont.openSansBoldFontOfSize(size: 17)
        errorLabel.font = UIFont.openSansFontOfSize(size: 15)
        errorTitle.textColor = UIColor.white
        errorLabel.textColor = UIColor.white
        
        retryBtn.backgroundColor = UIColor.mtBrightOrange
        retryBtn.setTitleColourForAllStates(colour: UIColor.white)
        retryBtn.titleLabel?.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
        
        logoutBtn.setTitleColourForAllStates(colour: UIColor.white.withAlphaComponent(0.8))
        logoutBtn.titleLabel?.font = UIFont.openSansSemiBoldFontOfSize(size: 14)
    }
    
    @IBAction func retryBtnPressed(_ sender: Any) {
        presenter?.retryBtnPressed()
    }
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        presenter?.logoutBtnPressed()
    }
}

extension SplashViewController: SplashView {

    func setupNavigationFlow(state: SessionState, isAdmin: Bool?) {
        switch state {
        case .login:
            //Login
            guard let loginNC = storyboard?.instantiateViewController(withIdentifier: "loginNC") as? LoginNavigationController else { return }
            guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginViewController else { return }
            
            loginNC.setViewControllers([loginVC], animated: false)
            
            guard let appDelegate = UIApplication.shared.delegate else { return }
            appDelegate.window??.rootViewController = loginNC
            appDelegate.window??.makeKeyAndVisible()
        case .selectOrganisation:
            //Select Organisation
                if let savedHomeUrl = UserDefaults.standard.string(forKey: "homeUrl") {
                    self.changePageToWebContentHome(url: savedHomeUrl)
                }
            
        case .home:
            //Organisation Wrapper
//            guard let loginNC = storyboard?.instantiateViewController(withIdentifier: "loginNC") as? LoginNavigationController else { return }
//            guard let organisationsVC = storyboard?.instantiateViewController(withIdentifier: "webContentVC") as? WebContentViewController else { return }
//            loginNC.setViewControllers([organisationsVC], animated: false)
//            
//            guard let appDelegate = UIApplication.shared.delegate else { return }
//            appDelegate.window??.rootViewController = loginNC
//            appDelegate.window??.makeKeyAndVisible()
//                if let savedHomeUrl = UserDefaults.standard.string(forKey: "homeUrl") {
//                    organisationsVC.loadUrl(urlString: savedHomeUrl)
//                }
            if let savedHomeUrl = UserDefaults.standard.string(forKey: "homeUrl") {
                self.changePageToWebContentHome(url: savedHomeUrl)
            }
            else
            {
                guard let loginNC = storyboard?.instantiateViewController(withIdentifier: "loginNC") as? LoginNavigationController else { return }
                guard let organisationsVC = storyboard?.instantiateViewController(withIdentifier: "organisationsVC") as? OrganisationsViewController else { return }
                organisationsVC.isAdmin = isAdmin
                
                loginNC.setViewControllers([organisationsVC], animated: false)
                
                guard let appDelegate = UIApplication.shared.delegate else { return }
                appDelegate.window??.rootViewController = loginNC
                appDelegate.window??.makeKeyAndVisible()
            }
         }
    }
    
    func showErrorRefreshingOrganisation() {
        errorView.isHidden = false
    }
    
    func clearErrorRefreshingOrganisation() {
        errorView.isHidden = true
    }
    
    func toggleLoadingIndicator(show: Bool) {
        switch show {
        case true:
            loadingIndicator.startAnimating()
        case false:
            loadingIndicator.stopAnimating()
        }
    }
    func changePageToWebContentHome(url: String) {
        if let webContentVC = storyboard?.instantiateViewController(withIdentifier: "webContentVC") as? WebContentViewController {
            webContentVC.webContentEntry = WebContentItem(title: "", url: url, content: nil)
            webContentVC.isUrlWhileLoggedOut = false
            webContentVC.showCartBtn = false
            webContentVC.delegate = self
            guard let appDelegate = UIApplication.shared.delegate else { return }
            UIView.transition(with: appDelegate.window!!, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromRight, animations: {
                appDelegate.window??.rootViewController = webContentVC
                appDelegate.window??.makeKeyAndVisible()
            }, completion: nil)
        }
    }
}

extension SplashViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
