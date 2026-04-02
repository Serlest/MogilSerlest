//
//  AuthModels.swift
//  MogilSerlest
//
//  Created by Philipp Timofeev on 02.04.26.
//

import Foundation

enum AuthMode {
    case signIn
    case signUp
    case resetPassword
}

struct AuthUser: Equatable {
    let uid: String
    let email: String?
}

enum AuthFlowError: LocalizedError {
    case invalidEmail
    case emptyPassword
    case weakPassword
    case passwordsDoNotMatch
    case firebaseUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Введите корректный email."
        case .emptyPassword:
            return "Введите пароль."
        case .weakPassword:
            return "Пароль должен содержать минимум 6 символов."
        case .passwordsDoNotMatch:
            return "Пароли не совпадают."
        case .firebaseUnavailable:
            return "Firebase SDK пока не подключён. Добавьте FirebaseAuth, FirebaseCore и GoogleService-Info.plist."
        }
    }
}
