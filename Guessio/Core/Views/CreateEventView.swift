import SwiftUI

struct CreateEventView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CreateEventViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create a New Event")
                .font(.title2).bold()

            TextField("Title", text: $viewModel.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Options (comma-separated)", text: $viewModel.optionsText)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Button(action: {
                viewModel.submitEvent { success in
                    if success { dismiss() }
                }
            }) {
                if viewModel.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(viewModel.isSubmitting || viewModel.title.isEmpty || viewModel.optionsText.isEmpty)

            Spacer()
        }
        .padding()
        .navigationTitle("New Event")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}
