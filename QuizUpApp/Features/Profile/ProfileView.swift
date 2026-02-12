import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var container: AppContainer
    let session: UserSession

    var body: some View {
        NavigationStack {
            Form {
                Section("Player") {
                    Text(session.user.username)
                    Text(session.user.email)
                    Text("Rating: \(session.user.rating)")
                }

                Section("Progression") {
                    Text("- ELO-style rating")
                    Text("- Topic-based level unlocks")
                    Text("- Anti-repeat question tracking")
                }

                Button("Sign Out", role: .destructive) {
                    container.session = nil
                }
            }
            .navigationTitle("Profile")
        }
    }
}
