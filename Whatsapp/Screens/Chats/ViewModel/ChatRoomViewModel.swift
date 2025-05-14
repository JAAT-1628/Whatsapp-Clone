//
//  ChatRoomViewModel.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 19/02/25.
//

import Foundation
import Combine
import SwiftUI
import PhotosUI

final class ChatRoomViewModel: ObservableObject {
    @Published var textMessage = ""
    @Published var messages = [MessageItems]()
    @Published var showPhotoPicker = false
    @Published var photoPickerItem: [PhotosPickerItem] = []
    @Published var mediaAttachments: [MediaAttachment] = []
    @Published var videoPlayerState: (show: Bool, player: AVPlayer?) = (false, nil)
    @Published var isRecordingVoiceMessage = false
    @Published var elapsedVoiceMessageTime: TimeInterval = 0
    @Published var scrollToBottomRequest: (scroll: Bool, isAnimated: Bool) = (false, false)
    @Published var isPaginating = false
    
    private var firstMessage: MessageItems?
    private var currentPage: String?
    private(set) var channel: ChatItemModel
    private var subscriptions = Set<AnyCancellable>()
    private var currentUser: UserItem?
    private let audioRecordingService = AudioRecordingService()
    
    var showPhotoPickerPreview: Bool { !mediaAttachments.isEmpty || !photoPickerItem.isEmpty }
    var disableSendButton: Bool { mediaAttachments.isEmpty }
    
    init(_ channel: ChatItemModel) {
        self.channel = channel
        listenToAuthState()
        onPhotoPickerSelection()
        setupAudioRecordingListners()
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        currentUser = nil
        audioRecordingService.tearDown()
    }
    
    private func listenToAuthState() {
        AuthManager.shared.authState.receive(on: DispatchQueue.main).sink {[weak self] authState in
            guard let self = self else { return }
            switch authState {
            case .loggedIn(let currentUser):
                self.currentUser = currentUser
                
                if self.channel.allMembersFetched {
                    self.getHistoricalMessages()
                } else {
                    self.getAllChannelMembers()
                }
                
            default:
                break
            }
        }.store(in: &subscriptions)
    }
    
    private func setupAudioRecordingListners() {
        audioRecordingService.$isRecording.receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                self?.isRecordingVoiceMessage = isRecording
            }.store(in: &subscriptions)
        
        audioRecordingService.$elaspedTime.receive(on: DispatchQueue.main)
            .sink { [weak self] elaspedTime in
                self?.elapsedVoiceMessageTime = elaspedTime
            }.store(in: &subscriptions)
    }
    
    func sendMessage() {
        if mediaAttachments.isEmpty {
            sendTextMessage(textMessage)
        } else {
            sendMultypleMediaMessages(textMessage, attachments: mediaAttachments)
            clearInputArea()
        }
    }
    
    private func sendTextMessage(_ text: String) {
        guard let currentUser else { return }
        MessageServices.sendTextMessage(to: channel, from: currentUser, text) {[weak self] in
            self?.scrollToBottom(isAnimated: true)
            self?.textMessage = ""
        }
    }
    
    private func clearInputArea() {
        textMessage = ""
        mediaAttachments.removeAll()
        photoPickerItem.removeAll()
        UIApplication.dismissKeyboard()
    }
    
    private func sendMultypleMediaMessages(_ text: String, attachments: [MediaAttachment]) {
        for (index, attachment) in attachments.enumerated() {
            let textMessage = index == 0 ? text : ""
            switch attachment.type {
            case .photo:
                sendPhotoMessage(text: textMessage, attachment)
            case .video:
                sendVideoMessage(text: textMessage, attachment)
            case .audio:
                sendVoiceMessage(text: textMessage, attachment)
            }
        }
    }
    
    private func sendPhotoMessage(text: String, _ attachment: MediaAttachment) {
        uploadImageToStorage(attachment) { [weak self] imageURL in
            guard let self = self, let currentUser else { return }
            
            let uploadPrams = MessageUploadPrams(
                channel: channel,
                text: text,
                type: .photo,
                attachment: attachment,
                thumbnailURL: imageURL.absoluteString,
                sender: currentUser)
                        
            MessageServices.sendMediaMessage(to: channel, params: uploadPrams) { [weak self] in
                self?.scrollToBottom(isAnimated: true)
            }
        }
    }
    
    private func sendVideoMessage(text: String, _ attachment: MediaAttachment) {
        uploadFileToStorage(for: .videoMessage, attachment) { [weak self] videoURL in
            self?.uploadImageToStorage(attachment, completion: { [weak self] thumbnailURL in
                guard let self = self, let currentUser else { return }
                let uploadParams = MessageUploadPrams(channel: self.channel, text: text, type: .video, attachment: attachment, thumbnailURL: thumbnailURL.absoluteString, videoURL: videoURL.absoluteString, sender: currentUser)
                
                MessageServices.sendMediaMessage(to: self.channel, params: uploadParams) { [weak self] in
                    self?.scrollToBottom(isAnimated: true)
                }
            })
        }
    }
    
    private func sendVoiceMessage(text: String, _ attachment: MediaAttachment) {
        guard let audioDuration = attachment.audioDuration, let currentUser else { return }
        uploadFileToStorage(for: .audioMessage, attachment) { [weak self] fileURL in
            guard let self = self else { return }
            let uploadParams = MessageUploadPrams(
                channel: self.channel,
                text: text,
                type: .audio,
                attachment: attachment,
                sender: currentUser,
                audioURL: fileURL.absoluteString,
                audioDuration: audioDuration)
            
            MessageServices.sendMediaMessage(to: self.channel, params: uploadParams) { [weak self] in
                self?.scrollToBottom(isAnimated: true)
            }
            if !textMessage.isEmptyOrWhiteSpace {
                self.sendTextMessage(text)
            }
        }
    }
    
    private func scrollToBottom(isAnimated: Bool) {
        scrollToBottomRequest.scroll = true
        scrollToBottomRequest.isAnimated = isAnimated
    }
    
    private func uploadImageToStorage(_ attachment: MediaAttachment, completion: @escaping(_ imageURL: URL) -> ()) {
        FirebaseHelper.uploadImage(attachment.thumbnail, for: .photoMessage) { result in
            switch result {
                
            case .success(let imageURL):
                completion(imageURL)
            case .failure(let error):
                print("Failed to upload image to Storage \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            print("Uploading image progress \(progress)")
        }
    }
    
    private func uploadFileToStorage(for uploadType: FirebaseHelper.UploadType, _ attachment: MediaAttachment, completion: @escaping(_ fileURL: URL) -> ()) {
        guard let fileToUpload = attachment.fileURL else { return }
        FirebaseHelper.uploadFile(for: uploadType, fileURL: fileToUpload) { result in
            switch result {
                
            case .success(let fileUrl):
                completion(fileUrl)
            case .failure(let error):
                print("Failed to upload file to Storage \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            print("Uploading file progress \(progress)")
        }
    }
    
    var isPaginatable: Bool { return currentPage != firstMessage?.id }
    
    private func getHistoricalMessages() {
            isPaginating = currentPage != nil
        MessageServices.getHistoricalMessages(for: channel, lastCurrsor: currentPage, pageSize: 15) { [weak self] messageNode in
            if self?.currentPage == nil {
                self?.getFirstMessage()
                self?.listenForNewMessage()
            }
            self?.messages.insert(contentsOf: messageNode.message, at: 0)
            self?.currentPage = messageNode.currentCurrsor
            self?.scrollToBottom(isAnimated: false)
            self?.isPaginating = false
        }
    }
    
    func paginateMoreMessages() {
        guard isPaginatable else {
            isPaginating = false
            return
        }
        getHistoricalMessages()
    }
    
    private func getFirstMessage() {
        MessageServices.getFirstMessage(in: channel) { [weak self] firstMessage in
            self?.firstMessage = firstMessage
        }
    }
    
    private func listenForNewMessage() {
        MessageServices.listenForNewMessage(in: channel) { [weak self] newMessage in
            self?.messages.append(newMessage)
            self?.scrollToBottom(isAnimated: false)
            guard let self = self else { return }
            MessageServices.resetUnreadCount(in: self.channel)
        }
    }
    
    private func getAllChannelMembers() {
        guard let currentUser = currentUser else { return }
        let membersAlreadyFetched = channel.members.compactMap { $0.uid }
        var membersUidsToFetch = channel.membersUids.filter { !membersAlreadyFetched.contains($0) }
        membersUidsToFetch = membersUidsToFetch.filter { $0 != currentUser.uid }
        
        UserService.getUsers(with: membersUidsToFetch) { [weak self] userNode in
            guard let self = self else { return }
            self.channel.members.append(contentsOf: userNode.users)
            self.getHistoricalMessages()
        }
    }
    
    func handelTextInputArea(_ action: TextInputAreaView.UserAction) {
        switch action {
        case .presentPhotoPicker:
            showPhotoPicker = true
        case .sendMessage:
            sendMessage()
        case .recordAudio:
            toggleAudioRecording()
        }
    }
    
    private func toggleAudioRecording() {
        if audioRecordingService.isRecording {
            audioRecordingService.stopRecording { [weak self] audioURL, audioDuration in
                self?.createAudioAttachmet(from: audioURL, audioDuration)
            }
        } else {
            audioRecordingService.startRecording()
        }
    }
    
    private func createAudioAttachmet(from audioURL: URL?, _ audioDuration: TimeInterval) {
        guard let audioURL = audioURL else { return }
        let id = UUID().uuidString
        let audioAttachment = MediaAttachment(id: id, type: .audio(audioURL, audioDuration))
        mediaAttachments.insert(audioAttachment, at: 0)
    }
    
    private func onPhotoPickerSelection() {
        $photoPickerItem.sink { [weak self] photoItems in
            guard let self = self else { return }
//            self.mediaAttachments.removeAll()
            let audioRecording = mediaAttachments.filter({ $0.type == .audio(.stubURL, 0) })
            self.mediaAttachments = audioRecording
            Task { await self.parsePhotoPickerItems(photoItems) }
        }.store(in: &subscriptions)
    }
    
    private func parsePhotoPickerItems(_ photoPickerItems: [PhotosPickerItem]) async {
        for photoItem in photoPickerItem {
            if photoItem.isVideo {
                if let movie = try? await photoItem.loadTransferable(type: VideoPickerTransferable.self),
                   let thumbnailImage = try? await movie.url.generateVideoThumbnail(),
                   let itemIdentifier = photoItem.itemIdentifier {
                    let videoAttachment = MediaAttachment(id: itemIdentifier, type: .video(thumbnailImage, movie.url))
                    self.mediaAttachments.insert(videoAttachment, at: 0)
                }
            } else {
                guard let data = try? await photoItem.loadTransferable(type: Data.self),
                      let thumbnail = UIImage(data: data),
                      let itemIdentifier = photoItem.itemIdentifier else { return }
                let photoAttachment = MediaAttachment(id: itemIdentifier, type: .photo(thumbnail))
                self.mediaAttachments.insert(photoAttachment, at: 0)
            }
        }
    }
    
    func dismissMediaPlayer() {
        videoPlayerState.player?.replaceCurrentItem(with: nil)
        videoPlayerState.player = nil
        videoPlayerState.show = false
    }
    
    func showMediaPlayer(_ fileURL: URL) {
        videoPlayerState.show = true
        videoPlayerState.player = AVPlayer(url: fileURL)
    }
    
    func handelMediaAttachmentPreview(_ action: MediaAttachmentPreview.UserAction) {
        switch action {
        case .play(let attachment):
            guard let fileURL = attachment.fileURL else { return }
            showMediaPlayer(fileURL)
        case .remove(let attachment):
            remove(attachment)
            guard let fileURL = attachment.fileURL else { return }
            if attachment.type == .audio(.stubURL, 0) {
                audioRecordingService.deleteRecording(at: fileURL)
            }
        }
    }
    
    private func remove(_ item: MediaAttachment) {
        guard let attachmentIndex = mediaAttachments.firstIndex(where: { $0.id == item.id }) else { return }
        mediaAttachments.remove(at: attachmentIndex)
        
        guard let photoIndex = photoPickerItem.firstIndex(where: { $0.itemIdentifier == item.id }) else { return }
        photoPickerItem.remove(at: photoIndex)
    }
    
    func isNewDay(for message: MessageItems, at index: Int) -> Bool {
        let priorIndex = max(0, (index - 1))
        let priorMessage = messages[priorIndex]
        return !message.timeStamp.isSameDay(as: priorMessage.timeStamp)
    }
    
    func showSendrName(for message: MessageItems, at index: Int) -> Bool {
        guard channel.isGroupChat else { return false }
        let isNewDay = isNewDay(for: message, at: index)
        let priorIndex = max(0, (index - 1))
        let priorMessage = messages[priorIndex]
        
        if isNewDay {
            return !message.isSentByMe
        } else {
            return !message.isSentByMe && !message.containSameOwner(as: priorMessage)
        }
    }
    
    func addReaction(_ reaction: Reaction, to message: MessageItems) {
        guard let currentUser else { return }
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
        MessageServices.addReaction(reaction, to: message, in: channel, from: currentUser) { [weak self] emojiCount in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.messages[index].reactions[reaction.emoji] = emojiCount
                self?.messages[index].userReactions[currentUser.uid] = reaction.emoji
            }
        }
    }
}
