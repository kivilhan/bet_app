import Foundation
import FirebaseFirestore

@MainActor
final class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    func fetchEvents() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await db.collection("events").getDocuments()
            self.events = try snapshot.documents.map { document in
                try document.data(as: Event.self)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
