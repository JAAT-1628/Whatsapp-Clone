//
//  UserItem.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 15/02/25.
//

import Foundation

struct UserItem: Identifiable, Hashable, Decodable {
    let uid: String
    let username: String
    let email: String
    var bio: String? = nil
    var profileImageUrl: String? = nil
    
    var id: String {
        return uid
    }
    
    var bioUnwrapped: String {
        return bio ?? "Hey there! I am using WhatsApp."
    }
    
    static let placeholder = UserItem(uid: "1", username: "Jaat Saab", email: "jaat@gmail.com")
    
    static let placeholders: [UserItem] = [
        UserItem(uid: "1", username: "Jaat Saab", email: "jaat@gmail.com"),
        UserItem(uid: "2", username: "Jaat ", email: "jaat@gmail.com"),
        UserItem(uid: "3", username: "Jaat Riptik", email: "jaat@gmail.com"),
        UserItem(uid: "4", username: "Jaat Manu", email: "jaat@gmail.com"),
        UserItem(uid: "5", username: "Saab", email: "jaat@gmail.com"),
        UserItem(uid: "6", username: "rrrr", email: "jaat@gmail.com"),
        UserItem(uid: "7", username: "Saabiiii", email: "jaat@gmail.com"),
        UserItem(uid: "8", username: "mmmmm", email: "jaat@gmail.com"),
        UserItem(uid: "9", username: "Jaat Saab", email: "jaat@gmail.com"),
        UserItem(uid: "10", username: "Jaat Saab", email: "jaat@gmail.com"),
        UserItem(uid: "11", username: "Jaat Saab", email: "jaat@gmail.com"),
        UserItem(uid: "12", username: "Jaat Saab", email: "jaat@gmail.com"),
        UserItem(uid: "13", username: "Jaat Saab", email: "jaat@gmail.com"),
        UserItem(uid: "14", username: "Jaat Saab", email: "jaat@gmail.com"),
        UserItem(uid: "15", username: "Jaat Saab", email: "jaat@gmail.com")
    ]
}

extension UserItem {
    init(dictionary: [String: Any]) {
        self.uid = dictionary[.uid] as? String ?? ""
        self.username = dictionary[.username] as? String ?? ""
        self.email = dictionary[.email] as? String ?? ""
        self.bio = dictionary[.bio] as? String? ?? nil
        self.profileImageUrl = dictionary[.profileImageUrl] as? String? ?? nil
    }
}

extension String {
    static let uid = "uid"
    static let username = "username"
    static let email = "email"
    static let bio = "bio"
    static let profileImageUrl = "profileImageUrl"
}
