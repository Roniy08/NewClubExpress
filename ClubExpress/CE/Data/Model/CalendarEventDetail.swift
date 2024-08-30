//
//  CalendarEventDetail.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 11/02/2019.
//  
//

import Foundation

class CalendarEventDetail {
    var eventDescription: String?
    var upcomingDates: Array<CalendarEventUpcomingDate>?
    var ads: Array<NativeAd>?
    
    init(eventDescription: String?, upcomingDates: Array<CalendarEventUpcomingDate>?, ads: Array<NativeAd>?) {
        self.eventDescription = eventDescription
        self.upcomingDates = upcomingDates
        self.ads = ads
    }
}
