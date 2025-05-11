//
//  EventService.swift
//  betapp
//
//  Created by Ilhan on 16/04/2025.
//

import Foundation
import FirebaseFirestore

final class EventService: EventServiceProtocol {
    private let db = Firestore.firestore()
    private let collection = "events"

    func fetchEvents(completion: @escaping ([Event]) -> Void) {
        db.collection(collection).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching events: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            let events = documents.compactMap { doc in
                Event(documentID: doc.documentID, data: doc.data())
            }
            completion(events)
        }
    }

    func saveEvent(_ event: Event, completion: ((Error?) -> Void)? = nil) {
        db.collection(collection).document(event.id).setData(event.asDictionary) { error in
            completion?(error)
        }
    }

    func subscribeToEvents(update: @escaping ([Event]) -> Void) {
        db.collection(collection).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Live update failed: \(error?.localizedDescription ?? "Unknown error")")
                update([])
                return
            }

            let events = documents.compactMap { doc in
                Event(documentID: doc.documentID, data: doc.data())
            }
            update(events)
        }
    }

    func updateEventStatus(eventId: String, to status: EventStatus, completion: ((Error?) -> Void)? = nil) {
        db.collection(collection).document(eventId).updateData(["status": status.rawValue]) { error in
            completion?(error)
        }
    }
}

final class DummyEventService: EventServiceProtocol {
    private var dummyEvents: [Event] = [
        Event(id: "1", title: "Will it rain tomorrow?", status: .takingBets),
        Event(id: "2", title: "Will the home team win?", status: .betsClosed),
        Event(id: "3", title: "Was the coin toss heads?", status: .resolved)
    ]

    private var updateCallbacks: [( [Event] ) -> Void] = []

    func fetchEvents(completion: @escaping ([Event]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(self.dummyEvents)
        }
    }

    func saveEvent(_ event: Event, completion: ((Error?) -> Void)? = nil) {
        if let index = dummyEvents.firstIndex(where: { $0.id == event.id }) {
            dummyEvents[index] = event
        } else {
            dummyEvents.append(event)
        }
        notifySubscribers()
        completion?(nil)
    }

    func subscribeToEvents(update: @escaping ([Event]) -> Void) {
        updateCallbacks.append(update)
        update(dummyEvents)
    }

    func updateEventStatus(eventId: String, to status: EventStatus, completion: ((Error?) -> Void)? = nil) {
        if let index = dummyEvents.firstIndex(where: { $0.id == eventId }) {
            dummyEvents[index].status = status
            notifySubscribers()
        }
        completion?(nil)
    }

    private func notifySubscribers() {
        for callback in updateCallbacks {
            callback(dummyEvents)
        }
    }
}

protocol EventServiceProtocol {
    func fetchEvents(completion: @escaping ([Event]) -> Void)
    func saveEvent(_ event: Event, completion: ((Error?) -> Void)?)
    func subscribeToEvents(update: @escaping ([Event]) -> Void)
    func updateEventStatus(eventId: String, to status: EventStatus, completion: ((Error?) -> Void)?)
}
