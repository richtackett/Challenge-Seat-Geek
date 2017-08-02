//
//  EventParser.swift
//  HomeAwayChallenge
//
//  Created by RICHARD TACKETT on 7/31/17.
//  Copyright © 2017 RICHARD TACKETT. All rights reserved.
//

import Foundation

final class ResponseParser {
    fileprivate var stringToDateFormatter = DateFormatter()
    fileprivate var dateToStringFormatter = DateFormatter()
    
    init() {
        stringToDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        stringToDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateToStringFormatter.dateStyle = .medium
        dateToStringFormatter.timeStyle = .short
    }
    
    func parse(JSON: [String: Any]) -> SearchResponse? {
        guard let meta = JSON["meta"] as? [String: Any],
            let totalCount = meta["total"] as? Int,
            let events = JSON["events"] as? [[String: Any]] else {
                return nil
        }
        
        var searchResponse = SearchResponse()
        searchResponse.totalCount = totalCount
        searchResponse.events = _getEvents(eventsJSON: events)
        
        return searchResponse
    }
}

//MARK: - Private Helper Methods
fileprivate extension ResponseParser {
    func _getEvents(eventsJSON: [[String: Any]]) -> [EventViewModel] {
        var events = [EventViewModel]()
        
        for eventJSON in eventsJSON {
            var timeZone: String?
            var dateStringLocal: String?
            var dateStringUTC: String?
            var dateTBD: Bool?
            
            var event = EventViewModel()
            event.ID = eventJSON["id"] as? Int64 ?? 0
            event.title = eventJSON["title"] as? String
            
            if let venue = eventJSON["venue"] as? [String: Any],
                let city = venue["city"] as? String,
                let state = venue["state"] as? String {
                event.location = "\(city), \(state)"
                timeZone = venue["timezone"] as? String
                dateStringLocal = eventJSON["datetime_local"] as? String
                dateStringUTC = eventJSON["datetime_local"] as? String
                dateTBD = eventJSON["datetime_tbd"] as? Bool
                event.when = _formatDate(dateStringLocal: dateStringLocal, dateStringUTC: dateStringUTC, timeZoneString: timeZone, dateTBD: dateTBD)
            }
            
            event = _getImage(event: event, eventJSON: eventJSON)
            events.append(event)
        }
        
        return events
    }
    
    func _getImage(event: EventViewModel, eventJSON: [String: Any]) -> EventViewModel {
        var event = event
        
        if let performers = eventJSON["performers"] as? [[String: Any]] {
            for performer in performers {
                if let image = performer["image"] as? String,
                    let imageURL = URL(string: image) {
                    event.imageURL = imageURL
                }
            }
        }
        
        return event
    }
    
    func _formatDate(dateStringLocal: String?, dateStringUTC: String?, timeZoneString: String?, dateTBD: Bool?) -> String {
        if let dateTBD = dateTBD, dateTBD == true {
            return "TBD"
        }
        
        guard let dateStringLocal = dateStringLocal,
            let dateStringUTC = dateStringUTC else {
                return "No Date"
        }
        
        let dateStringForFormat: String
        if let timeZoneString = timeZoneString,
            let timeZone = TimeZone(identifier: timeZoneString) {
            stringToDateFormatter.timeZone = timeZone
            dateStringForFormat = dateStringLocal
        } else {
            stringToDateFormatter.timeZone = Locale.current.calendar.timeZone
            dateStringForFormat = dateStringUTC
        }
        
        if let date = stringToDateFormatter.date(from: dateStringForFormat) {
            return dateToStringFormatter.string(from: date)
        } else {
            return "No Date"
        }
    }
}
