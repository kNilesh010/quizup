import Foundation

final class AuthService: AuthenticationServicing {
    private let repository: GameRepository

    init(repository: GameRepository) {
        self.repository = repository
    }

    func signIn(email: String, password: String) async throws -> UserSession {
        let user = try await repository.fetchUser(email: email)
        return UserSession(token: UUID().uuidString, user: user, issuedAt: .now)
    }

    func signUp(username: String, email: String, password: String) async throws -> UserSession {
        let user = try await repository.createUser(username: username, email: email, provider: .email)
        return UserSession(token: UUID().uuidString, user: user, issuedAt: .now)
    }

    func signInWithApple(token: String) async throws -> UserSession {
        let email = "apple_\(token.prefix(8))@private.quizup"
        let existing = try? await repository.fetchUser(email: email)
        let user = try await (existing ?? repository.createUser(username: "apple_player", email: email, provider: .apple))
        return UserSession(token: token, user: user, issuedAt: .now)
    }
}

final class QuestionService: QuestionServicing {
    private let repository: GameRepository

    init(repository: GameRepository) {
        self.repository = repository
    }

    func topics() async throws -> [Topic] {
        try await repository.fetchTopics()
    }

    func nextQuestion(for userID: UUID, topicID: UUID, level: DifficultyLevel) async throws -> Question {
        let history = try await repository.fetchHistory(userID: userID, topicID: topicID, level: level)
        let allQuestions = try await repository.fetchQuestions(topicID: topicID, level: level)
        let unseen = allQuestions.filter { !history.answeredQuestionIDs.contains($0.id) }

        guard let question = unseen.randomElement() else {
            throw RepositoryError.questionPoolExhausted
        }
        return question
    }
}

final class ProgressService: ProgressServicing {
    private let repository: GameRepository

    init(repository: GameRepository) {
        self.repository = repository
    }

    func submitAnswer(
        userID: UUID,
        topicID: UUID,
        level: DifficultyLevel,
        questionID: UUID,
        selectedIndex: Int
    ) async throws -> Bool {
        let question = try await repository.fetchQuestion(id: questionID)
        var history = try await repository.fetchHistory(userID: userID, topicID: topicID, level: level)
        history.answeredQuestionIDs.insert(questionID)
        try await repository.saveHistory(history)
        return question.correctIndex == selectedIndex
    }

    func completeRound(_ round: GameRound) async throws {
        try await repository.saveRound(round)
    }

    func unlockLevel(for userID: UUID, topicID: UUID) async throws -> DifficultyLevel {
        let rounds = try await repository.fetchRounds(userID: userID).filter { $0.topicID == topicID }
        let scoreByLevel = Dictionary(grouping: rounds, by: \.level)
            .mapValues { rounds in rounds.map(\.score).max() ?? 0 }

        if (scoreByLevel[.advanced] ?? 0) >= 70 { return .expert }
        if (scoreByLevel[.intermediate] ?? 0) >= 60 { return .advanced }
        if (scoreByLevel[.beginner] ?? 0) >= 50 { return .intermediate }
        return .beginner
    }
}

final class LeaderboardService: LeaderboardServicing {
    private let repository: GameRepository

    init(repository: GameRepository) {
        self.repository = repository
    }

    func globalTop(limit: Int) async throws -> [LeaderboardEntry] {
        Array(try await repository.fetchLeaderboard(topicID: nil).prefix(limit))
    }

    func topicTop(topicID: UUID, limit: Int) async throws -> [LeaderboardEntry] {
        Array(try await repository.fetchLeaderboard(topicID: topicID).prefix(limit))
    }
}
