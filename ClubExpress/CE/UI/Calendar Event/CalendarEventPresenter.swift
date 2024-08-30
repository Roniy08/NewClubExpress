//
//  CalendarEventPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

protocol CalendarEventView: class {
    func animateInBgView()
    func decreaseOverlay()
    func closeOverlay()
    func sendEventToOpenUrlInWebContent(url: String)
//    func showAds(ads: Array<NativeAd>)
}

class CalendarEventPresenter{
    weak var view: CalendarEventView?
    var event: CalendarEvent?
    
    func viewDidLoad() {
        view?.animateInBgView()
    }
    
    func bgViewTapped() {
        view?.decreaseOverlay()
    }
    
    func closePopupPressed() {
        view?.closeOverlay()
    }
    
    func openUrlInWebContent(url: String) {
        view?.sendEventToOpenUrlInWebContent(url: url)
    }
}

