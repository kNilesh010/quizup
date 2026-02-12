import SwiftUI

struct RootView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        Group {
            if let session = container.session {
                HomeTabView(session: session)
            } else {
                AuthView(container: container)
            }
        }
    }
}

struct HomeTabView: View {
    let session: UserSession

    var body: some View {
        TabView {
            HomeView(session: session)
                .tabItem { Label("Play", systemImage: "gamecontroller") }

            LeaderboardView()
                .tabItem { Label("Leaderboard", systemImage: "list.number") }

            ProfileView(session: session)
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}
