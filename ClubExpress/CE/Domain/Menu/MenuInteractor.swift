//
//  MenuInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

class MenuInteractor {
    fileprivate var sessionRepository: SessionRepository
    fileprivate var basketRepository: BasketRepository
    fileprivate var notificationsCountRepository: NotificationsCountRepository

    init(sessionRepository: SessionRepository, basketRepository: BasketRepository, notificationsCountRepository: NotificationsCountRepository) {
        self.sessionRepository = sessionRepository
        self.basketRepository = basketRepository
        self.notificationsCountRepository = notificationsCountRepository
    }
    
    func getFlattenedMenuEntries() -> Array<NavigationEntry> {
        let menuEntries = getMenuEntries()
        let flattenedMenuEntries = flattenMenuEntries(menuEntries: menuEntries)
        return flattenedMenuEntries
    }
    
    fileprivate func getMenuEntries() -> Array<NavigationEntry> {
        guard let session = sessionRepository.getSession() else { fatalError("Session not found") }
        let menuItems = session.navigationEntries ?? []
        
        //Set unique ID and level for each menu item
        //parent
        var uniqueID = 0
        for menuItem in menuItems {
            menuItem.id = uniqueID
            menuItem.level = 0
            uniqueID += 1
            
            //child
            if let childMenuItems = menuItem.entries {
                for childMenuItem in childMenuItems {
                    childMenuItem.id = uniqueID
                    childMenuItem.level = 1
                    uniqueID += 1
                    
                    //baby
                    if let babyMenuItems = childMenuItem.entries {
                        for babyMenuItem in babyMenuItems {
                            babyMenuItem.id = uniqueID
                            babyMenuItem.level = 2
                            uniqueID += 1
                        }
                    }
                }
            }
        }
        
        return menuItems
    }
    
    fileprivate func flattenMenuEntries(menuEntries: Array<NavigationEntry>) -> Array<NavigationEntry> {
        var flattenedArray = Array<NavigationEntry>()
        
        //flatten all menu entries into one depth array
        for menuEntry in menuEntries {
            flattenedArray.append(menuEntry)
            
            if let childMenuEntries = menuEntry.entries {
                let flattenedChildMenuEntries = flattenMenuEntries(menuEntries: childMenuEntries)
                for childMenuEntry in flattenedChildMenuEntries {
                    flattenedArray.append(childMenuEntry)
                }
            }
        }
        
        return flattenedArray
    }
    
    func getSession() -> Session {
        guard let session = sessionRepository.getSession() else { fatalError("Session not found") }
        return session
    }
    
    func getBasketCount() -> Int {
        return basketRepository.getBasketCount()
    }
    
    func getUnreadOrgNotificationsCount() -> Int {
        return notificationsCountRepository.getUnreadCount()
    }
}
