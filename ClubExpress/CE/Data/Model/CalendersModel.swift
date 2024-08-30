//
//  CalendersModel.swift
// ClubExpress
//
//  Created by Hayd Gately on 09/06/2021.
//  Copyright © 2021 Zeta. All rights reserved.
//

import Foundation

class CalendarsModel {
    let calendars: Array<OrgCalendar>?
    let showAds: Array<NativeAd>

    
    init(calendars: Array<OrgCalendar>?, showAds: Array<NativeAd>) {
            self.calendars = calendars
            self.showAds = showAds
    }
    
}
