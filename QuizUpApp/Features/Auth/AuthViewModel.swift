import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = "demo@quizup.app"
    @Published var username = ""
    @Published var password = "password"
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    func signIn() async {
        await perform {
            container.session = try await container.authService.signIn(email: email, password: password)
        }
    }

    func signUp() async {
        await perform {
            container.session = try await container.authService.signUp(username: username, email: email, password: password)
        }
    }

    private func perform(_ action: @escaping () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await action()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
