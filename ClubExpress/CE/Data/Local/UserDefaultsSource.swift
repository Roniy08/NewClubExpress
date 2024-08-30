//
//  UserDefaultsSource.swift
// ClubExpress
//
// Created by Ronit on 05/06/2024.
//  
//

import Foundation

protocol UserDefaultsSource {
    func getSessionToken() -> String?
    func setSessionToken(sessionToken: String)
    func clearSessionToken()
    func hasMultipleOrganisations() -> Bool
    func setMultipleOrganisations(hasMultipleOrganisations: Bool)
    func clearHasMultipleOrganisations()
    func hasSwitchOrganisationPopupShown() -> Bool
    func setShownSwitchOrganisationPopup(shownSwitchOrganisationPopup: Bool)
    func hasCloseFiltersConfirmPopupShown() -> Bool    
    func setShownCloseFiltersConfirmPopup(shownCloseFiltersConfirmPopup: Bool)
    func getDisabledCalendarIDs() -> Set<String>
    func addDisabledCalendarID(id: String)
    func removeDisabledCalendarID(id: String)
    func clearDisabledCalendarIDs()
    func setNotificationsToken(token: String)
    func clearNotificationsToken()
    func getNotificationsToken() -> String?
    func setDeviceName(name: String)
    func clearDeviceName()
    func getDeviceName() -> String
    func setEmailAddress(email: String)
    func clearEmailAddress()
    func getEmailAddress() -> String?
    func setAskedEnableNotificationsPopup(shown: Bool)
    func clearAskedEnableNotificationsPopup()
    func hasAskedEnableNotificationsPopup() -> Bool
}

class UserDefaultsSourceImpl: UserDefaultsSource {
    
    fileprivate let sessionTokenKey = "sessionToken"
    fileprivate let hasMultipleOrganisationsKey = "hasMultipleOrganisations"
    fileprivate let hasSwitchOrganisationPopupShownKey = "hasSwitchOrganisationPopupShown"
    fileprivate let hasCloseFiltersConfirmPopupShownKey = "hasShownCloseFiltersConfirmPopup"
    fileprivate let disabledCalendarIDsKey = "disabledCalendarIDsKey"
    fileprivate let notificationsTokenKey = "notificationsToken"
    fileprivate let deviceNameKey = "deviceName"
    fileprivate let emailAddressKey = "emailAddress"
    fileprivate let askedEnableNotificationsPopupKey = "askedEnableNotificationsPopup"
    
    //Session Token
    func getSessionToken() -> String? {
        if let sessionToken = UserDefaults.standard.value(forKey: sessionTokenKey) as? String {
            return sessionToken
        }
        
        return nil
    }
    
    func setSessionToken(sessionToken: String) {
        UserDefaults.standard.set(sessionToken, forKey: sessionTokenKey)
    }
    
    func clearSessionToken() {
        UserDefaults.standard.removeObject(forKey: sessionTokenKey)
    }
    
    //Has Multiple Organisations
    func hasMultipleOrganisations() -> Bool {
        if let hasMultipleOrganisations = UserDefaults.standard.value(forKey: hasMultipleOrganisationsKey) as? Bool {
            return hasMultipleOrganisations
        }
        
        return false
    }
    
    func setMultipleOrganisations(hasMultipleOrganisations: Bool) {
        UserDefaults.standard.set(hasMultipleOrganisations, forKey: hasMultipleOrganisationsKey)
    }
    
    func clearHasMultipleOrganisations() {
        UserDefaults.standard.removeObject(forKey: hasMultipleOrganisationsKey)
    }
    
    //Has Switch Organisation Popup Shown
    func hasSwitchOrganisationPopupShown() -> Bool {
        if let hasSwitchOrganisationPopupShown = UserDefaults.standard.value(forKey: hasSwitchOrganisationPopupShownKey) as? Bool {
            return hasSwitchOrganisationPopupShown
        }
        
        return false
    }
    
    func setShownSwitchOrganisationPopup(shownSwitchOrganisationPopup: Bool) {
        UserDefaults.standard.set(shownSwitchOrganisationPopup, forKey: hasSwitchOrganisationPopupShownKey)
    }
    
    //Has Cancel Filters Confirm Popup Shown
    func hasCloseFiltersConfirmPopupShown() -> Bool {
        if let hasCloseFiltersConfirmPopupShown = UserDefaults.standard.value(forKey: hasCloseFiltersConfirmPopupShownKey) as? Bool {
            return hasCloseFiltersConfirmPopupShown
        }
        
        return false
    }
    
    func setShownCloseFiltersConfirmPopup(shownCloseFiltersConfirmPopup: Bool) {
        UserDefaults.standard.set(shownCloseFiltersConfirmPopup, forKey: hasCloseFiltersConfirmPopupShownKey)
    }
    
    //Disabled Calendars
    func getDisabledCalendarIDs() -> Set<String> {
        if let disabledCalendarIDs = UserDefaults.standard.value(forKey: disabledCalendarIDsKey) as? Array<String> {
            return Set(disabledCalendarIDs)
        }
        
        return []
    }
    
    func addDisabledCalendarID(id: String) {
        var disabledCalendarIDs = getDisabledCalendarIDs()
        disabledCalendarIDs.insert(id)
        setDisabledCalendarIDs(ids: disabledCalendarIDs)
    }
    
    func removeDisabledCalendarID(id: String) {
        var disabledCalendarIDs = getDisabledCalendarIDs()
        disabledCalendarIDs.remove(id)
        setDisabledCalendarIDs(ids: disabledCalendarIDs)
    }
    
    func clearDisabledCalendarIDs() {
        UserDefaults.standard.removeObject(forKey: disabledCalendarIDsKey)
    }
    
    //Notifications Token
    func getNotificationsToken() -> String? {
        if let notificationsToken = UserDefaults.standard.value(forKey: notificationsTokenKey) as? String {
            return notificationsToken
        }
        
        return nil
    }
    
    func setNotificationsToken(token: String) {
        UserDefaults.standard.set(token, forKey: notificationsTokenKey)
    }
    
    func clearNotificationsToken() {
        UserDefaults.standard.removeObject(forKey: notificationsTokenKey)
    }
    
    //Device Name
    func getDeviceName() -> String {
        if let deviceName = UserDefaults.standard.value(forKey: deviceNameKey) as? String {
            return deviceName
        }
        
        return ""
    }
    
    func setDeviceName(name: String) {
        UserDefaults.standard.set(name, forKey: deviceNameKey)
    }
    
    func clearDeviceName() {
        UserDefaults.standard.removeObject(forKey: deviceNameKey)
    }
    
    //Email Address
    func getEmailAddress() -> String? {
        if let emailAddress = UserDefaults.standard.value(forKey: emailAddressKey) as? String {
            return emailAddress
        }
        
        return nil
    }
    
    func setEmailAddress(email: String) {
        UserDefaults.standard.set(email, forKey: emailAddressKey)
    }
    
    func clearEmailAddress() {
        UserDefaults.standard.removeObject(forKey: emailAddressKey)
    }
    
    //Asked Enable Notifications Popup
    func hasAskedEnableNotificationsPopup() -> Bool {
        if let askedEnableNotifications = UserDefaults.standard.value(forKey: askedEnableNotificationsPopupKey) as? Bool {
            return askedEnableNotifications
        }
        
        return false
    }
    
    func setAskedEnableNotificationsPopup(shown: Bool) {
        UserDefaults.standard.set(shown, forKey: askedEnableNotificationsPopupKey)
    }
    
    func clearAskedEnableNotificationsPopup() {
        UserDefaults.standard.removeObject(forKey: askedEnableNotificationsPopupKey)
    }
}

extension UserDefaultsSourceImpl {
    fileprivate func setDisabledCalendarIDs(ids: Set<String>) {
        let idsArray = Array(ids)
        UserDefaults.standard.set(idsArray, forKey: disabledCalendarIDsKey)
    }
}
