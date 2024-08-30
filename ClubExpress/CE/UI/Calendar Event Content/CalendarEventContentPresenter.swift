//
//  CalendarEventContentPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

protocol CalendarEventContentView: class {
    func setTitle(title: String)
    func closePopupEvent()
    func configureView(event: CalendarEvent)
    func setCalendarName(name: String)
    func setStartDate(dateString: NSAttributedString)
    func setEndDate(dateString: NSAttributedString)
    func toggleLoadingIndicator(show: Bool)
    func toggleEventDescriptionWebView(show: Bool)
    func showEventDetailErrorPopup()
    func setEventDescriptionWebView(html: String)
    func setUpcomingDatesLabel(text: String)
    func setUpcomingDatesHeader(title: String)
    func hideUpcomingDatesWrapper()
    func hideWebViewStackItem()
    func openUrlInWebContent(url: String)
    func showAds(ads: Array<NativeAd>)
}

class CalendarEventContentPresenter{
    weak var view: CalendarEventContentView?
    fileprivate var interactor: CalendarEventContentInteractor
    fileprivate var timezone = ""
    var event: CalendarEvent?
    var eventDetail: CalendarEventDetail?
    
    init(interactor: CalendarEventContentInteractor) {
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        getTimezone()
        configureEvent()
        getEventDetail()
    }
    
    func configureEvent() {
        if let event = self.event {
            if let name = event.title {
                view?.setTitle(title: name)
            }
            
            view?.configureView(event: event)
            
            if let calendar = event.parentCalendar {
                if let calendarName = calendar.name {
                    view?.setCalendarName(name: calendarName)
                }
            }
            
            if let startDate = event.startDate {
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone.mtTimeZone(identifier: timezone)
                dateFormatter.dateStyle = .full
                let dateString = dateFormatter.string(from: startDate)
                
                let timeFormatter = DateFormatter()
                timeFormatter.timeZone = TimeZone.mtTimeZone(identifier: timezone)
                timeFormatter.dateFormat = "h:mm a"
                let timeString = timeFormatter.string(from: startDate)
                
                let startString = "Start: "
                let atString = " at "
                var fullDateString = "\(startString)\(dateString)"
                
                let allDay = event.allDay ?? false
                if allDay == false {
                    fullDateString.append("\(atString)\(timeString)")
                }
                
                let attributedString = NSMutableAttributedString(string: fullDateString)
                
                let boldFont = UIFont.openSansSemiBoldFontOfSize(size: 15)
                let boldRange = NSRange(location: 0, length: startString.count)
                attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: boldRange)
                
                if allDay == false {
                    let atFont = UIFont.openSansFontOfSize(size: 14)
                    if let range = fullDateString.range(of: atString) {
                        let atRange = NSRange(range, in: fullDateString)
                        let atColor = UIColor.mtSlateGrey
                        attributedString.addAttributes([NSAttributedString.Key.font : atFont, NSAttributedString.Key.foregroundColor : atColor], range: atRange)
                    }
                }
                    
                view?.setStartDate(dateString: attributedString)
            }
            
            if let endDate = event.endDate {
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone.mtTimeZone(identifier: timezone)
                dateFormatter.dateStyle = .full
                let dateString = dateFormatter.string(from: endDate)
                
                let timeFormatter = DateFormatter()
                timeFormatter.timeZone = TimeZone.mtTimeZone(identifier: timezone)
                timeFormatter.dateFormat = "h:mm a"
                let timeString = timeFormatter.string(from: endDate)
                
                let endString = "End: "
                let atString = " at "
                var fullDateString = "\(endString)\(dateString)"
                
                let allDay = event.allDay ?? false
                if allDay == false {
                    fullDateString.append("\(atString)\(timeString)")
                }
                
                let attributedString = NSMutableAttributedString(string: fullDateString)
                
                let boldFont = UIFont.openSansSemiBoldFontOfSize(size: 15)
                let boldRange = NSRange(location: 0, length: endString.count)
                attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: boldRange)
                
                if allDay == false {
                    let atFont = UIFont.openSansFontOfSize(size: 14)
                    if let range = fullDateString.range(of: atString) {
                        let atRange = NSRange(range, in: fullDateString)
                        let atColor = UIColor.mtSlateGrey
                        attributedString.addAttributes([NSAttributedString.Key.font : atFont, NSAttributedString.Key.foregroundColor : atColor], range: atRange)
                    }
                }
                    
                view?.setEndDate(dateString: attributedString)
            }
        }
    }
    
    func configureEventDetail() {
        guard let eventDetail = eventDetail else { return }
        if let eventDescriptionHtml = eventDetail.eventDescription, eventDescriptionHtml.count > 0 {
            view?.setEventDescriptionWebView(html: eventDescriptionHtml)
        } else {
            view?.hideWebViewStackItem()
        }
        
        if let upcomingDates = eventDetail.upcomingDates {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.mtTimeZone(identifier: timezone)
            dateFormatter.dateStyle = .full
            
            let timeFormatter = DateFormatter()
            timeFormatter.timeZone = TimeZone.mtTimeZone(identifier: timezone)
            timeFormatter.dateFormat = "h:mm a"
            
            var upcomingDatesArray = Array<String>()
            upcomingDates.forEach { (upcomingDate) in
                var itemText = ""
                if let startTimestamp = upcomingDate.startTimestamp {
                    let startDate = Date(timeIntervalSince1970: TimeInterval(startTimestamp))
                    let dateString = dateFormatter.string(from: startDate)
                    itemText.append(dateString)
                    
                    let allDay = upcomingDate.allDay ?? false
                    if allDay == false {
                        let timeString = timeFormatter.string(from: startDate)
                        itemText.append(" \(timeString)")
                    }
                }
                
                upcomingDatesArray.append(itemText)
            }
            
            if upcomingDatesArray.count > 0 {
                let upcomingDatesText = upcomingDatesArray.joined(separator: "\n")
                view?.setUpcomingDatesLabel(text: upcomingDatesText)
            } else {
                view?.setUpcomingDatesLabel(text: "No other dates")
            }
            
            view?.setUpcomingDatesHeader(title: "All dates for this event:")
        } else {
            view?.hideUpcomingDatesWrapper()
        }
    }
    
    func closeBtnPressed() {
        view?.closePopupEvent()
    }
    
    func getEventDetail() {
        guard let entryID = event?.id else { return }
        view?.toggleLoadingIndicator(show: true)
        view?.toggleEventDescriptionWebView(show: false)
        
        interactor.getEventDetail(entryID: entryID).done { [weak self] (eventDetail) in
            guard let weakSelf = self else { return }
            weakSelf.eventDetail = eventDetail
            weakSelf.configureEventDetail()
            weakSelf.setAds(ads: eventDetail.ads ?? [])
        }.catch { [weak self] (error) in
            guard let weakSelf = self else { return }
            weakSelf.view?.showEventDetailErrorPopup()
            weakSelf.view?.toggleLoadingIndicator(show: false)
        }
    }
    
    fileprivate func getTimezone() {
        self.timezone = interactor.getTimezone()
    }
    
    func webViewDidFinishLoadingHeight() {
        view?.toggleLoadingIndicator(show: false)
        view?.toggleEventDescriptionWebView(show: true)
    }
    
    func webViewLinkClicked(url: String) {
        view?.closePopupEvent()
        view?.openUrlInWebContent(url: url)
    }
    
    func setAds(ads: Array<NativeAd>) {
        view?.showAds(ads: ads)
    }
}

