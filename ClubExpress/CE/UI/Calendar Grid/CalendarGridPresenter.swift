//
//  CalendarGridPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

protocol CalendarGridView: class {
    func setCalendarDays(days: Array<CalendarDay>, animated: Bool)
    func selectedDayDidChange(date: Date)
}

class CalendarGridPresenter{
    weak var view: CalendarGridView?
    fileprivate var interactor: CalendarGridInteractor
    fileprivate var events = Array<CalendarEvent>()
    var selectedMonth: Date? {
        didSet {
            if selectedMonth != oldValue {
                let animate = oldValue == nil ? false : true
                createCalendarDays(animated: animate)
            }
        }
    }
    var selectedDay: Date? {
        didSet {
            if selectedDay != oldValue {
                updateSelectedDayInCalendarDays()
            }
        }
    }
    fileprivate var days = Array<CalendarDay>()
    fileprivate var calendar = Calendar.current
    
    init(interactor: CalendarGridInteractor) {
        self.interactor = interactor
    }
    
    func eventsUpdated() {
        getEvents()
    }
    
    fileprivate func createCalendarDays(animated: Bool) {
        guard let selectedMonth = selectedMonth else { return }
        var days = Array<CalendarDay>()

        //add days for the month
        let daysInMonth = getDaysInMonth(date: selectedMonth)
        for day in 1...daysInMonth {
            let dayDate = buildDateForDay(day: day)
            let day = CalendarDay(cellType: .normal, date: dayDate, events: [])
            day.today = isDateToday(date: dayDate)
            day.selected = isDateSelected(date: dayDate)
            days.append(day)
        }
        
        //preappend spare days before month
        let firstDayWeekday = getFirstDayWeekday()
        let spareDaysBeforeWeekday = getSpareDaysBeforeWeekday(weekday: firstDayWeekday)
        if spareDaysBeforeWeekday > 0 {
            for _ in 1...spareDaysBeforeWeekday {
                let spareDay = CalendarDay(cellType: .empty, date: nil, events: [])
                days.insert(spareDay, at: 0)
            }
        }
        
        //append spare days after month
        let lastDayWeekday = getLastDayWeekday()
        let spareDaysAfterWeekday = getSpareDaysAfterWeekday(weekday: lastDayWeekday)
        if spareDaysAfterWeekday > 0 {
            for _ in 1...spareDaysAfterWeekday {
                let spareDay = CalendarDay(cellType: .empty, date: nil, events: [])
                days.append(spareDay)
            }
        }
        
        self.days = days
        view?.setCalendarDays(days: self.days, animated: animated)
    }
    
    func updateSelectedDayInCalendarDays() {
        guard let selectedDay = self.selectedDay else { return }
        let selectedDayComponents = calendar.dateComponents([.year, .month, .day], from: selectedDay)
        let selectedDayYear = selectedDayComponents.year
        let selectedDayMonth = selectedDayComponents.month
        let selectedDayDay = selectedDayComponents.day
        
        for day in days {
            if let date = day.date {
                let checkDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                let checkYear = checkDateComponents.year
                let checkMonth = checkDateComponents.month
                let checkDay = checkDateComponents.day
                if selectedDayDay == checkDay && selectedDayMonth == checkMonth && selectedDayYear == checkYear {
                    day.selected = true
                } else {
                    day.selected = false
                }
            }
        }
        
        view?.setCalendarDays(days: self.days, animated: false)
    }
    
    func getEvents() {
        let allEvents = interactor.getEvents()
        self.events = allEvents
        
        //update days with events
        for day in days {
            if let date = day.date {
                let dayDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                let dayYear = dayDateComponents.year ?? 0
                let dayMonth = dayDateComponents.month ?? 0
                let dayDay = dayDateComponents.day ?? 0
                
                let daysEvents = self.events.filter { (event) -> Bool in
                    if let startDate = event.startDate, let endDate = event.endDate {
                        if endDate < startDate
                        {
                            var calendar = Calendar.current
                            calendar.timeZone = TimeZone.mtTimeZone(identifier: getTimezone())
                            
                            let eventStartDateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
                            let eventStartYear = eventStartDateComponents.year ?? 0
                            let eventStartMonth = eventStartDateComponents.month ?? 0
                            let eventStartDay = eventStartDateComponents.day ?? 0
                            
                            let eventEndDateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
                            let eventEndYear = eventEndDateComponents.year ?? 0
                            let eventEndMonth = eventEndDateComponents.month ?? 0
                            let eventEndDay = eventEndDateComponents.day ?? 0
                            
                            //check if event exists on day
                            if dayYear >= eventStartYear && dayYear <= eventEndYear {
                                if dayMonth >= eventStartMonth && dayMonth <= eventEndMonth {
                                    if dayDay >= eventStartDay && dayDay <= eventEndDay {
                                        return true
                                    }
                                }
                            }
                        }
                        else
                        {
                            var calendar = Calendar.current
                            calendar.timeZone = TimeZone.mtTimeZone(identifier: getTimezone())
                            
                            let eventStartDateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
                            let eventStartYear = eventStartDateComponents.year ?? 0
                            let eventStartMonth = eventStartDateComponents.month ?? 0
                            let eventStartDay = eventStartDateComponents.day ?? 0
                            
                            let eventEndDateComponents = calendar.dateComponents([.year, .month, .day], from: endDate)
                            let eventEndYear = eventEndDateComponents.year ?? 0
                            let eventEndMonth = eventEndDateComponents.month ?? 0
                            let eventEndDay = eventEndDateComponents.day ?? 0
                            
                            //check if event exists on day
                            if dayYear >= eventStartYear && dayYear <= eventEndYear {
                                if dayMonth >= eventStartMonth && dayMonth <= eventEndMonth {
                                    if dayDay >= eventStartDay && dayDay <= eventEndDay {
                                        return true
                                    }
                                }
                            }
                        }
                            
                    }
                    return false
                }
                day.events = daysEvents
            }
        }
        view?.setCalendarDays(days: self.days, animated: false)
    }
    
    fileprivate func getDaysInMonth(date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)
        if let range = range {
            return range.count
        }
        return 0
    }
    
    fileprivate func buildDateForDay(day: Int) -> Date? {
        guard let selectedMonth = selectedMonth else { return nil }

        var components = calendar.dateComponents([.year, .month, .day], from: selectedMonth)
        components.day = day
        components.hour = 0
        components.minute = 0
        components.second = 0
        if let dayDate = calendar.date(from: components) {
            return dayDate
        }
        return nil
    }
    
    fileprivate func getFirstDayWeekday() -> Int {
        guard let selectedMonth = selectedMonth else { return 0 }
        let components = calendar.dateComponents([.weekday], from: selectedMonth)
        let weekday = components.weekday ?? 0
        return weekday
    }
    
    fileprivate func getSpareDaysBeforeWeekday(weekday: Int) -> Int {
        return weekday - 1
    }
    
    fileprivate func getLastDayWeekday() -> Int {
        guard let selectedMonth = selectedMonth else { return 0 }
        var components = calendar.dateComponents([.year, .month], from: selectedMonth)
        let nextMonth = (components.month ?? 0) + 1
        components.month = nextMonth
        components.day = 1
        let lastMonthDay = (components.day ?? 0) - 1
        components.day = lastMonthDay
        if let endOfMonth = calendar.date(from: components) {
            let weekdayComponents = calendar.dateComponents([.weekday], from: endOfMonth)
            let weekday = weekdayComponents.weekday ?? 0
            return weekday
        }
        return 0
    }
    
    fileprivate func getSpareDaysAfterWeekday(weekday: Int) -> Int {
        let remainingDays = 7 - weekday
        return remainingDays
    }
    
    fileprivate func isDateToday(date: Date?) -> Bool {
        guard let date = date else { return false }
        
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let currentYear = currentComponents.year
        let currentMonth = currentComponents.month
        let currentDay = currentComponents.day
        
        let checkDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let checkYear = checkDateComponents.year
        let checkMonth = checkDateComponents.month
        let checkDay = checkDateComponents.day
        
        if currentYear == checkYear && currentMonth == checkMonth && currentDay == checkDay {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func isDateSelected(date: Date?) -> Bool {
        guard let date = date else { return false }
        guard let selectedDate = selectedDay else { return false }
        
        let selectedDateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let selectedDateYear = selectedDateComponents.year
        let selectedDateMonth = selectedDateComponents.month
        let selectedDateDay = selectedDateComponents.day
        
        let checkDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let checkYear = checkDateComponents.year
        let checkMonth = checkDateComponents.month
        let checkDay = checkDateComponents.day
        
        if selectedDateYear == checkYear && selectedDateMonth == checkMonth && selectedDateDay == checkDay {
            return true
        } else {
            return false
        }
    }
    
    func didSelectDay(index: Int) {
        let day = days[index]
        if let date = day.date {
            if date != selectedDay {
                selectedDay = date
                
                view?.selectedDayDidChange(date: self.selectedDay!)
            }
        }
    }
    
    fileprivate func getTimezone() -> String {
        return interactor.getTimezone()
    }
}
