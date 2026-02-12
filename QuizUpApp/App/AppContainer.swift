import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let authService: AuthenticationServicing
    let questionService: QuestionServicing
    let progressService: ProgressServicing
    let leaderboardService: LeaderboardServicing

    @Published var session: UserSession?

    init(
        authService: AuthenticationServicing,
        questionService: QuestionServicing,
        progressService: ProgressServicing,
        leaderboardService: LeaderboardServicing,
        session: UserSession? = nil
    ) {
        self.authService = authService
        self.questionService = questionService
        self.progressService = progressService
        self.leaderboardService = leaderboardService
        self.session = session
    }

    static func bootstrap() -> AppContainer {
        let repository = InMemoryGameRepository.makeSeeded()
        return AppContainer(
            authService: AuthService(repository: repository),
            questionService: QuestionService(repository: repository),
            progressService: ProgressService(repository: repository),
            leaderboardService: LeaderboardService(repository: repository)
        )
    }
}
