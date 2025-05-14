//
//  AddNewChatViewModel.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 17/02/25.
//

import Foundation
import FirebaseAuth
import Combine

enum ChatCreatingRoutes {
    case addGroupChatMembers
    case setUpNewGroupChat
}

enum ChatConstants {
    static let maxGroupParticipants = 12
}

enum ChatCreationError: Error {
    case noChatPartner
    case failedToCreateUniqueIds
}

@MainActor
final class AddNewChatViewModel: ObservableObject {
    @Published var navStack = [ChatCreatingRoutes]()
    @Published var selectedChat = [UserItem]()
    @Published private(set) var users = [UserItem]()
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "UH OHH")
    
    private var lastCursor: String?
    private var currentUser: UserItem?
    private var subscription: AnyCancellable?
    
    var showSelectedUser: Bool { !selectedChat.isEmpty }
    var isPaginatable: Bool { !users.isEmpty }
    var isDirectChannel: Bool { selectedChat.count == 1 }
    
    init() {
        listenToAuthState()
    }
    
    deinit {
        subscription?.cancel()
        subscription = nil
    }
    
    private func listenToAuthState() {
        subscription = AuthManager.shared.authState.receive(on: DispatchQueue.main).sink { [weak self] authState in
            switch authState {
            case .loggedIn(let loggedInUser):
                self?.currentUser = loggedInUser
                Task { await self?.fetchUsers() }
            default:
                break
            }
        }
    }
    
    func fetchUsers() async {
        do {
            let userNode = try await UserService.paginateUsers(lastCursor: lastCursor, pageSize: 5)
            var fetchedUsers = userNode.users
            guard let curretnUid = Auth.auth().currentUser?.uid else { return }
            fetchedUsers = fetchedUsers.filter { $0.uid != curretnUid }
            self.users.append(contentsOf: fetchedUsers)
            self.lastCursor = userNode.currentCursor
            print("last Cursor \(lastCursor ?? "") \(users.count)")
        } catch {
            print("Failed to fetch users in AddNewChatViewModel")
        }
    }
    
    func handleItemSelection(_ item: UserItem) {
        if isUserSelected(item) {
            guard let index = selectedChat.firstIndex(where: { $0.uid == item.uid }) else { return }
            selectedChat.remove(at: index)
        } else {
            guard selectedChat.count < 12 else {
                showError("Sorry, we only allow a Maximum of 12 participants in a group chat")
                return
            }
            selectedChat.append(item)
        }
    }
    
    func isUserSelected(_ user: UserItem) -> Bool {
        let isSelected = selectedChat.contains { $0.uid == user.uid }
        return isSelected
    }
    
    func createDirectChat(_ chatPartner: UserItem, completion: @escaping (_ newChat: ChatItemModel) -> Void) {
        if selectedChat.isEmpty {
            selectedChat.append(chatPartner)
        }
        Task {
            // if chat with partner alredy exists
            if let channelId = await verifyIfDirectChannelExist(with: chatPartner.uid) {
                let snapshot = try await FirebaseConstants.ChannelsRef.child(channelId).getData()
                let channelDict = snapshot.value as! [String: Any]
                var directChannel = ChatItemModel(channelDict)
                directChannel.members = selectedChat
                if let currentUser {
                    directChannel.members.append(currentUser)
                }
                completion(directChannel)
            } else {
                // creating new chat with partner if it does not exists
                let channelCreation = createChannel(nil)
                switch channelCreation {
                case .success(let channel):
                    completion(channel)
                case .failure(let error):
                    showError("Sorry, something went wrong while we were trying to setup your chat.")
                    print("Failed to create a Direct chat \(error.localizedDescription)")
                }
            }
        }
    }
    
    typealias ChannelId = String
    private func verifyIfDirectChannelExist(with chatPartnerId: String) async -> ChannelId? {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let snapshot = try? await FirebaseConstants.UserDirectChannels.child(currentUid).child(chatPartnerId).getData(),
              snapshot.exists() else { return nil }
        
        let directMessageDict = snapshot.value as! [String: Bool]
        let channelId = directMessageDict.compactMap { $0.key }.first
        return channelId
    }

    
    func createGroupChat(_ groupName: String?, completion: @escaping (_ newChat: ChatItemModel) -> Void) {
        let channelCreation = createChannel(groupName)
        switch channelCreation {
        case .success(let channel):
            completion(channel)
        case .failure(let error):
            showError("Sorry, something went wrong while we were trying to setup your Group Chat.")
            print("Failed to create Group chat \(error.localizedDescription)")
        }
    }
    
    private func showError(_ errorMessage: String) {
        errorState.errorMessage = errorMessage
        errorState.showError = true
    }
    
    private func createChannel(_ chatName: String?) -> Result<ChatItemModel, Error> {
        guard !selectedChat.isEmpty else { return .failure(ChatCreationError.noChatPartner) }
        
        guard let channelId = FirebaseConstants.ChannelsRef.childByAutoId().key,
              let currentUid = Auth.auth().currentUser?.uid,
              let messageId = FirebaseConstants.MessageRef.childByAutoId().key
        else { return .failure(ChatCreationError.failedToCreateUniqueIds) }
        
        let timeStamp = Date().timeIntervalSince1970
        var membersUids = selectedChat.compactMap { $0.uid }
        membersUids.append(currentUid)
        
         let newChannelBroadcast = MessageAdminType.channelCreation.rawValue
         
        var channelDict: [String: Any] = [
            .id: channelId,
            .lastMessage: newChannelBroadcast,
            .lastMessageType: newChannelBroadcast,
            .creationDate: timeStamp,
            .lastMessageTimeStamp: timeStamp,
            .membersUids: membersUids,
            .membersCount: membersUids.count,
            .adminUids: [currentUid],
            .createdBy: currentUid
        ]
        
        if let chatName = chatName, !chatName.isEmptyOrWhiteSpace {
            channelDict[.name] = chatName
        }
         
         let messageDict: [String: Any] = [.type: newChannelBroadcast, .timeStamp: timeStamp, .ownerUid: currentUid]
        
        FirebaseConstants.ChannelsRef.child(channelId).setValue(channelDict)
         FirebaseConstants.MessageRef.child(channelId).child(messageId).setValue(messageDict)
        
        membersUids.forEach { userId in
            FirebaseConstants.UserChannelsRef.child(userId).child(channelId).setValue(true)
        }
         
         if isDirectChannel {
             let chatPartner = selectedChat[0]
             FirebaseConstants.UserDirectChannels.child(currentUid).child(chatPartner.uid).setValue([channelId: true])
             FirebaseConstants.UserDirectChannels.child(chatPartner.uid).child(currentUid).setValue([channelId: true])
         }
        
         var newChannelItem = ChatItemModel(channelDict)
         if let currentUser {
             newChannelItem.members.append(currentUser)
         }
         newChannelItem.members = selectedChat
         return .success(newChannelItem)
    }
}
