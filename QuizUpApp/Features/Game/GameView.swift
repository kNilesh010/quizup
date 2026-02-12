import SwiftUI

struct GameView: View {
    @EnvironmentObject private var container: AppContainer
    let session: UserSession
    let topic: Topic
    let level: DifficultyLevel

    @State private var currentQuestion: Question?
    @State private var score = 0
    @State private var questionsAnswered = 0
    @State private var askedQuestionIDs: [UUID] = []
    @State private var completed = false

    var body: some View {
        VStack(spacing: 16) {
            Text("\(topic.name) • \(level.title)")
                .font(.headline)
            Text("Score: \(score)")

            if let question = currentQuestion, !completed {
                Text(question.prompt)
                    .font(.title3)
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button(option) {
                        Task { await submit(answer: index) }
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                Text("Round Complete! Final score: \(score)")
                    .font(.title2)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Live Match")
        .task {
            if currentQuestion == nil {
                await loadQuestion()
            }
        }
    }

    private func loadQuestion() async {
        guard !completed else { return }
        do {
            currentQuestion = try await container.questionService.nextQuestion(for: session.user.id, topicID: topic.id, level: level)
        } catch {
            completed = true
        }
    }

    private func submit(answer index: Int) async {
        guard let question = currentQuestion else { return }
        let correct = (try? await container.progressService.submitAnswer(
            userID: session.user.id,
            topicID: topic.id,
            level: level,
            questionID: question.id,
            selectedIndex: index
        )) ?? false

        askedQuestionIDs.append(question.id)
        if correct { score += 10 }
        questionsAnswered += 1

        if questionsAnswered >= 10 {
            completed = true
            let round = GameRound(
                id: UUID(),
                userID: session.user.id,
                topicID: topic.id,
                level: level,
                questionIDs: askedQuestionIDs,
                score: score,
                completedAt: .now
            )
            try? await container.progressService.completeRound(round)
            return
        }

        await loadQuestion()
    }
}
