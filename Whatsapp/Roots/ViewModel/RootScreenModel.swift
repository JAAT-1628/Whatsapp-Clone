///Users/riptikjhajhria/Documents/Swift Learning/Whatsapp/Whatsapp/Roots/Views/RootView.swift
//  RootScreenModel.swift
//  WhatsAppClone
//
//  Created by Osaretin Uyigue on 3/18/24.
//

import Foundation
import Combine

final class RootScreenModel: ObservableObject {
    @Published private(set) var authState = AuthState.pending
    private var cancallable: AnyCancellable?
    
    init() {
        cancallable = AuthManager.shared.authState.receive(on: DispatchQueue.main)
            .sink {[weak self] latestAuthState in
                self?.authState = latestAuthState
            }
        
        //for creating test accounts
//        AuthManager.testAccounts.forEach { email in
//            registerTestAccount(with: email)
//        }
    }
    //for creating test accounts
//    private func registerTestAccount(with email: String) {
//        Task {
//            let username = email.replacingOccurrences(of: "@test.com", with: "")
//            try await AuthManager.shared.createAccount(for: username, with: email, and: "1234567890")
//        }
//    }
}
