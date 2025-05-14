//
//  MessageItems.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 13/02/25.
//

import SwiftUI
import FirebaseAuth

struct MessageItems: Identifiable {
    typealias userId = String
    typealias emoji = String
    typealias emojiCount = Int
    
    let id: String
    let isGroupChat: Bool
    let text: String
    let type: MessageType
    let ownerUid: String
    let timeStamp: Date
    var sender: UserItem?
    let thumbnailURL: String?
    var thumbnailHeight: CGFloat?
    var thumbnailWidth: CGFloat?
    var videoURL: String?
    var audioURL: String?
    var audioDuration: TimeInterval?
    var reactions: [emoji: emojiCount] = [:]
    var userReactions: [userId: emoji] = [:]
    
    var direction: MessageDirection { ownerUid == Auth.auth().currentUser?.uid ? .sent : .received }
    
    static let sentPlaceholder = MessageItems(id: UUID().uuidString, isGroupChat: true, text: "Jaat Raj", type: .text, ownerUid: "1", timeStamp: Date(), thumbnailURL: nil)
    static let recivedPlaceholder =  MessageItems(id: UUID().uuidString, isGroupChat: false, text: "Choudhar puri Jaat ki", type: .text, ownerUid: "2", timeStamp: Date(), thumbnailURL: nil)
    
    // for messages alignment recived or sent
    var alignment: Alignment {
        direction == .received ? .leading : .trailing
    }
    var horizontalAlignment: HorizontalAlignment {
        direction == .received ? .leading : .trailing
    }
    var backgroundColor: Color {
        direction == .sent ? .bubbleGreen : .bubbleWhite
    }
    var showGroupPartnerInfo: Bool {
        isGroupChat && direction == .received
    }
    
    var imageSize: CGSize {
        let photoWidth = thumbnailWidth ?? 0
        let photoHeight = thumbnailHeight ?? 0
        let imageHeight = CGFloat(photoHeight / photoWidth * photoWidth)
        return CGSize(width: imageWidth, height: imageHeight)
    }
    
    var imageWidth: CGFloat {
        let photoWidth = (UIWindowScene.current?.screenWidth ?? 0) / 1.5
        return photoWidth
    }
    
    var audioDurationInString: String { return audioDuration?.formatElapsedTime ?? "00:00" }
    
    var isSentByMe: Bool { return ownerUid == Auth.auth().currentUser?.uid ?? "" }
    
    var menueAnchor: UnitPoint { return direction == .received ? .leading : .trailing }
    
    var reactionAnchor: Alignment { return direction == .sent ? .bottomTrailing : .bottomLeading }
    
    var hasReactions: Bool { return !reactions.isEmpty }
    
    func containSameOwner(as message: MessageItems) -> Bool {
        if let userA = message.sender, let userB = self.sender {
            return userA == userB
        } else {
            return false
        }
    }
    
    static let stubMessage: [MessageItems] = [
        MessageItems(id: UUID().uuidString, isGroupChat: true, text: "Jaat Raj textttt", type: .text, ownerUid: "3", timeStamp: Date(), thumbnailURL: nil),
        MessageItems(id: UUID().uuidString, isGroupChat: false, text: "Jaat Raj photoooo", type: .photo, ownerUid: "4", timeStamp: Date(), thumbnailURL: nil),
        MessageItems(id: UUID().uuidString, isGroupChat: false, text: "Jaat Raj audiooooo", type: .audio, ownerUid: "5", timeStamp: Date(), thumbnailURL: nil),
        MessageItems(id: UUID().uuidString, isGroupChat: true, text: "Jaat Raj videooooo", type: .video, ownerUid: "6", timeStamp: Date(), thumbnailURL: nil)
    ]
}

extension MessageItems {
    init(id: String, isGroupChat: Bool, dict: [String: Any]) {
        self.id = id
        self.isGroupChat = isGroupChat
        self.text = dict[.text] as? String ?? ""
        let type = dict[.type] as? String ?? "text"
        self.type = MessageType(type) ?? .text
        self.ownerUid = dict[.ownerUid] as? String ?? ""
        let timeInterval = dict[.timeStamp] as? Double ?? 0
        self.timeStamp = Date(timeIntervalSince1970: timeInterval)
        self.thumbnailURL = dict[.thumbnailUrls] as? String ?? nil
        self.thumbnailHeight = dict[.thumbnailHeight] as? CGFloat ?? nil
        self.thumbnailWidth = dict[.thumbnailWidth] as? CGFloat ?? nil
        self.videoURL = dict[.videoURL] as? String ?? nil
        self.audioURL = dict[.audioURL] as? String ?? nil
        self.audioDuration = dict[.audioDuration] as? TimeInterval ?? nil
        self.reactions = dict[.reactions] as? [emoji: emojiCount] ?? [:]
        self.userReactions = dict[.userReactions] as? [userId: emoji] ?? [:]
    }
}

extension String {
    static let `type` = "type"
    static let timeStamp = "timeStamp"
    static let ownerUid = "ownerUid"
    static let text = "text"
    static let thumbnailWidth = "thumbnailWidth"
    static let thumbnailHeight = "thumbnailHeight"
    static let videoURL = "videoURL"
    static let audioURL = "audioURL"
    static let audioDuration = "audioDuration"
    static let reactions = "reactions"
    static let userReactions = "userReactions"
}
