import SwiftUI

struct CreateEventView: View {
    @EnvironmentObject var app: AppManager
    @StateObject private var viewModel = CreateEventViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section(header: Text("Event Title")) {
                TextField("Enter title", text: $viewModel.title)
            }

            Section(header: Text("Options")) {
                TextField("Comma-separated options", text: $viewModel.optionsText)
            }

            Button("Submit Event") {
                if let userId = app.firebaseUser?.uid {
                    viewModel.submitEvent(for: userId) { success in
                        if success { dismiss() }
                    }
                }
            }
            .disabled(viewModel.isSubmitting)

            if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }
        }
        .navigationTitle("Create Event")
    }
}
