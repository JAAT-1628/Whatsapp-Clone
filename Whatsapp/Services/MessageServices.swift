//
//  MessageServices.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 19/02/25.
//

import Foundation
import FirebaseAuth
import Firebase

//chat reaction handels sending and fetching messages
struct MessageServices {
    static func sendTextMessage(to channel: ChatItemModel, from currentUser: UserItem, _ textMessage: String, onComplete: () -> Void) {
        let timeStamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.MessageRef.childByAutoId().key else { return }
        
        let channelDict: [String: Any] = [
            .lastMessage: textMessage,
            .lastMessageTimeStamp: timeStamp,
            .lastMessageType: MessageType.text.title
        ]
        
        let messageDict: [String: Any] = [
            .text: textMessage,
            .type: MessageType.text.title,
            .timeStamp: timeStamp,
            .ownerUid: currentUser.uid,
        ]
        
        FirebaseConstants.ChannelsRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessageRef.child(channel.id).child(messageId).setValue(messageDict)
        increaseUnreadMessageCount(in: channel)
        onComplete()
    }
    
    
    static func sendMediaMessage(to channel: ChatItemModel, params: MessageUploadPrams, completion: @escaping () -> Void) {
        guard let messageId = FirebaseConstants.MessageRef.childByAutoId().key else { return }
        let timeStamp = Date().timeIntervalSince1970
        
        let channelDict: [String: Any] = [
            .lastMessage: params.text,
            .lastMessageTimeStamp: timeStamp,
            .lastMessageType: params.type.title
        ]
        
        var messageDict: [String: Any] = [
            .text: params.text,
            .type: params.type.title,
            .timeStamp: timeStamp,
            .ownerUid: params.ownerUID,
        ]
        
        messageDict[.thumbnailUrls] = params.thumbnailURL ?? nil
        messageDict[.thumbnailWidth] = params.thumbnailWidth ?? nil
        messageDict[.thumbnailHeight] = params.thumbnailHeight ?? nil
        messageDict[.videoURL] = params.videoURL ?? nil
        messageDict[.audioURL] = params.audioURL ?? nil
        messageDict[.audioDuration] = params.audioDuration ?? nil
        
        FirebaseConstants.ChannelsRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessageRef.child(channel.id).child(messageId).setValue(messageDict)
        increaseUnreadMessageCount(in: channel)
        completion()
    }
    
    static func getMessages(for channel: ChatItemModel, completion: @escaping([MessageItems]) -> Void) {
        FirebaseConstants.MessageRef.child(channel.id).observe(.value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }
            var messages: [MessageItems] = []
            dict.forEach { key, value in
                let messageDict = value as? [String: Any] ?? [:]
                var  message = MessageItems(id: key, isGroupChat: channel.isGroupChat, dict: messageDict)
                let messageSender = channel.members.first(where: { $0.uid == message.ownerUid })
                message.sender = messageSender
                messages.append(message)
                if messages.count == snapshot.childrenCount {
                    messages.sort { $0.timeStamp < $1.timeStamp }
                    completion(messages)
                }
            }
        } withCancel: { error in
            print("Failed to get messages for \(channel.title)")
        }
    }
    
    static func getHistoricalMessages(for channel: ChatItemModel, lastCurrsor: String?, pageSize: UInt, completion: @escaping(MessageNode) -> ()) {
        let query: DatabaseQuery
        
        if lastCurrsor == nil {
            query = FirebaseConstants.MessageRef.child(channel.id).queryLimited(toLast: pageSize)
        } else {
            query = FirebaseConstants.MessageRef.child(channel.id)
                .queryOrderedByKey()
                .queryEnding(atValue: lastCurrsor)
                .queryLimited(toLast: pageSize)
        }
        
        query.observeSingleEvent(of: .value) { mainSnapshot in
            guard let first = mainSnapshot.children.allObjects.first as? DataSnapshot,
                  let allObject = mainSnapshot.children.allObjects as? [DataSnapshot]
            else { return }
            
            var messages: [MessageItems] = allObject.compactMap { messageSnapshot in
                let messageDict = messageSnapshot.value as? [String: Any] ?? [:]
                var message = MessageItems(id: messageSnapshot.key, isGroupChat: channel.isGroupChat, dict: messageDict)
                let messageSender = channel.members.first(where: { $0.uid == message.ownerUid })
                message.sender = messageSender
                return message
            }
            
            messages.sort { $0.timeStamp < $1.timeStamp }
            
            if messages.count == mainSnapshot.childrenCount {
                if lastCurrsor == nil { messages.removeLast() }
                let filterMessage = lastCurrsor == nil ? messages : messages.filter { $0.id != lastCurrsor }
                let messageNode = MessageNode(message: filterMessage, currentCurrsor: first.key)
                completion(messageNode)
            }
        } withCancel: { error in
            print("Failed to load messages for channel \(channel.name ?? "")")
            completion(.emptyNode)
        }
    }
    
    static func getFirstMessage(in channel: ChatItemModel, completion: @escaping(MessageItems) -> Void) {
        FirebaseConstants.MessageRef.child(channel.id)
            .queryLimited(toFirst: 1)
            .observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                dictionary.forEach { key, value in
                    guard let messageDict = snapshot.value as? [String: Any] else { return }
                    var firstMessage = MessageItems(id: key, isGroupChat: channel.isGroupChat, dict: messageDict)
                    let messageSender = channel.members.first(where: { $0.uid == firstMessage.ownerUid })
                    firstMessage.sender = messageSender
                    completion(firstMessage)
                }
            } withCancel: { error in
                print("Failed to load first messages for channel \(channel.name ?? "")")
            }
    }
    
    static func listenForNewMessage(in channel: ChatItemModel, completion: @escaping(MessageItems) -> Void) {
        FirebaseConstants.MessageRef.child(channel.id)
            .queryLimited(toLast: 1)
            .observe(.childAdded) { snapshot in
                guard let messageDict = snapshot.value as? [String: Any] else { return }
                var newMessage = MessageItems(id: snapshot.key, isGroupChat: channel.isGroupChat, dict: messageDict)
                let messageSender = channel.members.first(where: { $0.uid == newMessage.ownerUid })
                newMessage.sender = messageSender
                completion(newMessage)
            }
    }
    
    static func increaseCountViaTransaction(at ref: DatabaseReference, completion: ((Int) -> Void)? = nil) {
        ref.runTransactionBlock { currentData in
            if var count = currentData.value as? Int {
                count += 1
                currentData.value = count
            } else {
                currentData.value = 1
            }
            completion?(currentData.value as? Int ?? 0)
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    static func addReaction(_ reaction: Reaction, to message: MessageItems, in channel: ChatItemModel, from currentUser: UserItem, completion: @escaping(_ emojiCount: Int) -> ()) {
        let reactionRef = FirebaseConstants.MessageRef.child(channel.id).child(message.id).child(.reactions).child(reaction.emoji)
        increaseCountViaTransaction(at: reactionRef) { emojiCount in
            FirebaseConstants.MessageRef.child(channel.id).child(message.id).child(.userReactions).child(currentUser.uid).setValue(reaction.emoji)
            completion(emojiCount)
        }
    }
    
    static func increaseUnreadMessageCount(in channel: ChatItemModel) {
        let membersUids = channel.membersExcludingMe.map { $0.uid }
        for uid in membersUids {
            let channelUnreadCountRef = FirebaseConstants.UserChannelsRef.child(uid).child(channel.id)
            increaseCountViaTransaction(at: channelUnreadCountRef)
        }
    }
    
    static func resetUnreadCount(in channel: ChatItemModel) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserChannelsRef.child(currentUid).child(channel.id).setValue(0)
    }
}

struct MessageNode {
    var message: [MessageItems]
    var currentCurrsor: String?
    static let emptyNode = MessageNode(message: [], currentCurrsor: nil)
}

struct MessageUploadPrams {
    let channel: ChatItemModel
    let text: String
    let type: MessageType
    let attachment: MediaAttachment
    var thumbnailURL: String?
    var videoURL: String?
    var sender: UserItem
    var audioURL: String?
    var audioDuration: TimeInterval?
    
    var ownerUID: String {
        return sender.uid
    }
    
    var thumbnailWidth: CGFloat? {
        guard type == .photo || type == .video else { return nil }
        return attachment.thumbnail.size.width
    }
    
    var thumbnailHeight: CGFloat? {
        guard type == .photo || type == .video else { return nil }
        return attachment.thumbnail.size.height
    }
}
