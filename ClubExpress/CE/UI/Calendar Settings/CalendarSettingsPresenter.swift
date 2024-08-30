//
//  CalendarSettingsPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import EventKit

protocol CalendarSettingsView: class {
    func setCalendars(calendars: Array<OrgCalendar>)
    func replaceCalendar(index: Int, calendar: OrgCalendar)
    func closePopup()
    func openSystemUrl(url: String)
    func sendCalendarSettingsDidChange()
    func showCalendarPermissionsError()
    func showEmptyPlaceholderView(title: String, message: String)
    func removeEmptyPlaceholderView()
}

class CalendarSettingsPresenter{
    weak var view: CalendarSettingsView?
    fileprivate var interactor: CalendarSettingsInteractor
    fileprivate var calendars = Array<OrgCalendar>()
    fileprivate var settingsChanged = false
    fileprivate let deviceCalendarsStore = EKEventStore()

    init(interactor: CalendarSettingsInteractor) {
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        loadStoredCalendars()
        
        if hasDeviceCalendarPermissionGranted() {
            addDeviceCalendarsChangeNotification()
            markSubscribedCalendars()
        }
    }
    
    fileprivate func loadStoredCalendars() {
        self.calendars = interactor.getStoredCalendars()
        view?.setCalendars(calendars: self.calendars)
        
        if self.calendars.count == 0 {
            view?.showEmptyPlaceholderView(title: "No Calendars", message: "No calendars were found")
        } else {
            view?.removeEmptyPlaceholderView()
        }
    }
    
    func closeBtnPressed() {
        if settingsChanged {
            view?.sendCalendarSettingsDidChange()
        }
        view?.closePopup()
    }
    
    func calendarToggled(calendar: OrgCalendar, enabled: Bool) {
        let calendarIndex = calendars.firstIndex { (existingCalendar) -> Bool in
            return existingCalendar.id == calendar.id
        }
        if let calendarIndex = calendarIndex {
            calendars[calendarIndex].enabled = enabled
            
            let updatedCalendar = calendars[calendarIndex]
            view?.replaceCalendar(index: calendarIndex, calendar: updatedCalendar)
            
            interactor.updateStoredCalendar(calendar: updatedCalendar)            
        }
        settingsChanged = true
    }

    func subscribeBtnPressed(calendar: OrgCalendar) {
        //Ask permission to check subscribed calendars changes
        deviceCalendarsStore.requestAccess(to: .event) { (granted, error) in
            DispatchQueue.main.sync {
                if granted {
                    self.addDeviceCalendarsChangeNotification()
                    
                    //Subscribe to calendar ics
                    if let icsUrl = calendar.icsUrl {
                        self.view?.openSystemUrl(url: icsUrl)
                    }
                } else {
                    self.view?.showCalendarPermissionsError()
                }
            }
        }
    }
    
    fileprivate func addDeviceCalendarsChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceCalendarsStoreChanged), name: NSNotification.Name.EKEventStoreChanged, object: nil)
    }
    
    func appDidBecomeActive() {
        markSubscribedCalendars()
    }
    
    @objc func deviceCalendarsStoreChanged(notification: Notification) {
        markSubscribedCalendars()
    }
    
    fileprivate func markSubscribedCalendars() {
        //check already subscribed calendars if permission granted
        if hasDeviceCalendarPermissionGranted() {
            var subscribedDeviceCalendars = Array<String>()

        
            let deviceCalendars = self.deviceCalendarsStore.calendars(for: .event)
            for deviceCalendar in deviceCalendars {
                if deviceCalendar.type == .subscription {
                    let title = deviceCalendar.title
                    subscribedDeviceCalendars.append(title)
                }
            }
            
            //mark subscribed calendars
            let orgName = interactor.getOrganisationName()
            for calendar in calendars {
                guard let calendarName = calendar.name else { return }
                let fullCalendarName = "\(orgName) - \(calendarName)"
                if subscribedDeviceCalendars.contains(fullCalendarName) {
                    calendar.subscribed = true
                } else {
                    calendar.subscribed = false
                }
            }
            
            view?.setCalendars(calendars: calendars)
        }
    }
    
    fileprivate func hasDeviceCalendarPermissionGranted() -> Bool {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        switch status {
        case .authorized:
            return true
        case .denied, .notDetermined:
            return false
        default:
            return false
        }
    }
}
