//
//  CalendarManager.swift
//  FootballMatches
//
//  Created by Hai Pham on 04/03/2023.
//

import EventKit

/// Managing the interaction with the device's calendar
final class CalendarManager {
    static let shared = CalendarManager()
    let store = EKEventStore()
    
    // MARK: - Public methods
    /// Request permission to access the calendar
    ///
    /// - parameters:
    ///     - completion: Callback when the request completes.
    func requestPermission(completion: ((Bool, Error?) -> Void)? = nil) {
        store.requestAccess(to: .event) { (granted, error) in
            completion?(granted, error)
        }
    }
    
    /// Current permission status for the calendar
    func getPermissionStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    /// Set events in a specific calendar
    func setEvents(inCalendar calendar: AppCalendar,
                   events: [CalendarEventModel]) {
        if let ekCalendar = calendar.getEKCalendar() {
            events.forEach { calendarModel in
                let event = EKEvent(eventStore: store)
                event.title = calendarModel.title
                event.calendar = ekCalendar
                event.startDate = calendarModel.startDate
                event.endDate = calendarModel.endDate
                // 15 minutes alarm before event
                let alarm: EKAlarm = EKAlarm(relativeOffset: -900)
                event.alarms = [alarm]

                let existingEvents = getExistingEvents(inCalendar: calendar,
                                                       event: calendarModel)
                
                existingEvents.forEach({ event in
                    self.deleteCalendarItem(eventId: event.eventIdentifier)
                })
                do {
                    try store.save(event, span: EKSpan.thisEvent, commit: false)
                } catch let error {
                    print("Save event error: " + error.localizedDescription)
                }
            }
            do {
                try store.commit()
            } catch let error {
                print("Commit error: " + error.localizedDescription)
            }
        }
    }
    
    // Get existing events in a specific calendar
    func getExistingEvents(inCalendar calendar: AppCalendar,
                           event: CalendarEventModel) -> [EKEvent] {
        if let ekCalendar = calendar.getEKCalendar() {
            // TODO: Should check by eventIdentifier instead
            let predicate = store.predicateForEvents(withStart: event.startDate,
                                                     end: event.endDate,
                                                     calendars: [ekCalendar])
            let existingEvents = store.events(matching: predicate)
                .filter({ existingEvent in
                    return event.title == existingEvent.title
                    && event.startDate == existingEvent.startDate
                    && event.endDate == existingEvent.endDate
                })
            return existingEvents
        }
        return []
    }
    
    /// Delete all calendars in the AppCalendar
    func deleteAllAppCalendars() {
        // build a list of AppCalendar to delete then loop through deleting
        // trying to delete in the AppCalendar.allCases.forEach can hang
        var calendars: [AppCalendar] = []
        AppCalendar.allCases.forEach { calendar in
            calendars.append(calendar)
        }
        for calendar in calendars {
            self.deleteCalendar(calendar: calendar)
        }
    }
    
    /// Delete a specific calendar
    func deleteCalendar(calendar: AppCalendar) {
        if let ekCalendar = calendar.getEKCalendar() {
            do {
                try store.removeCalendar(ekCalendar, commit: true)
            } catch let error {
                print("Delete all events error: " + error.localizedDescription)
            }
        }
    }
    
    /// Check if there is permission to add event
    func canAddEventToCalendar() -> Bool {
        EKEventStore.authorizationStatus(for: .event) == EKAuthorizationStatus.authorized
    }

    // MARK: - Private methods
    private func deleteCalendarItem(eventId: String) {
        if let event = store.event(withIdentifier: eventId) {
            do {
                try store.remove(event, span: .thisEvent, commit: true)
            } catch let error {
                print("Delete event error: " + error.localizedDescription)
            }
        }
    }
}

// MARK: - CalendarEventModel
extension CalendarManager {
    struct CalendarEventModel {
        let title: String
        let startDate: Date
        let endDate: Date
    }
}

// MARK: - AppCalendar enum
extension CalendarManager {
    /// Enum to separate Calendars for the app
    enum AppCalendar: String, CaseIterable {
        case upcomingMatches = "Upcoming Matches"

        func getEKCalendar() -> EKCalendar? {
            let store = CalendarManager.shared.store
            if let existingCalendar = store.calendars(for: .event).first(where: { $0.title == self.rawValue }) {
                return existingCalendar
            } else {
                let calendar = EKCalendar(for: .event, eventStore: store)
                calendar.title = self.rawValue
                calendar.source = store.defaultCalendarForNewEvents?.source
                do {
                    try store.saveCalendar(calendar, commit: true)
                    return calendar
                } catch let error {
                    print("Save calendar error: " + error.localizedDescription)
                    return nil
                }
            }
        }
    }
}
