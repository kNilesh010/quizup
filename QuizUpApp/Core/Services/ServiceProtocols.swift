import Foundation

protocol AuthenticationServicing {
    func signIn(email: String, password: String) async throws -> UserSession
    func signUp(username: String, email: String, password: String) async throws -> UserSession
    func signInWithApple(token: String) async throws -> UserSession
}

protocol QuestionServicing {
    func topics() async throws -> [Topic]
    func nextQuestion(for userID: UUID, topicID: UUID, level: DifficultyLevel) async throws -> Question
}

protocol ProgressServicing {
    func submitAnswer(
        userID: UUID,
        topicID: UUID,
        level: DifficultyLevel,
        questionID: UUID,
        selectedIndex: Int
    ) async throws -> Bool

    func completeRound(_ round: GameRound) async throws
    func unlockLevel(for userID: UUID, topicID: UUID) async throws -> DifficultyLevel
}

protocol LeaderboardServicing {
    func globalTop(limit: Int) async throws -> [LeaderboardEntry]
    func topicTop(topicID: UUID, limit: Int) async throws -> [LeaderboardEntry]
}
