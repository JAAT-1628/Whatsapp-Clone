//
//  AuthProvider.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 15/02/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase

enum AuthState {
    case pending, loggedIn(UserItem), loggedOut
}

protocol AuthProvider {
    static var shared: AuthProvider { get }
    var authState: CurrentValueSubject<AuthState, Never> { get }
    func autoLogin() async
    func login(with email: String, and password: String) async throws
    func createAccount(for username: String, with email: String, and password: String) async throws
    func logOut() async throws
}

enum AuthError: Error {
    case accountCreationFailed(_ description: String)
    case failedToSaveUserInfo(_ description: String)
    case emailLoginFailed(_ description: String)
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .accountCreationFailed(let description):
            return description
        case .failedToSaveUserInfo(let description):
            return description
        case .emailLoginFailed(let description):
            return description
        }
    }
}

final class AuthManager: AuthProvider {
    
    private init() {
        Task { await autoLogin() }
    }
    
    static let shared: AuthProvider = AuthManager()
    
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    func autoLogin() async {
        if Auth.auth().currentUser == nil {
            authState.send(.loggedOut)
        } else {
            fetchCurrentUserInfo()
        }
    }
    
    func login(with email: String, and password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            fetchCurrentUserInfo()
            print("🔐 Successfully Signed In \(authResult.user.email ?? "") ")
        } catch {
            print("🔐 Failed to Sign Into the Account with: \(email)")
            throw AuthError.emailLoginFailed(error.localizedDescription)
        }
    }
    
    func createAccount(for username: String, with email: String, and password: String) async throws {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            let newUser = UserItem(uid: uid, username: username, email: email)
            try await saveUserInfoDatabase(user: newUser)
            self.authState.send(.loggedIn(newUser))
        } catch {
            print("🔐 Failed to Create an Account: \(error.localizedDescription)")
            throw AuthError.accountCreationFailed(error.localizedDescription)
        }
    }
    
    func logOut() async throws {
        do {
            try Auth.auth().signOut()
            authState.send(.loggedOut)
            print("🔐 Successfully logged out!")
        } catch {
            print("🔐 Failed to logOut current User: \(error.localizedDescription)")
        }
    }
}

extension AuthManager {
    private func saveUserInfoDatabase(user: UserItem) async throws {
        do {
            let userDictionary: [String: Any] = [.uid : user.uid, .username : user.username, .email : user.email]
            try await FirebaseConstants.UserRef.child(user.uid).setValue(userDictionary)
        } catch {
            print("🔐 Failed to Save Created user Info to Database: \(error.localizedDescription)")
            throw AuthError.failedToSaveUserInfo(error.localizedDescription)
        }
    }
    
    private func fetchCurrentUserInfo() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(currentUid).observe(.value) {[weak self] snapshot in
            
            guard let userDict = snapshot.value as? [String: Any] else { return }
            let loggedInUser = UserItem(dictionary: userDict)
            self?.authState.send(.loggedIn(loggedInUser))   
            print("🔐 \(loggedInUser.username) is logged in")
        } withCancel: { error in
            print("Failed to get current user info")
        }
    }
}


//for creating test accounts
//extension AuthManager {
//    static let testAccounts: [String] = [
//        "rip@test.com",
//        "rip1@test.com",
//        "rip2@test.com",
//        "rip3@test.com",
//        "rip4@test.com",
//        "rip5@test.com",
//        "rip6@test.com",
//        "rip7@test.com",
//        "rip8@test.com",
//        "rip9@test.com",
//        "rip10@test.com",
//        "rip11@test.com",
//        "rip12@test.com",
//        "rip13@test.com",
//        "rip14@test.com",
//        "rip15@test.com",
//        "rip16@test.com",
//        "rip17@test.com",
//        "rip18@test.com",
//        "rip19@test.com",
//        "rip20@test.com",
//        "rip21@test.com",
//        "rip22@test.com",
//        "rip23@test.com",
//        "rip24@test.com",
//        "rip25@test.com",
//        "rip26@test.com",
//        "rip27@test.com",
//        "rip28@test.com",
//        "rip29@test.com",
//        "rip30@test.com",
//        "rip31@test.com",
//        "rip32@test.com",
//        "rip33@test.com",
//        "rip34@test.com",
//        "rip35@test.com",
//        "rip36@test.com",
//        "rip37@test.com",
//        "rip38@test.com",
//        "rip39@test.com",
//        "rip40@test.com",
//        "rip41@test.com",
//        "rip42@test.com",
//        "rip43@test.com",
//        "rip44@test.com",
//        "rip45@test.com",
//        "rip46@test.com",
//        "rip47@test.com",
//        "rip48@test.com",
//        "rip49@test.com",
//        "rip50@test.com"
//    ]
//}
