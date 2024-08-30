//
//  TimeZone+MTDefault.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 07/02/2019.
//  
//

import Foundation

extension TimeZone {
    static func mtTimeZone(identifier: String) -> TimeZone {
        //Create time zone from identifier or default to users current time zone
        if identifier.count > 0 {
            let timezone = TimeZone(identifier: identifier)
            if let timezone = timezone {
                return timezone
            }
        }
        return TimeZone.current
    }
}
