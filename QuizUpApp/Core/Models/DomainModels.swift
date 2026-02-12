import Foundation

enum AuthProvider: String, Codable {
    case email
    case apple
    case guest
}

struct User: Identifiable, Codable, Hashable {
    let id: UUID
    var username: String
    var email: String
    var rating: Int
    var avatarURL: URL?
    var provider: AuthProvider
}

struct UserSession: Codable, Hashable {
    let token: String
    let user: User
    let issuedAt: Date
}

enum DifficultyLevel: Int, Codable, CaseIterable, Hashable {
    case beginner = 1
    case intermediate = 2
    case advanced = 3
    case expert = 4

    var title: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        }
    }
}

struct Topic: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
}

struct Question: Identifiable, Codable, Hashable {
    let id: UUID
    let topicID: UUID
    let level: DifficultyLevel
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct GameRound: Identifiable, Codable, Hashable {
    let id: UUID
    let userID: UUID
    let topicID: UUID
    let level: DifficultyLevel
    var questionIDs: [UUID]
    var score: Int
    var completedAt: Date?
}

struct UserQuestionHistory: Codable, Hashable {
    let userID: UUID
    let topicID: UUID
    let level: DifficultyLevel
    var answeredQuestionIDs: Set<UUID>
}

struct LeaderboardEntry: Identifiable, Codable, Hashable {
    var id: UUID { userID }
    let userID: UUID
    let username: String
    let rating: Int
    let wins: Int
}
