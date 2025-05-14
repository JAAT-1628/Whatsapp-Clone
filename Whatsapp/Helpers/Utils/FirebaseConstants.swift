//
//  FirebaseConstants.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 16/02/25.
//

import Foundation
import Firebase
import FirebaseStorage

enum FirebaseConstants {
    static let StorageRef = Storage.storage().reference()
    private static let DatabaseRef = Database.database().reference()
    static let UserRef = DatabaseRef.child("users")
    static let ChannelsRef = DatabaseRef.child("channels")
    static let MessageRef = DatabaseRef.child("channel-messages")
    static let UserChannelsRef = DatabaseRef.child("user-channels")
    static let UserDirectChannels = DatabaseRef.child("user-direct-channels")
}
