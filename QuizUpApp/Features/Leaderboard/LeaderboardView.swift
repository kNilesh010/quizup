import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var entries: [LeaderboardEntry] = []

    var body: some View {
        NavigationStack {
            List(entries.indices, id: \.self) { index in
                let entry = entries[index]
                HStack {
                    Text("#\(index + 1)")
                        .font(.headline)
                    VStack(alignment: .leading) {
                        Text(entry.username)
                        Text("Wins: \(entry.wins)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(entry.rating)")
                        .fontWeight(.semibold)
                }
            }
            .navigationTitle("Global Ranking")
            .task {
                entries = (try? await container.leaderboardService.globalTop(limit: 50)) ?? []
            }
        }
    }
}
