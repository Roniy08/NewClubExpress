//
//  MenuPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

protocol MenuView: class {
    func setMenuEntries(menuEntries: Array<NavigationEntry>)
    func setOrganisationName(name: String)
    func setUserName(name: String)
    func setUserImage(url: String)
    func setOrganisationImage(url: String)
    func refreshMenuRows(rows: Array<Int>)
    func setOpenEntries(openEntries: Set<NavigationEntry>)
    func toggleSwitchOrganisationsBtn(show: Bool)
    func didSelectMenuEntry(menuEntry: NavigationEntry)
    func setSelectedMenuEntry(entry: NavigationEntry)
    func setUserAvatarPlaceholder()
    func gotoSettings()
    func sendSwapOrgEvent()
    func setupBasketButton(count: Int)
    func gotoCart()
    func gotoLandingPage()
    func clearSelectedMenuEntry()
    func updateUnreadNotificationsCount(count: Int)
}

class MenuPresenter {
    weak var view: MenuView?
    fileprivate var interactor: MenuInteractor
    fileprivate var flattenedMenuEntries = Array<NavigationEntry>()
    var openEntries = Set<NavigationEntry>()
    var selectedMenuEntry: NavigationEntry?
    
    init(interactor: MenuInteractor) {//,InteractorLocationId: LocationIdInteractor
        self.interactor = interactor
//        self.InteractorLocationId = InteractorLocationId
    }
    
    func menuLoaded() {
        getHeaderDetails()
        getFlattenedMenuEntries()
        setupOpenSections()
        getInitialBasketCount()
        getUnreadNotificationsCount()
        listenForBasketCountChanges()
    }
    
    func setupOpenSections() {
        if let selectedMenuEntry = self.selectedMenuEntry {
            self.openEntries = onlyOpenSectionsForSelectedPage(selectedMenuEntry: selectedMenuEntry)
        } else {
            self.openEntries = []
        }
        
        view?.setOpenEntries(openEntries: self.openEntries)
    }
    
    func selectMenuItemFromUrl(url: String) {
        //search and create selected menu item from url
        let matchingMenuItem = self.flattenedMenuEntries.first { (navigationEntry) -> Bool in
            guard let navigationEntryUrl = navigationEntry.url else { return false }
            if navigationEntryUrl == url {
                return true
            }
            
            //extra check for selecting web link calendar menu after redirecting to native page
            if url == "mtkapp://calendar" && navigationEntryUrl.lowercased().contains("/calendar") {
                return true
            }
            
            return false
        }
        if let matchingMenuItem = matchingMenuItem {
            self.selectedMenuEntry = matchingMenuItem
            view?.setSelectedMenuEntry(entry: matchingMenuItem)
            
            setupOpenSections()
        } else {
            view?.clearSelectedMenuEntry()
        }
    }
    
    fileprivate func getHeaderDetails() {
        let session = interactor.getSession()
        guard let userInfo = session.userInfo else { return }
        guard let organisation = session.selectedOrganisation else { return }
        
        let firstName = userInfo.firstName ?? ""
        let lastName = userInfo.lastName ?? ""
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        view?.setUserName(name: fullName)
        
        view?.setUserAvatarPlaceholder()
        if let userAvatarUrl = userInfo.avatarUrl, userAvatarUrl.count > 0 {
            view?.setUserImage(url: userAvatarUrl)
        }
        
        if let organisationName = organisation.name {
            view?.setOrganisationName(name: organisationName)
        }
        
        if let organisationImageUrl = organisation.imageUrl {
            view?.setOrganisationImage(url: organisationImageUrl)
        }
        
        if let hasMultipleOrganisations = session.hasMultipleOrganisations {
            if hasMultipleOrganisations == true {
                view?.toggleSwitchOrganisationsBtn(show: true)
            } else {
                view?.toggleSwitchOrganisationsBtn(show: false)
            }
        }
    }
    
    fileprivate func getFlattenedMenuEntries() {
        self.flattenedMenuEntries = interactor.getFlattenedMenuEntries()
        view?.setMenuEntries(menuEntries: self.flattenedMenuEntries)
    }
    
    func didPressPage(menuEntry: NavigationEntry) {
        selectedMenuEntry = menuEntry
        
        view?.didSelectMenuEntry(menuEntry: menuEntry)
    }
    
    func didPressDropdown(menuEntry: NavigationEntry) {
        let open = openEntries.contains(menuEntry)
        
        if open {
            //Close menu section
            openEntries.remove(menuEntry)
            
            let childIds = menuEntry.entries!.compactMap { $0.id }
            var rows = Array<Int>()
            childIds.forEach { (id) in
                rows.append(id)
            }
            
            //Close child sections inside this menu entry
            openEntries.forEach { (navigationEntry) in
                if childIds.contains(navigationEntry.id!) {
                    openEntries.remove(navigationEntry)
                    let subChildIds = navigationEntry.entries!.compactMap { $0.id }
                    subChildIds.forEach { (id) in
                        rows.append(id)
                    }
                }
            }
            
            rows.sort()
            
            view?.setOpenEntries(openEntries: openEntries)
            view?.refreshMenuRows(rows: rows)
        } else {
            //Open menu section
            openEntries.insert(menuEntry)
            
            let childIds = menuEntry.entries!.compactMap { $0.id }
            var rows = Array<Int>()
            childIds.forEach { (id) in
                rows.append(id)
            }
            
            rows.sort()
            
            view?.setOpenEntries(openEntries: openEntries)
            view?.refreshMenuRows(rows: rows)
        }
    }
    
    func swapOrgBtnPressed() {
        view?.sendSwapOrgEvent()
    }
    
    func settingsBtnPressed() {
        selectedMenuEntry = nil
        view?.clearSelectedMenuEntry()
        
        view?.gotoSettings()
    }

    fileprivate func onlyOpenSectionsForSelectedPage(selectedMenuEntry: NavigationEntry) -> Set<NavigationEntry> {
        var openSections = Set<NavigationEntry>()
        
        //Open parent top level entries for the selected entry
        let reveresedMenuEntries = Array(flattenedMenuEntries.reversed())
        let selectMenuEntryIndex = reveresedMenuEntries.firstIndex(of: selectedMenuEntry) ?? 0
        let menuEntriesSplice = Array(reveresedMenuEntries[selectMenuEntryIndex ..< reveresedMenuEntries.count])
        
        var currentLevel = selectedMenuEntry.level ?? 2
        
        if currentLevel > 0 {
            for navigationEntry in menuEntriesSplice {
                if let navigationEntryLevel = navigationEntry.level {
                    if navigationEntryLevel < currentLevel {
                        openSections.insert(navigationEntry)
                        currentLevel = (navigationEntry.level ?? 0)
                        if currentLevel == 0 {
                            break
                        }
                    }
                }
            }
        }

        return openSections
    }
    
    fileprivate func getInitialBasketCount() {
        let basketCount = interactor.getBasketCount()
        view?.setupBasketButton(count: basketCount)
    }
        
    func basketButtonPressed() {
        selectedMenuEntry = nil
        view?.clearSelectedMenuEntry()
        
        view?.gotoCart()
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
    
    func logoBtnPressed() {
        selectedMenuEntry = nil
        view?.clearSelectedMenuEntry()
        view?.gotoLandingPage()
    }
    
    func orgNameBtnPressed() {
        selectedMenuEntry = nil
        view?.clearSelectedMenuEntry()
        view?.gotoLandingPage()
    }
    
    func getUnreadNotificationsCount() {
        var userInfo = interactor.getSession().userInfo
        let unreadCount = interactor.getUnreadOrgNotificationsCount()
        var currentOrgUnreadCount = Int(userInfo?.unreadOrgNotifications ?? "0")!
        
        var totalCount = 0
        for org in userInfo?.orgUnreadCounts ?? [:] {
            totalCount += Int(org.value) ?? 0
        }
        view?.updateUnreadNotificationsCount(count: currentOrgUnreadCount)
    }
    
    fileprivate func setupUnreadNotificationsCountDidChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(unreadNotificationsCountDidChange), name: Notification.Name.init("UnreadNotificationsCountDidChange"), object: nil)
    }
    
    fileprivate func removeUnreadNotificationsCountDidChangeNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("UnreadNotificationsCountDidChange"), object: nil)
    }
    
    @objc func unreadNotificationsCountDidChange(notification: Notification) {
        getUnreadNotificationsCount()
    }
}
