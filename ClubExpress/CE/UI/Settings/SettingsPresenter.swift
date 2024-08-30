//
//  SettingsPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 18/02/2019.
//  
//

import Foundation
import UIKit
import LocalAuthentication
protocol PresenterDelegate: class {
    func onDataReceived(data: [[String:String]])
    func showGotoSettingsAlert(message:String)
    func showGotoSettings(message:String)
    func showAlertMessage(title: String,message: String)
}
protocol SettingsView: class {
    func setSections(sections: Array<SettingsSection>)
    func presentWebView(webContentEntry: WebContentItem)
    func showLogoutPopup()
    func showServerSwitchActionSheet()
    func gotoLogout()
    func sendSwapOrgEvent()
    func setFooterString(string: String)
    func showNotificationsToggleError()
    func showNotificationsPermissionPopup()
    func showNotificationsDeniedPopup()
    func addAppDidBecomeActiveNotification()
}

class SettingsPresenter{
    weak var view: SettingsView?
    fileprivate var interactor: SettingsInteractor
    var sections = Array<SettingsSection>()
    var notificationsEnabled = false
    var setAuthUserEnabled :Bool = false
    var authDefaults = UserDefaults.standard
    weak var delegate: PresenterDelegate?
    var versionString = ""

    init(interactor: SettingsInteractor) {
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        setVersionString()
        if let userAuth = UserDefaults.standard.value(forKey: "authTheUser") as? Bool, userAuth == true {
           print("key is present")
            self.setAuthUserEnabled = true
        } else {
            print("key is not present")
            self.setAuthUserEnabled = false
        }
        getNotificationsEnabledState() {
            self.buildSections()
        }
        if isBiometricAuthenticationEnabled() {
            print("biometric is on")
        }
        else
        {
            self.setAuthUserEnabled = false
        }
        view?.addAppDidBecomeActiveNotification()
    }
    // send value from here to settings view controller
    func getUserEndPoints()
    {
        let session = interactor.getSession()
        let userInf = session.userInfo
        if userInf?.mtkAdmin == true
        {
            delegate?.onDataReceived(data: (userInf?.end_point)!)
        }
        
    }
    func isBiometricAuthenticationEnabled() -> Bool {
        let context = LAContext()
        var error: NSError?
        let isBiometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        if let error = error {
            print("Error checking biometric availability: \(error.localizedDescription)")
        }

        return isBiometricAvailable
    }
    fileprivate func buildSections() {
        var sections = Array<SettingsSection>()

        let session = interactor.getSession()
        var userInf = session.userInfo
        let settingsMenuEntries = session.settingsEntries ?? []
//        print(userInf?.end_point)
        //Create section for items from organisation settings menu
        let organisationItems = settingsMenuEntries.map { (entry) -> SettingsItem in
            let urlString = entry.url ?? ""
            return SettingsItem(title: entry.label, type: .webUrl(url: urlString), accessoryType: .arrow, textStyle: .normal)
        }
        let organisationSection = SettingsSection(items: organisationItems)
        sections.append(organisationSection)
        
        //Add on app generic items
        var appItems = Array<SettingsItem>()
        
        let notificationsItem = SettingsItem(title: "Allow Notifications", type: .toggleNotifications(enabled: notificationsEnabled), accessoryType: .toggleSwitch, textStyle: .normal)
        appItems.append(notificationsItem)
        if let userAuth = UserDefaults.standard.value(forKey: "authTheUser") as? Bool, userAuth == true {
//            if BioMetricAuthenticator.shared.faceIDAvailable() {
//                    // device supports face id recognition.
//                    let authItem = SettingsItem(title: "Face ID", type: .toggleAuth(enabled: setAuthUserEnabled), accessoryType: .toggleSwitch, textStyle: .normal)
//                    appItems.append(authItem)
//                }
//                else
//                {
//                    let authItem = SettingsItem(title: "Touch ID", type: .toggleAuth(enabled: setAuthUserEnabled), accessoryType: .toggleSwitch, textStyle: .normal)
//                    appItems.append(authItem)
//                }
        }
        else
        {
//            let authItem = SettingsItem(title: "Touch ID", type: .toggleAuth(enabled: setAuthUserEnabled), accessoryType: .toggleSwitch, textStyle: .normal)
//            appItems.append(authItem)
        }
        
        let hasMultipleOrganisations = session.hasMultipleOrganisations ?? false
        if hasMultipleOrganisations {
            let switchOrganisationItem = SettingsItem(title: "Change Organization", type: .changeOrganisation, accessoryType: .arrow, textStyle: .normal)
            appItems.append(switchOrganisationItem)
        }
        if userInf?.mtkAdmin == true
        {
                let changeServer = SettingsItem(title: "Change Server", type: .changeServer, accessoryType: .arrow, textStyle: .normal)
                appItems.append(changeServer)

        }
        let logoutItem = SettingsItem(title: "Log Out", type: .logOut, accessoryType: .nothing, textStyle: .destructive)
        appItems.append(logoutItem)
        
        let appItemsSection = SettingsSection(items: appItems)
        sections.append(appItemsSection)
        
        self.sections = sections
        view?.setSections(sections: self.sections)
    }
    
    fileprivate func setVersionString() {
        let session = interactor.getSession()
        var userInf = session.userInfo
        let versionNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "0"
        let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? "0"
//        \\ change build version of test build version when upload new build
        if userInf?.mtkAdmin == true
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM"
            let currentDateString = dateFormatter.string(from: Date())
            versionString = "Version: \(versionNumber) | Build \(buildNumber) | Build Date \(currentDateString)-\(SDKConstants.buildDate)" + "-(\(SDKConstants.testBuildVersion))" + "\n\(SDKConstants.sdkVersion)"
//                                                                  year and month and date
        }
        else
        {
            versionString = "Version \(versionNumber) | Build \(buildNumber)"
        }
        print(versionString)
        view?.setFooterString(string: versionString)
    }
    
    func itemPressed(item: SettingsItem) {
        if let type = item.type {
            switch type {
            case .webUrl(let url):
                let title = item.title ?? ""
                let webContentEntry = WebContentItem(title: title, url: url, content: nil)
                view?.presentWebView(webContentEntry: webContentEntry)
            case .changeOrganisation:
                view?.sendSwapOrgEvent()
            case .changeServer:
                view?.showServerSwitchActionSheet()
            case .logOut:
                view?.showLogoutPopup()
            default: break
            }
        }
    }
    
    func toggleSwitched(item: SettingsItem, enabled: Bool) {
        guard let itemType = item.type else { return }
        if case .toggleNotifications = itemType {
            if enabled {
                NotificationsPermissionUtil.getNotificationsAuthorizationStatus { (status) in
                    DispatchQueue.main.async {
                        if status == .notDetermined {
                            self.view?.showNotificationsPermissionPopup()
                        } else if status == .authorized {
                            self.toggleNotifications()
                        } else if status == .denied {
                            self.view?.showNotificationsDeniedPopup()
                            
                            self.notificationsEnabled = false
                            self.returnNotificationsSwitch(enabled: self.notificationsEnabled)
                        }
                    }
                }
            } else {
                toggleNotifications()
            }
        }
        else if case .toggleAuth = itemType
        {
            if isBiometricAuthenticationEnabled() {
                if enabled{
                    if let userAuth = UserDefaults.standard.value(forKey: "authTheUser") as? Bool, userAuth  == true
                    {
                        self.authDefaults.set(false, forKey: "authTheUser")
//                        self.authDefaults.set(false, forKey: "authSwitch")
                        self.authDefaults.synchronize()
                        self.setAuthUserEnabled = false
                    }
                    else
                    {
//                        self.enableAuth()
                    }
                   
                }
                else{
                    self.authDefaults.set(false, forKey: "authTheUser")
//                    self.authDefaults.set(false, forKey: "authSwitch")
                    self.authDefaults.synchronize()
                    setAuthUserEnabled = false
                }
            } else {
                print("Biometric authentication is disabled")
                delegate?.showGotoSettings(message: "biometric is off, turn on from settings")
                self.setAuthUserEnabled = false
                self.viewDidLoad()
            }

        }
    }
//    func enableAuth()
//    {
//        // Set AllowableReuseDuration in seconds to bypass the authentication when user has just unlocked the device with biometric
////        BioMetricAuthenticator.shared.allowableReuseDuration = 30
//        
//        // start authentication
//        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { [weak self] (result) in
//                
//            switch result {
//            case .success( _):
//                
//                // authentication successful
//               // call login api()
//                print("success")
//                self!.authDefaults.set(true, forKey: "authTheUser")
////                self!.authDefaults.set(true, forKey: "authSwitch")
//                self!.authDefaults.synchronize()
//                self!.setAuthUserEnabled = true
//            case .failure(let error):
//                
//                switch error {
//                    
//                // device does not support biometric (face id or touch id) authentication
//                case .biometryNotAvailable:
////                    self!.showAlertPopup(title: "Alert", message: error.message())
//                    self!.delegate?.showGotoSettingsAlert(message: error.message())
//                    
//                // No biometry enrolled in this device, ask user to register fingerprint or face
//                case .biometryNotEnrolled:
//                    self!.delegate!.showGotoSettingsAlert(message: error.message())
//                    
//                // show alternatives on fallback button clicked
//                case .canceledBySystem:
//                    print("canceled by system")
//                    break
//                    
//                case .passcodeNotSet:
////                    self!.showAlertPopup(title: "Alert", message: error.message())
//                    self!.delegate?.showAlertMessage(title: "alert", message: error.message())
//                    break
//                    
//                case .fallback:
//                    self!.delegate?.showAlertMessage(title: "alert", message: "Biometric is locked out now, because there were too many failed attempts")
//                    // Biometry is locked out now, because there were too many failed attempts.
//                // Need to enter device passcode to unlock.
//                case .biometryLockedout:
//                    self?.showPasscodeAuthentication(message: error.message())
//                    
//                // do nothing on canceled by system or user
//                case .canceledByUser:
//                    print("canceled by user")
//                    break
//                    
//                // show error for any other reason
//                default:
//                    self!.delegate?.showAlertMessage(title: "alert", message: error.message())
//                }
//            }
//        }
//    }
    // show passcode authentication
///    func showPasscodeAuthentication(message: String) {
//        
//        BioMetricAuthenticator.authenticateWithPasscode(reason: message) { [weak self] (result) in
//            switch result {
//            case .success( _):
//                self!.authDefaults.set(true, forKey: "authTheUser")
//                self!.authDefaults.synchronize()
//            case .failure(let error):
//                print(error.message())
//            }
//        }
//    }
    func logoutConfirmed() {
        view?.gotoLogout()
    }
    
    fileprivate func getNotificationsEnabledState(completion: @escaping () -> Void) {
        NotificationsPermissionUtil.getNotificationsAuthorizationStatus { (status) in
            DispatchQueue.main.async {
                if status == .notDetermined {
                    self.notificationsEnabled = false
                } else if status == .denied {
                    self.notificationsEnabled = false
                } else if status == .authorized {
                    let enabledState = self.interactor.getNotificationsEnabledState()
                    self.notificationsEnabled = enabledState
                }
                
                completion()
            }
        }
    }
    
    func updateSectionsWithNotifcationState(enabled: Bool) {
        for section in sections {
            for item in section.items {
                guard let type = item.type else { return }
                if case .toggleNotifications = type {
                    item.type = .toggleNotifications(enabled: enabled)
                }
            }
        }
        view?.setSections(sections: self.sections)
    }
    
    func returnNotificationsSwitch(enabled: Bool) {
        view?.setSections(sections: self.sections)
    }
    
    func respondedToNotificationsPermissionPopup(success: Bool) {
        print("notifications permission: \(success)")
        
        switch success {
        case true:
            toggleNotifications()
        case false:
           returnNotificationsSwitch(enabled: false)
        }
    }
    
    func toggleNotifications() {
        notificationsEnabled = !notificationsEnabled
        
        interactor.toggleNotifications().done { [weak self] (response) in
            guard let weakSelf = self else { return }
            if let success = response.success {
                if success == true {
                    weakSelf.updateSectionsWithNotifcationState(enabled: weakSelf.notificationsEnabled)
                    return
                }
            }
            weakSelf.view?.showNotificationsToggleError()
            weakSelf.returnNotificationsSwitch(enabled: !weakSelf.notificationsEnabled)
        }.catch { [weak self] error in
            guard let weakSelf = self else { return }
            weakSelf.view?.showNotificationsToggleError()
            weakSelf.returnNotificationsSwitch(enabled: !weakSelf.notificationsEnabled)
        }
    }
    
    func appDidBecomeActive() {
        getNotificationsEnabledState() {
            self.buildSections()
        }
    }
}
