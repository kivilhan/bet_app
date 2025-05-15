import SwiftUI
import FirebaseFirestore

struct PlayView: View {
    @StateObject private var viewModel = EventViewModel()
    @State private var showingCreateEvent = false

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading events...")
                        .padding()
                } else if viewModel.events.isEmpty {
                    Text("No events available.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.events) { event in
                        NavigationLink(destination: EventDetailView(event: event)) {
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .font(.headline)
                                Text(event.status.rawValue.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Created: \(event.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .navigationTitle("Play")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        showingCreateEvent = true
                    }) {
                        Label("Create Event", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingCreateEvent) {
                CreateEventView()
            }
        }
    }
}

// MARK: - Preview
struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView()
    }
}
