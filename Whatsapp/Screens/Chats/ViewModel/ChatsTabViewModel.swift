//
//  ChatsTabViewModel.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 18/02/25.
//

import Foundation
import FirebaseAuth

enum ChannelTabRoutes: Hashable {
    case chatRoom(_ channel: ChatItemModel)
}

final class ChatsTabViewModel: ObservableObject {
    
    @Published var navRoutes = [ChannelTabRoutes]()
    @Published var navigateToChatRoom = false
    @Published var newChannel: ChatItemModel?
    @Published var showSheet = false
    @Published var channels = [ChatItemModel]()
    typealias ChannelId = String
    @Published var channelDictionary: [ChannelId: ChatItemModel] = [:]
    
    private let currentUser: UserItem
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        fetchCurrentUserChannels()
    }
    
    func onNewChannelCreation(_ channel: ChatItemModel) {
        showSheet = false
        newChannel = channel
        navigateToChatRoom = true
    }
    
    private func fetchCurrentUserChannels() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserChannelsRef.child(currentUid).queryLimited(toFirst: 10).observe(.value) {[weak self] snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }
            dict.forEach { key, value in
                let channelId = key
                let unreadCount = value as? Int ?? 0
                self?.getChannel(with: channelId, unreadCount)
            }
        } withCancel: { error in
            print("Failed to get the current user's channelIds: \(error.localizedDescription)")
        }

    }
    
    private func getChannel(with channelId: String, _ unreadCount: Int) {
        FirebaseConstants.ChannelsRef.child(channelId).observe(.value) {[weak self] snapshot in
            guard let dict = snapshot.value as? [String: Any], let self = self else { return }
            var channel = ChatItemModel(dict)
            if let memCachedChannel = self.channelDictionary[channelId], !memCachedChannel.members.isEmpty {
                channel.members = memCachedChannel.members
                channel.unReadCount = unreadCount
                self.channelDictionary[channelId] = channel
                self.reloadData()
            } else {
                self.getChannelMembers(channel) { members in
                    channel.members = members
                    channel.unReadCount = unreadCount
                    channel.members.append(self.currentUser)
                    self.channelDictionary[channelId] = channel
                    self.reloadData()
                }
            }
        } withCancel: { error in
            print("Failed to get the channel for id \(channelId): \(error.localizedDescription)")
        }
    }
    
    private func getChannelMembers(_ channel: ChatItemModel, completion: @escaping (_ members: [UserItem]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let channelMemberUids = Array(channel.membersUids.filter { $0 != currentUid }.prefix(2))
        UserService.getUsers(with: channelMemberUids) { userNode in
            completion(userNode.users)
        }
    }
    
    
    private func reloadData() {
        self.channels = Array(channelDictionary.values)
        self.channels.sort { $0.lastMessageTimeStamp > $1.lastMessageTimeStamp }
    }
}
