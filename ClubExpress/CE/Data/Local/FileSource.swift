//
//  FileSource.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

protocol FileSource {
    func saveUserInfo(userInfo: UserInfo)
    func getUserInfo() -> UserInfo?
    func clearUserInfo()
    func saveSelectedOrganisation(organisation: Organisation)
    func getSelectedOrganisation() -> Organisation?
    func clearSelectedOrganisation()
    func saveNavigationMenu(entries: Array<NavigationEntry>)
    func getNavigationMenu() -> Array<NavigationEntry>?
    func clearNavigationMenu()
    func saveSettingsMenu(entries: Array<NavigationEntry>)
    func getSettingsMenu() -> Array<NavigationEntry>?
    func clearSettingsMenu()
}

class FileSourceImpl: FileSource {
    fileprivate var userInfoFilePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("userInfo.xml").path
        return url
    }
    fileprivate var selectedOrganisationFilePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("selectedOrganisation.xml").path
        return url
    }
    fileprivate var navigationMenuFilePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("organisationMenu.xml").path
        return url
    }
    fileprivate var settingsMenuFilePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("settingsMenu.xml").path
        return url
    }
    
    //User Info
    func saveUserInfo(userInfo: UserInfo) {
        let path = userInfoFilePath
        let _ = NSKeyedArchiver.archiveRootObject(userInfo, toFile: path)
    }
    
    func getUserInfo() -> UserInfo? {
        if let userInfo = NSKeyedUnarchiver.unarchiveObject(withFile: userInfoFilePath) as? UserInfo {
            return userInfo
        }
        return nil
    }
    
    func clearUserInfo() {
        let manager = FileManager.default
        let path = userInfoFilePath
        do {
            try manager.removeItem(atPath: path)
        } catch let error {
            print("delete user info error \(error.localizedDescription)")
        }
    }
    
    //Selected Organisation
    func saveSelectedOrganisation(organisation: Organisation) {
        let path = selectedOrganisationFilePath
        let _ = NSKeyedArchiver.archiveRootObject(organisation, toFile: path)
    }
    
    func getSelectedOrganisation() -> Organisation? {
        if let selectedOrganisation = NSKeyedUnarchiver.unarchiveObject(withFile: selectedOrganisationFilePath) as? Organisation {
            return selectedOrganisation
        }
        return nil
    }
    
    func clearSelectedOrganisation() {
        let manager = FileManager.default
        let path = selectedOrganisationFilePath
        do {
            try manager.removeItem(atPath: path)
        } catch let error {
            print("delete selected organisation error \(error.localizedDescription)")
        }
    }
    
    //Navigation Menu
    func saveNavigationMenu(entries: Array<NavigationEntry>) {
        let path = navigationMenuFilePath
        let _ = NSKeyedArchiver.archiveRootObject(entries, toFile: path)
    }
    
    func getNavigationMenu() -> Array<NavigationEntry>? {
        if let navigationEntries = NSKeyedUnarchiver.unarchiveObject(withFile: navigationMenuFilePath) as? Array<NavigationEntry> {
            return navigationEntries
        }
        return nil
    }
    
    func clearNavigationMenu() {
        let manager = FileManager.default
        let path = navigationMenuFilePath
        do {
            try manager.removeItem(atPath: path)
        } catch let error {
            print("delete navigation menu error \(error.localizedDescription)")
        }
    }
    
    //Settings Menu
    func saveSettingsMenu(entries: Array<NavigationEntry>) {
        let path = settingsMenuFilePath
        let _ = NSKeyedArchiver.archiveRootObject(entries, toFile: path)
    }
    
    func getSettingsMenu() -> Array<NavigationEntry>? {
        if let settingsEntries = NSKeyedUnarchiver.unarchiveObject(withFile: settingsMenuFilePath) as? Array<NavigationEntry> {
            return settingsEntries
        }
        return nil
    }
    
    func clearSettingsMenu() {
        let manager = FileManager.default
        let path = settingsMenuFilePath
        do {
            try manager.removeItem(atPath: path)
        } catch let error {
            print("delete settings menu error \(error.localizedDescription)")
        }
    }
}
