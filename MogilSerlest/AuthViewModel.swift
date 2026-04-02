//
//  AuthViewModel.swift
//  MogilSerlest
//
//  Created by Philipp Timofeev on 02.04.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
    var mode: AuthMode = .signIn
    var name = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    var isAuthenticated = false
    var isLoading = false
    var showsAlert = false
    var alertMessage = ""

    let authService: AuthServicing

    init(authService: AuthServicing) {
        self.authService = authService
        isAuthenticated = authService.currentUser != nil
        authService.startListening { [weak self] isAuthenticated in
            self?.isAuthenticated = isAuthenticated
        }
    }

    convenience init() {
        self.init(authService: FirebaseAuthService())
    }

    var title: String {
        switch mode {
        case .signIn:
            "Вход"
        case .signUp:
            "Регистрация"
        case .resetPassword:
            "Восстановление пароля"
        }
    }

    var subtitle: String {
        switch mode {
        case .signIn:
            "Введите email и пароль."
        case .signUp:
            "Создайте новый аккаунт через email."
        case .resetPassword:
            "Мы отправим письмо для сброса пароля."
        }
    }

    var primaryButtonTitle: String {
        switch mode {
        case .signIn:
            "Войти"
        case .signUp:
            "Создать аккаунт"
        case .resetPassword:
            "Отправить письмо"
        }
    }

    var isSubmitDisabled: Bool {
        if isLoading {
            return true
        }

        switch mode {
        case .signIn:
            return normalizedEmail.isEmpty || password.isEmpty
        case .signUp:
            return trimmedName.isEmpty || normalizedEmail.isEmpty || password.isEmpty || confirmPassword.isEmpty
        case .resetPassword:
            return normalizedEmail.isEmpty
        }
    }

    func submit() async {
        do {
            try validate()
            isLoading = true
            defer { isLoading = false }

            switch mode {
            case .signIn:
                _ = try await authService.signIn(email: normalizedEmail, password: password)
            case .signUp:
                _ = try await authService.signUp(
                    email: normalizedEmail,
                    password: password,
                    displayName: trimmedName
                )
            case .resetPassword:
                try await authService.sendPasswordReset(email: normalizedEmail)
                showAlert("Письмо для восстановления отправлено на \(normalizedEmail).")
                mode = .signIn
            }
        } catch {
            showAlert(error.localizedDescription)
        }
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            showAlert(error.localizedDescription)
        }
    }

    private var normalizedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func validate() throws {
        guard normalizedEmail.contains("@"), normalizedEmail.contains(".") else {
            throw AuthFlowError.invalidEmail
        }

        switch mode {
        case .signIn:
            guard !password.isEmpty else {
                throw AuthFlowError.emptyPassword
            }
        case .signUp:
            guard password.count >= 6 else {
                throw AuthFlowError.weakPassword
            }

            guard password == confirmPassword else {
                throw AuthFlowError.passwordsDoNotMatch
            }
        case .resetPassword:
            break
        }
    }

    private func showAlert(_ message: String) {
        alertMessage = message
        showsAlert = true
    }
}
