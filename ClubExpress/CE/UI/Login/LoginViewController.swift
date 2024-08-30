//
//  LoginViewController.swift
// ClubExpress
//
// Created by Ronit on 05/06/2024.
//  
//

import UIKit
import Security
import Foundation
import LocalAuthentication
class LoginViewController: UIViewController {
    var presenter: LoginPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    fileprivate var screenTapGesture: UITapGestureRecognizer?
    var isCheckEnabled = false
    var isLoginEnabled = false
    @IBOutlet weak var emailTF: LoginTextField!
    
    @IBOutlet weak var cancelBtn: LoginButton!
    @IBOutlet weak var passwordTF: LoginTextField!
    @IBOutlet weak var loginBtn: LoginButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var scrollViewBottomConstrait: NSLayoutConstraint!
//    @IBOutlet weak var footerTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var footerBtn: UIButton!
    var isauthResult = false
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addScreenTapGesture()
        presenter?.viewDidLoad()
    }
    @IBAction func btnCancel(_ sender: Any) {
    }
    func didReceiveData(data: String) {
            // Use the received data
            print(data)
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
 /*   func verifyUser()
    {
        // Set AllowableReuseDuration in seconds to bypass the authentication when user has just unlocked the device with biometric
        //        BioMetricAuthenticator.shared.allowableReuseDuration = 30
        // start authentication
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { [weak self] (result) in
                
            switch result {
            case .success( _):
                
                // authentication successful
                print("success")
                if let (retrievedEmail, retrievedPassword) = KeychainManager.shared.getCredentialsFromKeychain(email: self!.emailTF.text!), let userAuth = UserDefaults.standard.value(forKey: "authTheUser") as? Bool, userAuth  == true {
//                    print("Retrieved email: \(retrievedEmail), password: \(retrievedPassword)")
                    MembershipAPIRouter.isUserBiometricSaved = true
                    self!.presenter?.loginBtnPressed(username: self!.emailTF.text!, password: retrievedPassword)

                }
                else
                {
                    self!.showAlertPopup(title: "Alert", message: "there is no any Email and Password is present for login")
                }
                
            case .failure(let error):
                
                switch error {
                    
                // device does not support biometric (face id or touch id) authentication
                case .biometryNotAvailable:
                    self!.showAlertPopup(title: "Alert", message: error.message())
                    
                // No biometry enrolled in this device, ask user to register fingerprint or face
                case .biometryNotEnrolled:
                    self?.showGotoSettingsAlert(message: error.message())
                    
                // show alternatives on fallback button clicked
                case .canceledBySystem:
                    print("canceled by system")
                    break
                    
                case .passcodeNotSet:
                    self!.showAlertPopup(title: "Alert", message: error.message())
                    break
                    
                case .fallback:
                    self!.showAlertPopup(title: "Alert", message: "Biometric is locked out now, because there were too many failed attempts.")
                    
                    // Biometry is locked out now, because there were too many failed attempts.
                // Need to enter device passcode to unlock.
                case .biometryLockedout:
                    self?.showPasscodeAuthentication(message: error.message())
                    
                // do nothing on canceled by system or user
                case .canceledByUser:
                    print("canceled by user")
                    break
                    
                // show error for any other reason
                default:
                    self!.showAlertPopup(title: "Error", message: error.message())
                }
            }
        }
    }*/
    func isBiometricAuthenticationEnabled() -> Bool {
        let context = LAContext()
        var error: NSError?
        let isBiometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        if let error = error {
            print("Error checking biometric availability: \(error.localizedDescription)")
        }

        return isBiometricAvailable
    }
    @IBAction func btnAuthClick(_ sender: Any) {
//        if isBiometricAuthenticationEnabled() {
//            print("biometric is on")
//            if isCheckEnabled == true && lblAuthTitle.text!.contains("Login with ")
//            {
//                if let (retrievedEmail, retrievedPassword) = KeychainManager.shared.getCredentialsFromKeychain(email: emailTF.text!) {
////                    print("Retrieved email: \(retrievedEmail), password: \(retrievedPassword)")
////                    self.verifyUser()
//                }
//                else
//                {
//                    self.showAlertPopup(title: "Alert", message: "there is no any Email and Password is present for login")
//                }
//            }
//            else
//            {
//                if isLoginEnabled == true
//                {
////                    self.authDefaults.set(false, forKey: "authTheUser")
////                    self.authDefaults.synchronize()
//                    isauthResult = false
//                    isLoginEnabled = false
////                    if BioMetricAuthenticator.shared.faceIDAvailable() {
////                        self.lblAuthTitle.text = "Enable Face ID"
////                    }
////                    else
////                    {
////                        self.lblAuthTitle.text = "Enable Touch ID"
////                    }
//                   
//                    self.imgCheck.image = UIImage(named: "icUncheck")
//                }
//                else
//                {
////                    self.enableAuth()
//                }
//            }
//        }
//        else
//        {
//            self.showGotoSettingsLogin(message: "biometric is off, enable from settings for login")
//        }
       
    }
  /*  func enableAuth()
    {
        // Set AllowableReuseDuration in seconds to bypass the authentication when user has just unlocked the device with biometric
//        BioMetricAuthenticator.shared.allowableReuseDuration = 30
        
        // start authentication
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { [weak self] (result) in
                
            switch result {
            case .success( _):
                
                // authentication successful
               // call login api()
                if self!.isLoginEnabled == true
                {
//                    self!.authDefaults.set(true, forKey: "authTheUser")
//                    self!.authDefaults.synchronize()
                    self!.isauthResult = true
                    self!.isCheckEnabled = true
                   
                }
                else
                {
                    self!.isLoginEnabled = true
//                    self!.authDefaults.set(true, forKey: "authTheUser")
//                    self!.authDefaults.synchronize()
                    self!.isauthResult = true
                    self!.imgCheck.image = UIImage(named: "icCheckMark")
                }
                print("success auth")
                

            case .failure(let error):
                
                switch error {
                    
                // device does not support biometric (face id or touch id) authentication
                case .biometryNotAvailable:
                    self!.showAlertPopup(title: "Alert", message: error.message())
                    
                // No biometry enrolled in this device, ask user to register fingerprint or face
                case .biometryNotEnrolled:
                    self?.showGotoSettingsAlert(message: error.message())
                    
                // show alternatives on fallback button clicked
                case .canceledBySystem:
                    print("canceled by system")
                    break
                    
                case .passcodeNotSet:
                    self!.showAlertPopup(title: "Alert", message: error.message())
                    break
                    
                case .fallback:
                    self!.showAlertPopup(title: "Alert", message: "Biometric is locked out now, because there were too many failed attempts.")
                    
                    // Biometry is locked out now, because there were too many failed attempts.
                // Need to enter device passcode to unlock.
                case .biometryLockedout:
                    self?.showPasscodeAuthentication(message: error.message())
                    
                // do nothing on canceled by system or user
                case .canceledByUser:
                    print("canceled by user")
                    self!.imgCheck.image = UIImage(named: "icUncheck")
                    self!.isCheckEnabled = false
                    self!.isLoginEnabled = false
                    if BioMetricAuthenticator.shared.faceIDAvailable() {
                        // device supports face id recognition.
                        self!.lblAuthTitle.text = "Enable Face ID"
                    }
                    else
                    {
                        self!.lblAuthTitle.text = "Enable Touch ID"
                    }
//                    self!.authDefaults.set(false, forKey: "authTheUser")
//                    self!.authDefaults.synchronize()
                    self!.isauthResult = false
                    break
                    
                // show error for any other reason
                default:
                    self!.showAlertPopup(title: "Error", message: error.message())
                }
            }
        }
    }*/
    // show passcode authentication
//    func showPasscodeAuthentication(message: String) {
//        
//        BioMetricAuthenticator.authenticateWithPasscode(reason: message) { [weak self] (result) in
//            switch result {
//            case .success( _):
////                self!.authDefaults.set(true, forKey: "authTheUser")
////                self!.authDefaults.synchronize()
//                self!.isauthResult = true
//                self!.imgCheck.image = UIImage(named: "icCheckMark")
//                if BioMetricAuthenticator.shared.faceIDAvailable() {
//                    self!.lblAuthTitle.text = "Login with Face ID"
////                    self!.lblAuthTitle.textColor = UIColor.white
////                    self!.lblAuthTitle.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
//                    self!.authLoginBtn.setTitle("Login with Face ID", for: .normal)
////                    self!.loginAuthBtn.setTitle("Login with Face ID", for: .normal)
//                }
//                else
//                {
//                    self!.lblAuthTitle.text = "Login with Touch ID"
//                    self!.authLoginBtn.setTitle("Login with Touch ID", for: .normal)
////                    self!.lblAuthTitle.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
////                    self!.loginAuthBtn.setTitle("Login with Touch ID", for: .normal)
//                }
//                self!.isLoginEnabled = true
//                guard let username = self!.emailTF.text, let password = self!.passwordTF.text else { return }
//                MembershipAPIRouter.isUserBiometricSaved = self!.isauthResult
//                self!.presenter?.loginBtnPressed(username: username, password: password)
//            case .failure(let error):
//                self!.showAlertPopup(title: "Error", message: error.message())
//                print(error.message())
//            }
//        }
//    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func setupView() {
        view.backgroundColor = UIColor.mtBrightWhite
        emailTF.backgroundColor = UIColor.white
        passwordTF.backgroundColor = UIColor.white
        emailTF.tintColor = UIColor.mtBrandBlueDark
        passwordTF.tintColor = UIColor.mtBrandBlueDark
        loginBtn.setTitleColourForAllStates(colour: UIColor.white)
//        footerView.backgroundColor = UIColor.mtBrightWhite
//        footerTextView.textColor = UIColor.black
        emailTF.font = UIFont.openSansFontOfSize(size: 15)
        passwordTF.font = UIFont.openSansFontOfSize(size: 15)
        loginBtn.titleLabel?.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
        emailTF.font = UIFont.openSansFontOfSize(size: 15)
        passwordTF.font = UIFont.openSansFontOfSize(size: 15)
        emailTF.textColor = UIColor.black
        passwordTF.textColor = UIColor.black
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func addScreenTapGesture() {
        screenTapGesture = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        view?.addGestureRecognizer(screenTapGesture!)
    }
    
    fileprivate func scrollToBottom() {
        if scrollView.contentSize.height > scrollView.frame.height {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.frame.height), animated: true)
        }
    }
    
    @objc func screenTapped(gesture: UITapGestureRecognizer) {
        if emailTF.isFirstResponder {
            emailTF.resignFirstResponder()
            scrollView.setContentOffset(CGPoint(x: 0, y: -10), animated: true)
        } else if passwordTF.isFirstResponder {
            passwordTF.resignFirstResponder()
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
//        if let organisationsVC = storyboard?.instantiateViewController(withIdentifier: "groupVC") as? SelectOrganisationController {
//            navigationController?.setViewControllers([organisationsVC], animated: true)
//        }
        guard let username = emailTF.text, let password = passwordTF.text else { return }
            presenter?.loginBtnPressed(username: username, password: password)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
            let animationOptions: UIView.AnimationOptions = [UIView.AnimationOptions(rawValue: curve), .beginFromCurrentState]
            if passwordTF.isFirstResponder
            {
                
                UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
                    let keyboardHeight = keyboardSize.height + 5
                    self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight , right: 0)
                    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
                    self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    self.scrollToBottom()
                })
            }
            else
            {
                UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
                    self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0 , right: 0)
                    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
                    self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    self.scrollToBottom()
                })
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
            let animationOptions: UIView.AnimationOptions = [UIView.AnimationOptions(rawValue: curve), .beginFromCurrentState]
            let keyboardHeight = keyboardSize.height - 5
            if passwordTF.isFirstResponder
            {
                
                UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
                    self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
                    self.view.layoutIfNeeded()
                }, completion: { (completed) in
//                    self.scrollToBottom()
                })
            }
            else
            {
                UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
                    self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom:keyboardHeight, right: 0)
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    self.view.layoutIfNeeded()
                }, completion: { (completed) in
//                    self.scrollToBottom()
                })
            }
            
        }
    }
    
    @IBAction func footerBtnPressed(_ sender: Any) {
        presenter?.footerBtnPressed()
    }
    
    
   
}


extension LoginViewController: LoginView {
    func toggleLoadingIndicator(show: Bool) {
        if show {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    func toggleLoginBtnEnabled(enabled: Bool) {
        loginBtn.isEnabled = enabled
    }
    
    func toggleLoginBtnVisible(visible: Bool) {
        loginBtn.isHidden = !visible
    }
    
    func showEnterDetailsPopup() {
        showAlertPopup(title: "Enter Details", message: "Enter Email Address and Password and try again.")
    }
    
    func showErrorPopup(message: String) {
        showAlertPopup(title: "Login Error", message: message)
    }
    
    func enterPasswordTextField() {
        view.layoutIfNeeded()
        passwordTF.becomeFirstResponder()
    }
    
    func leavePasswordTextField() {
        self.view.layoutIfNeeded()
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        passwordTF.resignFirstResponder()
    }
    // use this to open url ....... for home screen
    func openWebView(urlString: String) {
        navigationController?.setNavigationBarHidden(true, animated: true)

        if let webContentVC = storyboard?.instantiateViewController(withIdentifier: "webContentVC") as? WebContentViewController {
            webContentVC.webContentEntry = WebContentItem(title: "", url: urlString, content: nil)
            webContentVC.isUrlWhileLoggedOut = false
            webContentVC.showCartBtn = false
            webContentVC.delegate = self
            navigationController?.pushViewController(webContentVC, animated: true)
        }
    }
    
    func pushToOrganisations() {
        if let organisationsVC = storyboard?.instantiateViewController(withIdentifier: "organisationsVC") as? OrganisationsViewController {
            navigationController?.setViewControllers([organisationsVC], animated: true)
        }
    }
    
    func toggleFooterView(view: Bool) {
        switch view {
        case true:
            footerView.isHidden = false
        case false:
            footerView.isHidden = true
        }
    }
    func showPreNotificationsPermissionPopup() {
        let notificationsAlertVC = UIAlertController(title: "Enable Notifications?", message: "Do you want to enable push notifications to receive updates from your organizations?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            NotificationsPermissionUtil.showNotificationsPermissionPopup(callback: { (success) in
                self.presenter?.respondedToNotificationsPermissionPopup(success: success)
            })
        }
        notificationsAlertVC.addAction(yesAction)
        let noAction = UIAlertAction(title: "Not now", style: .cancel) { (action) in
            
        }
        notificationsAlertVC.addAction(noAction)
        notificationsAlertVC.preferredAction = yesAction
        present(notificationsAlertVC, animated: true, completion: nil)
    }
    func toggleFooterBtn(enabled: Bool) {
//        switch enabled {
//        case true:
//            footerBtn.isEnabled = true
//            footerBtn.isHidden = false
//        case false:
//            footerBtn.isEnabled = false
//            footerBtn.isHidden = true
//        }
    }
    
    func showFooterMessage(string: String) {
//        let fontName = UIFont.openSansFontOfSize(size: 15).fontName
//        let fontColour = "#DFDFDF"
//        let linkColour = "#FF6602"
//        
//        var html = string
//        let css = "<style>body { color: \(fontColour); font-family: \(fontName); font-size: 15; } a { color: \(linkColour); }</style>"
//        html += css
//        
//        let data = Data(html.utf8)
//        if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
//            footerTextView.linkTextAttributes = [.foregroundColor: UIColor.mtBrightOrange]
//            
//            footerTextView.attributedText = attributedString
//        }
    }
    
    func toggleTextFieldsEnabled(enabled: Bool) {
        switch enabled {
        case true:
            emailTF.isEnabled = true
            passwordTF.isEnabled = true
        case false:
            emailTF.isEnabled = false
            passwordTF.isEnabled = false
        }
    }
    
    func showInvalidEmailPopup() {
        showAlertPopup(title: "Invalid Email", message: "Please enter a valid Email Address and try again")
    }
    
    func prefillEmailAddressTF(email: String) {
        emailTF.text = email
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTF.isFirstResponder {
            presenter?.emailTFReturned()
        } else if passwordTF.isFirstResponder {
            presenter?.passwordTFReturned()
            
            //run login
            guard let username = emailTF.text, let password = passwordTF.text else { return true }
            MembershipAPIRouter.isUserBiometricSaved = self.isauthResult
            presenter?.loginBtnPressed(username: username, password: password)
        }
        return true
    }
}

extension LoginViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension LoginViewController: WebContentDelegate {
    func openLinkToNativePage(url: String) {
        let endpoint = NavigationUtil().getEndpointAfterScheme(url: url)
        if endpoint == "logout" {
            //close webview and return to login
            if navigationController?.visibleViewController is WebContentViewController {
                navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func gotoCart() { }
}
extension LoginViewController {
    
    func showGotoSettingsAlert(message: String) {
        let settingsAction = UIAlertAction(title: "Go to settings", style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    func showGotoSettingsLogin(message: String) {
        let settingsAction = UIAlertAction(title: "Go to settings", style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
