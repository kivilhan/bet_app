import SwiftUI

struct EventDetailView: View {
    let event: Event

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(event.title)
                    .font(.title)
                    .bold()

                Text("Created by: \(event.createdById)")
                    .font(.subheadline)

                Text("Status: \(event.status.rawValue.capitalized)")
                    .font(.subheadline)

                Text("Options:")
                    .font(.headline)
                ForEach(event.options, id: \.self) { option in
                    Text("• \(option)")
                }

                if let winning = event.winningOption {
                    Text("Winning Option: \(winning)")
                        .foregroundColor(.green)
                        .font(.headline)
                }

                Text("Created At: \(event.createdAt.formatted(.dateTime))")
                    .font(.footnote)

                if let resolvedAt = event.resolvedAt {
                    Text("Resolved At: \(resolvedAt.formatted(.dateTime))")
                        .font(.footnote)
                }
            }
            .padding()
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
