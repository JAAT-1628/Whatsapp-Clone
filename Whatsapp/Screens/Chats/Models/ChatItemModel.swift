//
//  ChatItemModel.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 18/02/25.
//

import Foundation
import FirebaseAuth

struct ChatItemModel: Identifiable, Hashable {
    var id: String
    var name: String?
    private var lastMessage: String
    var creationDate: Date
    var lastMessageTimeStamp: Date
    var membersCount: Int
    var adminUids: [String]
    var membersUids: [String]
    var members: [UserItem]
    private var thumbnailUrls: String?
    var createdBy: String
    let lastMessageType: MessageType
    var unReadCount: Int = 0
    
    var isGroupChat: Bool { membersCount > 2 }
    
    var coverImageUrl: String? {
        if let thumbnailUrls = thumbnailUrls {
            return thumbnailUrls
        }
        
        if isGroupChat == false {
            return membersExcludingMe.first?.profileImageUrl
        }
        return nil
    }
    
    var membersExcludingMe: [UserItem] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        return members.filter { $0.uid != currentUid }
    }
    
    var title: String {
        if let name = name {
            return name
        }
        
        if isGroupChat {
            return groupMemberNames
        } else {
            return membersExcludingMe.first?.username ?? "Unknown"
        }
    }
    
    private var groupMemberNames: String {
        let membersCount = membersCount - 1
        let fullName: [String] = membersExcludingMe.map { $0.username }
        
        if membersCount == 2 {
            return fullName.joined(separator: " and ")
        } else if membersCount > 2 {
            let remaningCount = membersCount - 2
            return fullName.prefix(2).joined(separator: ", ") + ", and \(remaningCount) " + "others"
        }
        return "Unknown"
    }
    
    var isCreatedByMe: Bool { createdBy == Auth.auth().currentUser?.uid ?? "" }
    var creatorName: String { members.first { $0.uid == createdBy }?.username ?? "Someone" }
    var allMembersFetched: Bool { members.count == membersCount }
    
    var previewMessage: String {
        switch lastMessageType {
        case .admin:
            return "Chat created start conversation"
        case .text:
            return lastMessage
        case .photo:
            return "Photo Message"
        case .video:
            return "Video Message"
        case .audio:
            return "Voice Message"
        }
    }
    
    static let placeholder = ChatItemModel(id: "1", lastMessage: "Hello", creationDate: Date(), lastMessageTimeStamp: Date(), membersCount: 1, adminUids: [], membersUids: [], members: [], createdBy: "", lastMessageType: .text)
}

extension ChatItemModel {
    init(_ dict: [String: Any]) {
        self.id = dict[.id] as? String ?? ""
        self.name = dict[.name] as? String? ?? nil
        self.lastMessage = dict[.lastMessage] as? String ?? ""
        let creationInterval = dict[.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationInterval)
        let lastMessageTimeStampInterval = dict[.lastMessageTimeStamp] as? Double ?? 0
        self.lastMessageTimeStamp = Date(timeIntervalSince1970: lastMessageTimeStampInterval)
        self.membersCount = dict[.membersCount] as? Int ?? 0
        self.adminUids = dict[.adminUids] as? [String] ?? []
        self.thumbnailUrls = dict[.thumbnailUrls] as? String ?? nil
        self.membersUids = dict[.membersUids] as? [String] ?? []
        self.members = dict[.members] as? [UserItem] ?? []
        self.createdBy = dict[.createdBy] as? String ?? ""
        let msgTypeValue = dict[.lastMessageType] as? String ?? "text"
        self.lastMessageType = MessageType(msgTypeValue) ?? .text
    }
}

extension String {
    static let id = "id"
    static let name = "name"
    static let lastMessage = "lastMessage"
    static let creationDate = "creationDate"
    static let lastMessageTimeStamp = "lastMessageTimeStamp"
    static let membersCount = "membersCount"
    static let adminUids = "adminUids"
    static let membersUids = "membersUids"
    static let thumbnailUrls = "thumbnailUrls"
    static let members = "members"
    static let createdBy = "createdBy"
    static let lastMessageType = "lastMessageType"
}
