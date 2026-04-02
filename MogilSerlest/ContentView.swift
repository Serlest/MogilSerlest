//
//  ContentView.swift
//  MogilSerlest
//
//  Created by Philipp Timofeev on 02.04.26.
//

import Observation
import SwiftUI

struct ContentView: View {
    @State private var viewModel = AuthViewModel()

    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                MainScreenView(viewModel: viewModel)
            } else {
                AuthScreen(viewModel: viewModel)
            }
        }
        .animation(.snappy, value: viewModel.isAuthenticated)
    }
}

private struct AuthScreen: View {
    @Bindable var viewModel: AuthViewModel
    @FocusState private var focusedField: AuthField?

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        headerBlock
                        modePicker
                        formCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Ошибка", isPresented: $viewModel.showsAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
        .onAppear {
            setInitialFocus()
        }
        .onChange(of: viewModel.mode) { _, _ in
            setInitialFocus()
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MogilSerlest")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text("Вход, регистрация и восстановление пароля в чистой подаче: спокойная иерархия Apple и компактный контраст Instagram.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                badge("Email Auth")
                badge("Reset Flow")
                badge("Firebase Ready")
            }
        }
    }

    private var modePicker: some View {
        HStack(spacing: 8) {
            modeButton("Вход", .signIn)
            modeButton("Регистрация", .signUp)
            modeButton("Сброс", .resetPassword)
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            formTitle
            fieldsBlock
            primaryButton
            secondaryButtons
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 24, y: 12)
    }

    private var formTitle: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
            Text(viewModel.subtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var fieldsBlock: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.mode == .signUp {
                labeledField("Имя") {
                    TextField("Ваше имя", text: $viewModel.name, prompt: Text("Например, Philipp"))
                        .textContentType(.name)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .name)
                }
            }

            labeledField("Email") {
                TextField("Email", text: $viewModel.email, prompt: Text("name@example.com"))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.emailAddress)
                    .submitLabel(viewModel.mode == .resetPassword ? .send : .next)
                    .focused($focusedField, equals: .email)
            }

            if viewModel.mode != .resetPassword {
                labeledField("Пароль") {
                    SecureField("Пароль", text: $viewModel.password, prompt: Text("Минимум 6 символов"))
                        .textContentType(viewModel.mode == .signIn ? .password : .newPassword)
                        .submitLabel(viewModel.mode == .signUp ? .next : .go)
                        .focused($focusedField, equals: .password)
                }
            }

            if viewModel.mode == .signUp {
                labeledField("Повторите пароль") {
                    SecureField("Повторите пароль", text: $viewModel.confirmPassword, prompt: Text("Повторите пароль"))
                        .textContentType(.newPassword)
                        .submitLabel(.go)
                        .focused($focusedField, equals: .confirmPassword)
                }
            }
        }
        .textFieldStyle(.roundedBorder)
        .onSubmit {
            handleSubmit()
        }
    }

    private var primaryButton: some View {
        Button {
            Task {
                await viewModel.submit()
            }
        } label: {
            HStack(spacing: 8) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                }

                Text(viewModel.primaryButtonTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(.black)
        .disabled(viewModel.isSubmitDisabled)
    }

    private var secondaryButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.mode == .signIn {
                Button("Нет аккаунта? Зарегистрироваться") {
                    viewModel.mode = .signUp
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)

                Button("Забыли пароль?") {
                    viewModel.mode = .resetPassword
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            } else if viewModel.mode == .signUp {
                Button("Уже есть аккаунт? Войти") {
                    viewModel.mode = .signIn
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            } else {
                Button("Назад ко входу") {
                    viewModel.mode = .signIn
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)

                Button("Создать аккаунт") {
                    viewModel.mode = .signUp
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline.weight(.medium))
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.95),
                    Color(red: 0.92, green: 0.95, blue: 1.0),
                    Color(red: 1.0, green: 0.93, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.55))
                .frame(width: 260, height: 260)
                .blur(radius: 12)
                .offset(x: 130, y: -260)

            Circle()
                .fill(Color.black.opacity(0.05))
                .frame(width: 220, height: 220)
                .blur(radius: 12)
                .offset(x: -120, y: 310)
        }
    }

    private func modeButton(_ title: String, _ mode: AuthMode) -> some View {
        Button(title) {
            viewModel.mode = mode
        }
        .buttonStyle(.plain)
        .font(.subheadline.weight(.semibold))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 11)
        .background(viewModel.mode == mode ? Color.primary : Color.white.opacity(0.55), in: Capsule())
        .foregroundStyle(viewModel.mode == mode ? Color(.systemBackground) : .primary)
    }

    private func badge(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(.secondary)
            .background(Color.white.opacity(0.5), in: Capsule())
    }

    private func labeledField<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
            content()
        }
    }

    private func setInitialFocus() {
        switch viewModel.mode {
        case .signUp:
            focusedField = .name
        case .signIn, .resetPassword:
            focusedField = .email
        }
    }

    private func handleSubmit() {
        switch (viewModel.mode, focusedField) {
        case (.signUp, .name):
            focusedField = .email
        case (_, .email) where viewModel.mode != .resetPassword:
            focusedField = .password
        case (.signUp, .password):
            focusedField = .confirmPassword
        default:
            Task {
                await viewModel.submit()
            }
        }
    }
}

private struct MainScreenView: View {
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("Главный экран")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Пока здесь пусто.")
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Выйти", role: .destructive) {
                    viewModel.signOut()
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
        .alert("Ошибка", isPresented: $viewModel.showsAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

private enum AuthField: Hashable {
    case name
    case email
    case password
    case confirmPassword
}

#Preview {
    ContentView()
}
