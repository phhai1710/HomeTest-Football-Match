//
//  CalendarHelper.swift
//  FootballMatches
//
//  Created by Hai Pham on 04/03/2023.
//

import Foundation
import Combine

// TODO: Temporary class for setting reminder
final class CalendarHelper {
    static let shared = CalendarHelper()

    /**
     Set reminder for a match
     
     - parameters:
         - home:  Name of home team
         - away:  Name of away team
         - date: Time of the reminder
         - completion: Callback after setting reminder. It may throw error if the app doesn't have permission
     */
    func setReminderForMatch(home: String,
                             away: String,
                             date: Date,
                             completion: @escaping (Bool, Error?) -> ()) {
        CalendarManager.shared.requestPermission { [unowned self] success, error in
            if let error = error {
                completion(false, error)
            } else {
                if success {
                    if let event = self.createEventModel(home: home,
                                                         away: away,
                                                         date: date) {
                        CalendarManager.shared.setEvents(inCalendar: .upcomingMatches,
                                                         events: [event])
                        completion(true, nil)
                    } else {
                        completion(false, nil)
                    }
                } else {
                    completion(false, nil)
                }
            }
        }
    }
    
    /**
     Check if a match has been scheduled or not
     
     - parameters:
         - home:  Name of home team
         - away:  Name of away team
         - date: Time of the reminder
     - Returns: **True** if match has been scheduled
     */
    func hasScheduled(home: String, away: String, date: Date) -> Bool {
        if CalendarManager.shared.getPermissionStatus() == .authorized {
            if let event = CalendarHelper.shared.createEventModel(home: home,
                                                                  away: away,
                                                                  date: date) {
                return !CalendarManager.shared.getExistingEvents(inCalendar: .upcomingMatches,
                                                                 event: event).isEmpty

            }
        }
        
        return false
    }
    
    func createEventModel(home: String,
                          away: String,
                          date: Date) -> CalendarManager.CalendarEventModel? {
        let title = home + " vs " + away
        let endDate = date.addingTimeInterval(900)
        let event = CalendarManager.CalendarEventModel(title: title,
                                                       startDate: date,
                                                       endDate: endDate)
        return event
    }
}
