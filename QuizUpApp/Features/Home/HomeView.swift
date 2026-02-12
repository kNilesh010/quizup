import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var container: AppContainer
    let session: UserSession

    @State private var topics: [Topic] = []
    @State private var selectedTopic: Topic?
    @State private var selectedLevel: DifficultyLevel = .beginner

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Topic", selection: $selectedTopic) {
                    ForEach(topics) { topic in
                        Text(topic.name).tag(Optional(topic))
                    }
                }
                .pickerStyle(.wheel)

                Picker("Level", selection: $selectedLevel) {
                    ForEach(DifficultyLevel.allCases, id: \.self) { level in
                        Text(level.title).tag(level)
                    }
                }
                .pickerStyle(.segmented)

                if let topic = selectedTopic {
                    NavigationLink {
                        GameView(session: session, topic: topic, level: selectedLevel)
                    } label: {
                        Text("Start Ranked Match")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Choose Category")
            .task {
                topics = (try? await container.questionService.topics()) ?? []
                selectedTopic = topics.first
            }
        }
    }
}
