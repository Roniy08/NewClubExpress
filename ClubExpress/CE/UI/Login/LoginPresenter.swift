//
//  LoginPresenter.swift
// ClubExpress
//
// Created by Ronit on 05/06/2024.
//  
//

import Foundation

protocol LoginView: class {
    func showEnterDetailsPopup()
    func showErrorPopup(message: String)
    func toggleLoadingIndicator(show: Bool)
    func toggleLoginBtnEnabled(enabled: Bool)
    func toggleLoginBtnVisible(visible: Bool)
    func enterPasswordTextField()
    func showPreNotificationsPermissionPopup()
    func leavePasswordTextField()
    func openWebView(urlString: String)
    func pushToOrganisations()
//    func showFooterMessage(string: String)
//    func toggleFooterView(view: Bool)
//    func toggleFooterBtn(enabled: Bool)
    func toggleTextFieldsEnabled(enabled: Bool)
    func showInvalidEmailPopup()
    func prefillEmailAddressTF(email: String)
}

class LoginPresenter {
    weak var view: LoginView?
    fileprivate var interactor: LoginInteractor
    fileprivate var footerUrl = ""
    
    init(interactor: LoginInteractor) {
        self.interactor = interactor
    }
    
    func viewDidLoad() {
//        setDefaultFooterMessage()
//        getFooterMessage()
        getPreviouslyUsedEmailAddress()
    }
    
    func setDefaultFooterMessage() {
//        view?.toggleFooterView(view: false)
    }
    
    func getFooterMessage() {
//        interactor.getLoginFooterMessage().done { [weak self] footerMessage in
//            guard let weakSelf = self else { return }
//            if footerMessage.count > 0 {
//                weakSelf.view?.showFooterMessage(string: footerMessage)
//                weakSelf.view?.toggleFooterView(view: true)
//                weakSelf.setFooterUrl(message: footerMessage)
//            }
//        }.catch { error in
//            print(error.localizedDescription)
//        }
    }
    
    
    func loginBtnPressed(username: String, password: String) {
        guard username.count > 0, password.count > 0 else {
            view?.showEnterDetailsPopup()
            return
        }
        
        if !isEmailValid(email: username) {
            view?.showInvalidEmailPopup()
            return
        }
        
        login(username: username, password: password)
    }

    
    fileprivate func login(username: String, password: String) {
        view?.toggleTextFieldsEnabled(enabled: false)
        toggleLoginBtnLoading(loading: true)
        
//        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? ""

        interactor.login(username: username, password: password).done { [weak self] (_) in
            guard let weakSelf = self else { return }
            if MembershipAPIRouter.storeorgCount == 1
            {
                self?.getSessionTokn()
            }
            else{
                weakSelf.view?.pushToOrganisations()
            }
        }.catch { [weak self] (error) in
            guard let weakSelf = self else { return }
            
            var errorMessage = ""
            if let loginError = error as? LoginError {
                switch loginError {
                case .errorMessage(let message):
                    errorMessage = message
                default:
                    errorMessage = "Could not log in"
                }
            } else {
                errorMessage = "Could not log in"
            }
            weakSelf.view?.showErrorPopup(message: errorMessage)
            print(error.localizedDescription)
        }.finally { [weak self] in
            guard let weakSelf = self else { return }
            
            weakSelf.toggleLoginBtnLoading(loading: false)
            weakSelf.view?.toggleTextFieldsEnabled(enabled: true)
        }
    }
    
    fileprivate func toggleLoginBtnLoading(loading: Bool) {
        switch loading {
        case true:
            view?.toggleLoadingIndicator(show: true)
            view?.toggleLoginBtnEnabled(enabled: false)
            view?.toggleLoginBtnVisible(visible: false)
        case false:
            view?.toggleLoadingIndicator(show: false)
            view?.toggleLoginBtnEnabled(enabled: true)
            view?.toggleLoginBtnVisible(visible: true)
        }
    }
    func getSessionTokn()
    {
            interactor.exchangeToken(tokenstrs: MembershipAPIRouter.tempSessionTokenStr!).done  { [weak self] (_) in
                guard let weakSelf = self else { return }
                //here home screen
                print("here home screen")
                weakSelf.view?.openWebView(urlString: MembershipAPIRouter.homeURLStr!)
                self!.configureNotifications()
            }.catch { [weak self] (error) in
                guard let weakSelf = self else { return }
                
                var errorMessage = ""
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .errorMessage(let message):
                        errorMessage = message
                    default:
                        errorMessage = "Could not log in"
                    }
                } else {
                    errorMessage = "Could not log in"
                }
                weakSelf.view?.showErrorPopup(message: errorMessage)
                print(error.localizedDescription)
            }.finally { [weak self] in
                guard let weakSelf = self else { return }
                
                weakSelf.toggleLoginBtnLoading(loading: false)
                weakSelf.view?.toggleTextFieldsEnabled(enabled: true)
            }

    }
    func configureNotifications() {
        NotificationsPermissionUtil.getNotificationsAuthorizationStatus { (status) in
            DispatchQueue.main.async {
                if status == .notDetermined {
                    //ask first time popup
                    let askedToEnableNotifications = self.interactor.hasAskedEnableNotificationsPopup()
                    if askedToEnableNotifications == false {
                        self.view?.showPreNotificationsPermissionPopup()
                        self.view?.showEnterDetailsPopup()
                        self.interactor.setAskedEnableNotificationsPopup(shown: true)
                    }
                } else if status == .authorized {
                    //re-register device after logging in
                    self.registerDeviceForNotifications()
                }
            }
        }
    }
    func respondedToNotificationsPermissionPopup(success: Bool) {
        print("notifications permission: \(success)")
        
        switch success {
        case true:
            registerDeviceForNotifications()
        case false:
            break
        }
    }
    
    fileprivate func registerDeviceForNotifications() {
        interactor.registerDeviceForPushNotifications().done { response in
        }.catch { error in
            print(error)
        }
    }
    func emailTFReturned() {
        view?.enterPasswordTextField()
    }
    
    func passwordTFReturned() {
        
        view?.leavePasswordTextField()
    }
    
    func footerBtnPressed() {
        view?.openWebView(urlString: footerUrl)
    }
    
    fileprivate func setFooterUrl(message: String) {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        guard let detect = detector else { return }
        let matches = detect.matches(in: message, options: [], range: NSRange(location: 0, length: message.count))
        if let firstMatch = matches.first {
            guard let range = Range(firstMatch.range, in: message) else { return }
            let url = message[range]
            self.footerUrl = String(url)
//            view?.toggleFooterBtn(enabled: true)
        } else {
            self.footerUrl = ""
//            view?.toggleFooterBtn(enabled: false)
        }
    }
    
    fileprivate func isEmailValid(email: String) -> Bool {
        return email.contains("@")
    }
    
    fileprivate func getPreviouslyUsedEmailAddress() {
        if let emailAddress = interactor.getPreviouslyUsedEmailAddress() {
            view?.prefillEmailAddressTF(email: emailAddress)
            view?.enterPasswordTextField()
        }
    }
}
