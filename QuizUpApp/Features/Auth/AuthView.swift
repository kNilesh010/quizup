import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var vm: AuthViewModel

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: AuthViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Email", text: $vm.email)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $vm.password)
                TextField("Username (for sign-up)", text: $vm.username)

                Button("Sign In") {
                    Task { await vm.signIn() }
                }
                .buttonStyle(.borderedProminent)

                Button("Create Account") {
                    Task { await vm.signUp() }
                }
                .buttonStyle(.bordered)

                if let errorMessage = vm.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("QuizUp Clone")
        }
    }
}
