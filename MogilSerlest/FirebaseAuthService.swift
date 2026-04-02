//
//  FirebaseAuthService.swift
//  MogilSerlest
//
//  Created by Philipp Timofeev on 02.04.26.
//

import Foundation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

protocol AuthServicing {
    var currentUser: AuthUser? { get }
    func startListening(onChange: @escaping @MainActor (Bool) -> Void)
    func signIn(email: String, password: String) async throws -> AuthUser
    func signUp(email: String, password: String, displayName: String) async throws -> AuthUser
    func sendPasswordReset(email: String) async throws
    func signOut() throws
}

final class FirebaseAuthService: AuthServicing {
    private var stateHandle: Any?

    var currentUser: AuthUser? {
        #if canImport(FirebaseAuth)
        guard let user = Auth.auth().currentUser else {
            return nil
        }

        return AuthUser(uid: user.uid, email: user.email)
        #else
        return nil
        #endif
    }

    func startListening(onChange: @escaping @MainActor (Bool) -> Void) {
        #if canImport(FirebaseAuth)
        stateHandle = Auth.auth().addStateDidChangeListener { _, user in
            Task { @MainActor in
                onChange(user != nil)
            }
        }
        #else
        Task { @MainActor in
            onChange(false)
        }
        #endif
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        #if canImport(FirebaseAuth)
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthUser(uid: result.user.uid, email: result.user.email)
        #else
        throw AuthFlowError.firebaseUnavailable
        #endif
    }

    func signUp(email: String, password: String, displayName: String) async throws -> AuthUser {
        #if canImport(FirebaseAuth)
        let result = try await Auth.auth().createUser(withEmail: email, password: password)

        if !displayName.isEmpty {
            let request = result.user.createProfileChangeRequest()
            request.displayName = displayName
            try await request.commitChanges()
        }

        return AuthUser(uid: result.user.uid, email: result.user.email)
        #else
        throw AuthFlowError.firebaseUnavailable
        #endif
    }

    func sendPasswordReset(email: String) async throws {
        #if canImport(FirebaseAuth)
        try await Auth.auth().sendPasswordReset(withEmail: email)
        #else
        throw AuthFlowError.firebaseUnavailable
        #endif
    }

    func signOut() throws {
        #if canImport(FirebaseAuth)
        try Auth.auth().signOut()
        #else
        throw AuthFlowError.firebaseUnavailable
        #endif
    }
}
