//
//  CalendarRepository.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

class CalendarRepository {
    fileprivate var userDefaultsSource: UserDefaultsSource
    fileprivate var calendarSettingsLocalSource: CalendarSettingsLocalSource
    fileprivate var calendarEventsLocalSource: CalendarEventsLocalSource
    fileprivate var membershipRemoteSource: MembershipRemoteSource
    
    init(userDefaultsSource: UserDefaultsSource, membershipRemoteSource: MembershipRemoteSource, calendarSettingsLocalSource: CalendarSettingsLocalSource, calendarEventsLocalSource: CalendarEventsLocalSource) {
        self.userDefaultsSource = userDefaultsSource
        self.membershipRemoteSource = membershipRemoteSource
        self.calendarSettingsLocalSource = calendarSettingsLocalSource
        self.calendarEventsLocalSource = calendarEventsLocalSource
    }
    
    func getCalendars(sessionToken: String, organisationID: String) -> Promise<CalendarsModel> {
        return Promise { seal in
            membershipRemoteSource.getCalendars(sessionToken: sessionToken, organisationID: organisationID).done { [weak self] response in
                guard let weakSelf = self else { return }

                if let calendars = response.calendars {
                    //Mark calendar as enabled or disabled from preferences
                    let disabledCalendarIDs = weakSelf.getDisabledCalendarIDs()
                    let updatedCalendars = calendars.map({ (calendar) -> OrgCalendar in
                        if let calendarID = calendar.id {
                            if disabledCalendarIDs.contains(calendarID) {
                                calendar.enabled = false
                            } else {
                                calendar.enabled = true
                            }
                        }
                        return calendar
                    })
                    
                    //Save calendars in memory
                    weakSelf.saveStoredCalendars(calendars: updatedCalendars)
                    var calendersModel = CalendarsModel(calendars: updatedCalendars, showAds: response.showAds)
                    seal.fulfill(calendersModel)
                } else {
                    seal.reject(CalendarError.noCalendars)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getEvents(sessionToken: String, organisationID: String, startTimestamp: Int, endTimestamp: Int, timezone: String) -> Promise<Array<CalendarEvent>> {
        return Promise { seal in
            
            //get calendar ids and filter out disabled ones
            let calendars = getStoredCalendars()
            let disabledCalendarIDs = getDisabledCalendarIDs()
            let activeCalendarIDs = calendars.filter({ (calendar) -> Bool in
                guard let id = calendar.id else { return false }
                return !disabledCalendarIDs.contains(id)
            }).compactMap({ (calendar) -> String? in
                return calendar.id
            })
            
            //return empty events if no active calendars ids
            if activeCalendarIDs.count == 0 {
                saveStoredEvents(events: [])
                seal.fulfill([])
                return
            }
            
            membershipRemoteSource.getCalendarEvents(sessionToken: sessionToken, organisationID: organisationID, calendarIDs: activeCalendarIDs, startTimestamp: startTimestamp, endTimestamp: endTimestamp).done { [weak self] response in
                guard let weakSelf = self else { return }

                if let entries = response.entries {
                    
                    entries.forEach({ (event) in
                        //save calendar to each event
                        let calendar = calendars.first(where: { (calendar) -> Bool in
                            return calendar.id == event.calendarID
                        })
                        if let matchedCalendar = calendar {
                            event.parentCalendar = matchedCalendar
                        }
                        
                        //save start and end time from timestamps
                        let timeFormatter = DateFormatter()
                        timeFormatter.dateFormat = "h:mm a"
                        timeFormatter.timeZone = TimeZone.mtTimeZone(identifier: timezone)
                        
                        if let startTimestamp = event.startTimestamp {
                            let startDate = Date(timeIntervalSince1970: TimeInterval(startTimestamp))
                            let startTimeStrimg = timeFormatter.string(from: startDate)
                            event.startTime = startTimeStrimg
                        }
                        if let endTimestamp = event.endTimestamp {
                            let endDate = Date(timeIntervalSince1970: TimeInterval(endTimestamp))
                            let endTimeStrimg = timeFormatter.string(from: endDate)
                            event.endTime = endTimeStrimg
                        }
                        
                        //save start and end dates
                        if let startTimestamp = event.startTimestamp {
                            event.startDate = Date(timeIntervalSince1970: TimeInterval(startTimestamp))
                        }
                        if let endTimestamp = event.endTimestamp {
                            event.endDate = Date(timeIntervalSince1970: TimeInterval(endTimestamp))
                        }
                        if (response.showAds != nil){
                            event.showAds = response.showAds
                        }

                    })
                    
                    //save events in memory
                    weakSelf.saveStoredEvents(events: entries)
                    
                    seal.fulfill(entries)
                } else {
                    seal.reject(CalendarError.noEvents)
                }
            }.catch(policy: .allErrors) { error in
                seal.reject(error)
            }
        }
    }
    
    func getEventDetail(sessionToken: String, organisationID: String, entryID: String) -> Promise<CalendarEventResponse> {
        return Promise { seal in
            membershipRemoteSource.getCalendarEventDetail(sessionToken: sessionToken, organisationID: organisationID, entryID: entryID).done { response in
                seal.fulfill(response)
            }.catch(policy: .allErrors) { error in
                seal.reject(error)
            }
        }
    }
    
    func cancelPendingEventsRequests() {
        let command = "calendar-entries"
        membershipRemoteSource.cancelRequests(command: command)
    }
    
    //Stored calendars in memory
    func getStoredCalendars() -> Array<OrgCalendar> {
        return calendarSettingsLocalSource.getCalendars()
    }
    
    func saveStoredCalendars(calendars: Array<OrgCalendar>) {
        calendarSettingsLocalSource.saveCalendars(calendars: calendars)
    }
    
    func clearStoredCalendars() {
        calendarSettingsLocalSource.clearCalendars()
    }
    
    func updateStoredCalendar(calendar: OrgCalendar) {
        //Update stored calendar
        calendarSettingsLocalSource.updateCalendar(calendar: calendar)
        
        //Update disabled calendar ids
        guard let id = calendar.id else { return }
        if let enabled = calendar.enabled {
            if enabled {
                removeDisabledCalendarID(id: id)
            } else {
                addDisabledCalendarID(id: id)
            }
        }
    }
    
    //Disabled calendar IDs
    func getDisabledCalendarIDs() -> Set<String> {
        return userDefaultsSource.getDisabledCalendarIDs()
    }
    
    func addDisabledCalendarID(id: String) {
        userDefaultsSource.addDisabledCalendarID(id: id)
    }
    
    func removeDisabledCalendarID(id: String) {
        userDefaultsSource.removeDisabledCalendarID(id: id)
    }
    
    func clearDisabledCalendarIDs() {
        userDefaultsSource.clearDisabledCalendarIDs()
    }
    
    //Stored events in memory
    func getStoredEvents() -> Array<CalendarEvent> {
        return calendarEventsLocalSource.getEvents()
    }
    
    func saveStoredEvents(events: Array<CalendarEvent>) {
        calendarEventsLocalSource.saveEvents(events: events)
    }
    
    func clearStoredEvents() {
        calendarEventsLocalSource.clearEvents()
    }
    
    func clearCalendarData() {
        clearStoredCalendars()
        clearDisabledCalendarIDs()
        clearStoredEvents()
    }
}
