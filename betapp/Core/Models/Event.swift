//
//  Event.swift
//  betapp
//
//  Created by Ilhan on 16/04/2025.
//

import Foundation

struct Event: Identifiable {
    var id: String
    var title: String
    var status: EventStatus

    init(id: String, title: String, status: EventStatus) {
        self.id = id
        self.title = title
        self.status = status
    }

    init?(documentID: String, data: [String: Any]) {
        guard
            let title = data["title"] as? String,
            let statusString = data["status"] as? String,
            let status = EventStatus(rawValue: statusString)
        else {
            return nil
        }
        self.id = documentID
        self.title = title
        self.status = status
    }

    var asDictionary: [String: Any] {
        return [
            "title": title,
            "status": status.rawValue
        ]
    }
}

enum EventStatus: String {
    case takingBets
    case betsClosed
    case resolved
    case cancelled
}
