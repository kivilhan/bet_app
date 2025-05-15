import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class CreateEventViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var optionsText: String = ""
    @Published var isSubmitting = false
    @Published var errorMessage: String?

    func submitEvent(completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "You must be logged in to create an event."
            completion(false)
            return
        }

        let options = optionsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !options.isEmpty else {
            errorMessage = "You must provide at least one option."
            completion(false)
            return
        }

        let newEvent = Event(
            title: title,
            createdById: currentUser.uid,
            options: options
        )

        isSubmitting = true
        errorMessage = nil

        let docRef = Firestore.firestore().collection("events").document(newEvent.id)
        docRef.setData(newEvent.asDictionary) { [weak self] error in
            Task { @MainActor in
                self?.isSubmitting = false
                if let error = error {
                    self?.errorMessage = "Failed to save event: \(error.localizedDescription)"
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
