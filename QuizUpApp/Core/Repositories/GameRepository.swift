import Foundation

enum RepositoryError: Error {
    case userNotFound
    case invalidCredentials
    case topicNotFound
    case questionPoolExhausted
    case questionNotFound
}

protocol GameRepository {
    func createUser(username: String, email: String, provider: AuthProvider) async throws -> User
    func fetchUser(email: String) async throws -> User
    func updateUser(_ user: User) async throws

    func fetchTopics() async throws -> [Topic]
    func fetchQuestions(topicID: UUID, level: DifficultyLevel) async throws -> [Question]
    func fetchQuestion(id: UUID) async throws -> Question

    func fetchHistory(userID: UUID, topicID: UUID, level: DifficultyLevel) async throws -> UserQuestionHistory
    func saveHistory(_ history: UserQuestionHistory) async throws

    func saveRound(_ round: GameRound) async throws
    func fetchRounds(userID: UUID) async throws -> [GameRound]

    func fetchLeaderboard(topicID: UUID?) async throws -> [LeaderboardEntry]
}

actor InMemoryGameRepository: GameRepository {
    private var usersByEmail: [String: User] = [:]
    private var topicsByID: [UUID: Topic] = [:]
    private var questionsByID: [UUID: Question] = [:]
    private var questionsByTopicAndLevel: [String: [UUID]] = [:]
    private var histories: [String: UserQuestionHistory] = [:]
    private var roundsByUser: [UUID: [GameRound]] = [:]

    static func makeSeeded() -> InMemoryGameRepository {
        let repo = InMemoryGameRepository()
        Task {
            await repo.seedData()
        }
        return repo
    }

    private func key(topicID: UUID, level: DifficultyLevel) -> String {
        "\(topicID.uuidString)-\(level.rawValue)"
    }

    private func key(userID: UUID, topicID: UUID, level: DifficultyLevel) -> String {
        "\(userID.uuidString)-\(topicID.uuidString)-\(level.rawValue)"
    }

    private func seedData() {
        let user = User(id: UUID(), username: "demo_player", email: "demo@quizup.app", rating: 1200, avatarURL: nil, provider: .email)
        usersByEmail[user.email] = user

        let science = Topic(id: UUID(), name: "Science", description: "Physics, chemistry, biology and beyond")
        let movies = Topic(id: UUID(), name: "Movies", description: "Global cinema trivia")
        [science, movies].forEach { topicsByID[$0.id] = $0 }

        for topic in [science, movies] {
            for level in DifficultyLevel.allCases {
                let generated = (1...25).map { idx in
                    Question(
                        id: UUID(),
                        topicID: topic.id,
                        level: level,
                        prompt: "[\(level.title)] \(topic.name) question #\(idx)",
                        options: ["Option A", "Option B", "Option C", "Option D"],
                        correctIndex: Int.random(in: 0..<4),
                        explanation: "Auto-generated explanation for learning reinforcement."
                    )
                }
                questionsByTopicAndLevel[key(topicID: topic.id, level: level)] = generated.map(\.id)
                for question in generated { questionsByID[question.id] = question }
            }
        }
    }

    func createUser(username: String, email: String, provider: AuthProvider) async throws -> User {
        if usersByEmail[email] != nil { throw RepositoryError.invalidCredentials }
        let user = User(id: UUID(), username: username, email: email, rating: 1000, avatarURL: nil, provider: provider)
        usersByEmail[email] = user
        return user
    }

    func fetchUser(email: String) async throws -> User {
        guard let user = usersByEmail[email] else { throw RepositoryError.userNotFound }
        return user
    }

    func updateUser(_ user: User) async throws {
        usersByEmail[user.email] = user
    }

    func fetchTopics() async throws -> [Topic] {
        Array(topicsByID.values).sorted { $0.name < $1.name }
    }

    func fetchQuestions(topicID: UUID, level: DifficultyLevel) async throws -> [Question] {
        let ids = questionsByTopicAndLevel[key(topicID: topicID, level: level)] ?? []
        return ids.compactMap { questionsByID[$0] }
    }

    func fetchQuestion(id: UUID) async throws -> Question {
        guard let question = questionsByID[id] else { throw RepositoryError.questionNotFound }
        return question
    }

    func fetchHistory(userID: UUID, topicID: UUID, level: DifficultyLevel) async throws -> UserQuestionHistory {
        histories[key(userID: userID, topicID: topicID, level: level)]
            ?? UserQuestionHistory(userID: userID, topicID: topicID, level: level, answeredQuestionIDs: [])
    }

    func saveHistory(_ history: UserQuestionHistory) async throws {
        histories[key(userID: history.userID, topicID: history.topicID, level: history.level)] = history
    }

    func saveRound(_ round: GameRound) async throws {
        roundsByUser[round.userID, default: []].append(round)
    }

    func fetchRounds(userID: UUID) async throws -> [GameRound] {
        roundsByUser[userID] ?? []
    }

    func fetchLeaderboard(topicID: UUID?) async throws -> [LeaderboardEntry] {
        let allUsers = Array(usersByEmail.values)
        return allUsers.map {
            LeaderboardEntry(userID: $0.id, username: $0.username, rating: $0.rating, wins: Int.random(in: 10...100))
        }
        .sorted { $0.rating > $1.rating }
    }
}
