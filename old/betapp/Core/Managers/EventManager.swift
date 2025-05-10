//
//  EventManager.swift
//  betapp
//
//  Created by Ilhan on 16/04/2025.
//

import Foundation
import Combine

final class EventManager: ObservableObject {
    @Published var events: [Event] = []

    private let service = EventService()

    init() {
        subscribeToLiveUpdates()
    }

    func loadEvents() {
        service.fetchEvents { [weak self] events in
            DispatchQueue.main.async {
                self?.events = events
            }
        }
    }

    func subscribeToLiveUpdates() {
        service.subscribeToEvents { [weak self] events in
            DispatchQueue.main.async {
                self?.events = events
            }
        }
    }

    func updateEventStatus(eventId: String, to status: EventStatus) {
        service.updateEventStatus(eventId: eventId, to: status) { error in
            if let error = error {
                print("Failed to update event status: \(error.localizedDescription)")
            }
        }
    }

    func createOrUpdateEvent(_ event: Event) {
        service.saveEvent(event) { error in
            if let error = error {
                print("Failed to save event: \(error.localizedDescription)")
            }
        }
    }
}
