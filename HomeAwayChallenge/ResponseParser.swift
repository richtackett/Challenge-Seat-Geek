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
            let eventsJSON = JSON["events"] as? [[String: Any]] else {
                return nil
        }
        
        var searchResponse = SearchResponse()
        searchResponse.totalCount = totalCount
        searchResponse.events = _getEvents(eventsJSON: eventsJSON)
        
        return searchResponse
    }
}

//MARK: - Private Helper Methods
fileprivate extension ResponseParser {
    func _getEvents(eventsJSON: [[String: Any]]) -> [EventViewModel] {
        var events = [EventViewModel]()
        
        for eventJSON in eventsJSON {
            var event = EventViewModel()
            event.ID = eventJSON["id"] as? Int64 ?? 0
            event.title = eventJSON["title"] as? String
            
            if let venue = eventJSON["venue"] as? [String: Any],
                let city = venue["city"] as? String,
                let state = venue["state"] as? String {
                event.location = "\(city), \(state)"
            }
            

            event = _setLocation(event: event, eventJSON: eventJSON)
            event = _formatDate(event: event, eventJSON: eventJSON)
            event = _setImage(event: event, eventJSON: eventJSON)
            events.append(event)
        }
        
        return events
    }
    
    func _setLocation(event: EventViewModel, eventJSON: [String: Any]) -> EventViewModel {
        var event = event
        
        if let venue = eventJSON["venue"] as? [String: Any],
            let city = venue["city"] as? String,
            let state = venue["state"] as? String {
            event.location = "\(city), \(state)"
        }
        
        return event
    }
    
    func _setImage(event: EventViewModel, eventJSON: [String: Any]) -> EventViewModel {
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
    
    func _formatDate(event: EventViewModel, eventJSON: [String: Any]) -> EventViewModel {
        var event = event
        
        if let dateTBD = eventJSON["datetime_tbd"] as? Bool, dateTBD == true {
            event.when = "TBD"
        } else {
            var dateStringForFormat: String? = nil
            if let dateStringLocal = eventJSON["datetime_local"] as? String,
                let venue = eventJSON["venue"] as? [String: Any],
                let timeZoneString = venue["timezone"] as? String,
                let timeZone = TimeZone(identifier: timeZoneString) {
                stringToDateFormatter.timeZone = timeZone
                dateStringForFormat = dateStringLocal
            } else if let dateStringUTC = eventJSON["datetime_local"] as? String  {
                stringToDateFormatter.timeZone = Locale.current.calendar.timeZone
                dateStringForFormat = dateStringUTC
            }
            
            if let dateStringForFormat = dateStringForFormat,
                let date = stringToDateFormatter.date(from: dateStringForFormat) {
                event.when = dateToStringFormatter.string(from: date)
            }
        }
        
        return event
    }
}
