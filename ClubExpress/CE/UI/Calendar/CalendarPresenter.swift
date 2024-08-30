//
//  CalendarPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

protocol CalendarView: class {
    func setCurrentMonthLabel(text: String)
    func toggleTodayBtn(enabled: Bool)
    func setSelectedMonth(date: Date)
    func setSelectedDay(date: Date)
    func eventsUpdatedRefreshGrid()
    func toggleEventsLoadingIndicator(show: Bool)
    func setSelectedDayEvents(events: Array<CalendarEvent>)
    func setSelectedDateHeaderString(dateString: String)
    func toggleEmptyCell(show: Bool)
    func toggleTableViewAlwaysBounce(bounce: Bool)
    func showErrorGettingCalendarsPopup()
    func showErrorGettingEventsPopup()
    func presentEventPopup(event: CalendarEvent)
    func toggleSeperatorLine(show: Bool)
    func endRefreshControlAnimating()
    func sendEventToChangePageToWebContent(url: String)
    func showAds(ads: Array<NativeAd>)
}

class CalendarPresenter{
    weak var view: CalendarView?
    fileprivate var interactor: CalendarInteractor
    fileprivate var selectedDayEvents = Array<CalendarEvent>()
    var eventsStartTimestamp: Int = 0
    var eventsEndTimestamp: Int = Int(Date().timeIntervalSince1970)
    var selectedMonth = Date()
    var selectedDay = Date()
    var calendarsLoaded = false
    var calendar = Calendar.current
    
    init(interactor: CalendarInteractor) {
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        resetStoredCalendarsAndEvents()
        getCalendarsAndLoadEvents()

        setSelectedMonthToCurrentMonth()
        setSelectedDayToToday()
    }
    
    fileprivate func resetStoredCalendarsAndEvents() {
        interactor.clearStoredCalendars()
        interactor.clearStoredEvents()
    }
    
    fileprivate func getCalendarsAndLoadEvents() {
        view?.toggleEventsLoadingIndicator(show: true)
        
        interactor.getCalendars().done { [weak self] (calendars) in
            guard let weakSelf = self else { return }
            weakSelf.calendarsLoaded = true
            weakSelf.loadEvents()
            weakSelf.setAds(ads: calendars.showAds)
        }.catch { [weak self] (error) in
            guard let weakSelf = self else { return }
            weakSelf.view?.showErrorGettingCalendarsPopup()
            weakSelf.view?.toggleEventsLoadingIndicator(show: false)
            weakSelf.view?.endRefreshControlAnimating()
            print(error.localizedDescription)
        }
    }
    
    fileprivate func loadEvents() {
        view?.toggleEventsLoadingIndicator(show: true)
                
        interactor.getEvents(startTimestmap: eventsStartTimestamp, endTimestamp: eventsEndTimestamp).done { [weak self] (events) in
            guard let weakSelf = self else { return }
            weakSelf.view?.eventsUpdatedRefreshGrid()
            weakSelf.getSelectedDayEvents()
        }.catch(policy: .allErrors) { [weak self] (error) in
            guard let weakSelf = self else { return }
            if (error as NSError).code != NSURLErrorCancelled {
                weakSelf.view?.showErrorGettingEventsPopup()
            }
            print(error.localizedDescription)
        }.finally { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.view?.toggleEventsLoadingIndicator(show: false)
            weakSelf.view?.endRefreshControlAnimating()
        }
    }
    
    func setAds(ads: Array<NativeAd>) {
        view?.showAds(ads: ads)
    }
    
    func pulledToRefresh() {
        getCalendarsAndLoadEvents()
    }
    
    func calendarSettingsDidChange() {
        loadEvents()
    }
    
    func todayBtnPressed() {
        setSelectedMonthToCurrentMonth()
        setSelectedDayToToday()
    }
    
    func nextMonthBtnPressed() {
        changeCalendarToNextMonth()
    }
    
    func previousMonthBtnPressed() {
        changeCalendarToPrevMonth()
    }
    
    fileprivate func changeCalendarToNextMonth() {
        setSelectedMonthToNextMonth()
        updateSelectedDayOnMonthChange()
    }
    
    fileprivate func changeCalendarToPrevMonth() {
        setSelectedMonthToPreviousMonth()
        updateSelectedDayOnMonthChange()
    }
    
    fileprivate func updateSelectedDayOnMonthChange() {
        let selectedMonthComponents = calendar.dateComponents([.year, .month], from: selectedMonth)
        let selectedMonthMonth = selectedMonthComponents.month
        let selectedMonthYear = selectedMonthComponents.year
        
        let todayComponents = calendar.dateComponents([.year, .month], from: Date())
        let todayMonth = todayComponents.month
        let todayYear = todayComponents.year
        
        if selectedMonthMonth == todayMonth && selectedMonthYear == todayYear {
            setSelectedDayToToday()
        } else {
            setSelectedDayToStartOfSelectedMonth()
        }
    }
    
    fileprivate func setSelectedMonthToNextMonth() {
        let monthsToAdd = 1
        let nextMonthDate = calendar.date(byAdding: .month, value: monthsToAdd, to: selectedMonth)
        
        if let nextMonthDate = nextMonthDate {
            updateSelectedMonth(newMonth: nextMonthDate)
        }
    }
    
    fileprivate func setSelectedMonthToPreviousMonth() {
        let monthsToAdd = -1
        let nextMonthDate = calendar.date(byAdding: .month, value: monthsToAdd, to: selectedMonth)
        
        if let nextMonthDate = nextMonthDate {
            updateSelectedMonth(newMonth: nextMonthDate)
        }
    }
    
    fileprivate func setSelectedMonthToCurrentMonth() {
        let currentMonth = Date()
        var components = calendar.dateComponents([.year, .month], from: currentMonth)
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        if let currentMonthDate = calendar.date(from: components) {
            updateSelectedMonth(newMonth: currentMonthDate)
        }
    }
    
    fileprivate func updateSelectedMonth(newMonth: Date) {
        if newMonth == selectedMonth { return }
        
        self.selectedMonth = newMonth
        view?.setSelectedMonth(date: self.selectedMonth)
        
        setStartTimestampForMonth(date: selectedMonth)
        setEndTimestampForMonth(date: selectedMonth)
        
        buildSelectedMonthLabel(date: selectedMonth)
        
        configureTodayBtn()
        
        if calendarsLoaded == true {
            //Only load events after initial calendars have loaded
            loadEvents()
        }
    }
    
    fileprivate func buildSelectedMonthLabel(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let dateString = dateFormatter.string(from: date)
        view?.setCurrentMonthLabel(text: dateString)
    }
    
    fileprivate func setStartTimestampForMonth(date: Date) {
        eventsStartTimestamp = Int(date.timeIntervalSince1970)
    }
    
    fileprivate func setEndTimestampForMonth(date: Date) {
        let dayRange = calendar.range(of: .day, in: .month, for: date)
        let dayCount = dayRange?.count ?? 1
        
        var components = calendar.dateComponents([.year, .month], from: date)
        components.day = dayCount
        components.hour = 23
        components.minute = 59
        components.second = 59
        if let endOfMonth = calendar.date(from: components) {
            eventsEndTimestamp = Int(endOfMonth.timeIntervalSince1970)
        }
    }
    
    fileprivate func configureTodayBtn() {
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let currentDay = currentComponents.day
        let currentMonth = currentComponents.month
        let currentYear = currentComponents.year
        
        let selectedMonthComponents = calendar.dateComponents([.year, .month], from: self.selectedMonth)
        let selectedMonthMonth = selectedMonthComponents.month
        let selectedMonthYear = selectedMonthComponents.year
        
        let selectedDayComponents = calendar.dateComponents([.year, .month, .day], from: self.selectedDay)
        let selectedDayDay = selectedDayComponents.day
        let selectedDayMonth = selectedDayComponents.month
        let selectedDayYear = selectedDayComponents.year
        
        if currentYear == selectedMonthYear && currentMonth == selectedMonthMonth {
            if currentYear == selectedDayYear && currentMonth == selectedDayMonth && currentDay == selectedDayDay {
                view?.toggleTodayBtn(enabled: false)
            } else {
                view?.toggleTodayBtn(enabled: true)
            }
        } else {
            view?.toggleTodayBtn(enabled: true)
        }
    }
    
    fileprivate func setSelectedDayToToday() {
        let currentDay = Date()
        
        var components = calendar.dateComponents([.year, .month, .day], from: currentDay)
        components.hour = 0
        components.minute = 0
        components.second = 0
        if let currentDayDate = calendar.date(from: components) {
            setSelectedDayToDay(day: currentDayDate)
        }
    }
    
    fileprivate func setSelectedDayToDay(day: Date) {
        if day == selectedDay { return }
        
        self.selectedDay = day
        view?.setSelectedDay(date: self.selectedDay)
        
        configureTodayBtn()
        
        setSelectedDateHeaderString()
        getSelectedDayEvents()
    }
    
    fileprivate func setSelectedDayToStartOfSelectedMonth() {
        let dateOfSelectedMonth = self.selectedMonth
        setSelectedDayToDay(day: dateOfSelectedMonth)
    }
    
    func viewSwipedLeft() {
        changeCalendarToNextMonth()
    }
    
    func viewSwipedRight() {
        changeCalendarToPrevMonth()
    }
    
    func selectedDayDidChange(day: Date) {
        setSelectedDayToDay(day: day)
    }
    
    fileprivate func getSelectedDayEvents() {
        self.selectedDayEvents = interactor.getStoredEventsForDay(date: selectedDay)
        view?.setSelectedDayEvents(events: self.selectedDayEvents)
        for i in 0 ..< self.selectedDayEvents.count {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/dd/yyyy h:mma"
            let start_Date = (selectedDayEvents[i].startDate ?? Date()) as Date
            let end_date = (selectedDayEvents[i].endDate ?? Date()) as Date
            
            let comparisonResult = start_Date.compare(end_date)

                if comparisonResult == .orderedAscending {
                    view?.toggleEmptyCell(show: false)
                    view?.toggleSeperatorLine(show: true)
                }
               else if comparisonResult == .orderedDescending
                {
                    view?.toggleEmptyCell(show: false)
                    view?.toggleSeperatorLine(show: true)
                    // here check all day event as the end date is not greater than start date
                }
               else if comparisonResult == .orderedSame || selectedDayEvents.count != 0
                {
                    view?.toggleEmptyCell(show: false)
                    view?.toggleSeperatorLine(show: true)
                }
            else
            {
                view?.toggleEmptyCell(show: true)
                view?.toggleSeperatorLine(show: false)
            }
            
            
//            if self.selectedDayEvents[i].startTime == self.selectedDayEvents[i].endTime || selectedDayEvents.count == 0
//            {
//                view?.toggleEmptyCell(show: true)
//                view?.toggleSeperatorLine(show: false)
//            }
//            else{
//                view?.toggleEmptyCell(show: false)
//                view?.toggleSeperatorLine(show: true)
//            }
           }
//        if selectedDayEvents.count == 0 {
//            view?.toggleEmptyCell(show: true)
//            view?.toggleSeperatorLine(show: false)
//        } else {
//            view?.toggleEmptyCell(show: false)
//            view?.toggleSeperatorLine(show: true)
//        }
    }
    
    fileprivate func setSelectedDateHeaderString() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.dateFormat = "EEEE, MMMM d yyyy"
        let dateString = dateFormatter.string(from: selectedDay)
        
        view?.setSelectedDateHeaderString(dateString: dateString)
    }
    
    func didSelectEvent(index: Int) {
        let event = selectedDayEvents[index]
        view?.presentEventPopup(event: event)
    }
    
    func openUrlInWebContent(url: String) {
        view?.sendEventToChangePageToWebContent(url: url)
    }
}
