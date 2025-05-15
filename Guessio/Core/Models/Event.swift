import Foundation

struct Event: Identifiable, Codable {
    let id: String
    let title: String
    let createdById: String
    let options: [String]
    let createdAt: Date
    var resolvedAt: Date?
    var winningOption: String?
    var status: EventStatus


    init(
        title: String,
        createdById: String,
        options: [String]
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.createdById = createdById
        self.options = options
        self.createdAt = Date()
        self.status = .takingBets
        self.resolvedAt = nil
        self.winningOption = nil
    }

    var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "createdById": createdById,
            "options": options,
            "createdAt": createdAt,
            "status": status.rawValue
        ]

        if let resolvedAt = resolvedAt {
            dict["resolvedAt"] = resolvedAt
        }

        if let winningOption = winningOption {
            dict["winningOption"] = winningOption
        }

        return dict
    }
}

enum EventStatus: String, Codable, CaseIterable {
    case takingBets
    case betsClosed
    case resolved
    case cancelled
}
