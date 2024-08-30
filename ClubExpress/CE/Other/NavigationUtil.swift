//
//  NavigationUtil.swift
//  ClubExpress
//
//  Created by Joe Benton on 08/01/2019.
//  Copyright © 2019 Zeta. All rights reserved.
//

import Foundation

struct NavigationUtil {
    //Decide which native page to load from selected navigation entry or load web view
    func getPage(menuEntry: NavigationEntry) -> activePage {
        var url = menuEntry.url ?? ""
        url = url.lowercased()
        
        if isNativePage(url: url) {
            let endpoint = getEndpointAfterScheme(url: url)
            if let page = getNativePageFromEndpoint(endpoint: endpoint) {
                return page
            }
        }
        
        let title = menuEntry.label ?? ""
        let menuUrl = menuEntry.url ?? ""
        let contentItem = WebContentItem(title: title, url: menuUrl, content: nil)
        return activePage.webview(contentItem: contentItem)
    }
    
    func isNativePage(url: String) -> Bool {
        let appScheme = "mtkapp:"
        if url.contains(appScheme) {
            return true
        } else {
            return false
        }
    }
    
    func getEndpointAfterScheme(url: String) -> String {
        let splitUrl = url.components(separatedBy: "://")
        if splitUrl.count > 1 {
            return splitUrl[1]
        }
        return url
    }
    
    func getNativePageFromEndpoint(endpoint: String) -> activePage? {
        switch endpoint {
        case "directory":
            return activePage.directory
        case "calendar":
            return activePage.calendar
        case "logout":
            return activePage.forceLogout
        default:
            return nil
        }
    }
}
