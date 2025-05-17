import SwiftUI

struct PlayView: View {
    @EnvironmentObject var app: AppManager
    @StateObject private var viewModel = EventViewModel()

    var body: some View {
        NavigationView {
            List(app.events) { event in
                NavigationLink(destination: EventDetailView(event: event)) {
                    Text(event.title)
                }
            }
            .navigationTitle("Play")
            .onAppear {
                Task {
                    await viewModel.fetchEvents()
                }
            }

            if viewModel.isLoading {
                ProgressView("Loading events...")
            }
        }
    }
}
