//
//  SessionRepository.swift
// ClubExpress
//
// Created by Ronit on 05/06/2024.
//  
//

import Foundation

class SessionRepository {
    fileprivate var userDefaultsSource: UserDefaultsSource
    fileprivate var fileSource: FileSource
    fileprivate var organisationColours: OrganisationColours
    
    fileprivate var session: Session?
    
    init(userDefaultsSource: UserDefaultsSource, fileSource: FileSource, organisationColours: OrganisationColours) {
        self.userDefaultsSource = userDefaultsSource
        self.fileSource = fileSource
        self.organisationColours = organisationColours
    }
    
    func getSession() -> Session? {
        if let session = self.session {
            return session
        } else {
            setupSessionWithSessionToken()
            return self.session
        }
    }
    
    func setupSessionWithSessionToken() {
        guard let sessionToken = userDefaultsSource.getSessionToken() else { return }
        let userInfo = fileSource.getUserInfo()
        let selectedOrganisation = fileSource.getSelectedOrganisation()
        let hasMultipleOrganisations = userDefaultsSource.hasMultipleOrganisations()
//        let navigationEntries = fileSource.getNavigationMenu()
//        let settingsEntries = fileSource.getSettingsMenu()
//        let session = Session(sessionToken: sessionToken, userInfo: userInfo, selectedOrganisation: selectedOrganisation, hasMultipleOrganisations: hasMultipleOrganisations, navigationEntries: navigationEntries, settingsEntries: settingsEntries, ablyAPIKey: nil)
        let session = Session(sessionToken: sessionToken, userInfo: userInfo, selectedOrganisation: selectedOrganisation, hasMultipleOrganisations: hasMultipleOrganisations, ablyAPIKey: nil)
        
        self.session = session
    }
    
    func setSessionToken(sessionToken: String) {
        userDefaultsSource.setSessionToken(sessionToken: sessionToken)
        
        if (self.session != nil) {
            self.session?.sessionToken = sessionToken
        } else {
            setupSessionWithSessionToken()
        }
    }
    
    func setUserInfo(userInfo: UserInfo) {
        fileSource.saveUserInfo(userInfo: userInfo)
        if (self.session != nil) {
            self.session?.userInfo = userInfo
        }
    }
    
    func setSelectedOrganisation(organisation: Organisation?) {
        if(organisation != nil){
            fileSource.saveSelectedOrganisation(organisation: organisation!)
            
            if let primaryBgColour = organisation!.primaryBgColour, let secondaryBgColour = organisation!.secondaryBgColour {
                organisationColours.setColours(primaryBgColourString: primaryBgColour, secondaryBgColourString: secondaryBgColour)
            }
            
            if (self.session != nil) {
                self.session?.selectedOrganisation = organisation
            }
        }
       
    }
    
    func setHasMultipleOrganisations(hasMultipleOrganisations: Bool) {
        userDefaultsSource.setMultipleOrganisations(hasMultipleOrganisations: hasMultipleOrganisations)
        if (self.session != nil) {
            self.session?.hasMultipleOrganisations = hasMultipleOrganisations
        }
    }
    
    func setNavigationMenu(entries: Array<NavigationEntry>) {
        fileSource.saveNavigationMenu(entries: entries)
        if (self.session != nil) {
            self.session?.navigationEntries = entries
        }
    }
    
    func setSettingsMenu(entries: Array<NavigationEntry>) {
        fileSource.saveSettingsMenu(entries: entries)
        if (self.session != nil) {
            self.session?.settingsEntries = entries
        }
    }
    
    func clearSelectedOrganisationData() {
        fileSource.clearSelectedOrganisation()
        fileSource.clearNavigationMenu()
        fileSource.clearSettingsMenu()
        
        self.session?.selectedOrganisation = nil
        self.session?.navigationEntries = nil
        self.session?.settingsEntries = nil
    }
    
    func hasSwitchOrganisationPopupShown() -> Bool {
        return userDefaultsSource.hasSwitchOrganisationPopupShown()
    }
    
    func setShownSwitchOrganisationPopup() {
        userDefaultsSource.setShownSwitchOrganisationPopup(shownSwitchOrganisationPopup: true)
    }
    
    func clearUserData() {
//        fileSource.clearUserInfo()
//        fileSource.clearNavigationMenu()
//        fileSource.clearSettingsMenu()
//        fileSource.clearSelectedOrganisation()
        
        userDefaultsSource.clearSessionToken()
//        userDefaultsSource.clearHasMultipleOrganisations()
        
        session = nil
    }
    
    func hasCloseFiltersConfirmPopupShown() -> Bool {
        return userDefaultsSource.hasCloseFiltersConfirmPopupShown()
    }
    
    func setShownCloseFiltersConfirmPopup() {
        userDefaultsSource.setShownCloseFiltersConfirmPopup(shownCloseFiltersConfirmPopup: true)
    }
    
    func setAblyAPIKey(key: String) {
        if (self.session != nil) {
            self.session?.ablyAPIKey = key
        }
    }
}
