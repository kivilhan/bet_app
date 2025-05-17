import Foundation

final class CreateEventViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var optionsText: String = ""
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String? = nil

    func submitEvent(for userId: String, completion: @escaping (Bool) -> Void) {
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
            createdById: userId,
            options: options
        )

        isSubmitting = true
        errorMessage = nil

        Task {
            await AppManager.shared.upsertEvent(newEvent)
            await MainActor.run {
                self.isSubmitting = false
                completion(true)
            }
        }
    }
}
