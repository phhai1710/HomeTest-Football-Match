//
//  FootballMatch.swift
//  FootballMatches
//
//  Created by Hai Pham on 04/03/2023.
//

import Foundation
import Domain

extension FootballMatch {
    static let dateFormat = "YYYY-MM-dd'T'HH:mm:ss.sss'Z'"
    
    // TODO: Change type of date to Date to avoid parsing everytime using _date
    var _date: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = FootballMatch.dateFormat
        let date = dateFormatter.date(from: date)
        return date
    }
}
