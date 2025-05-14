//
//  ChatRoomView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 13/02/25.
//

import SwiftUI
import PhotosUI

struct ChatRoomView: View {
    let channel: ChatItemModel
    @StateObject private var vm: ChatRoomViewModel
    @StateObject private var voiceMessagePlayer = VoiceMessagePlayer()
    @Environment(\.dismiss) var dismiss
    
    init(channel: ChatItemModel) {
        self.channel = channel
        _vm = StateObject(wrappedValue: ChatRoomViewModel(channel))
    }
    
    var body: some View {
        MessageListView(vm)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            leadingNavItems()
            tralingNavItems()
        }
        .photosPicker(isPresented: $vm.showPhotoPicker, selection: $vm.photoPickerItem, maxSelectionCount: 12, photoLibrary: .shared())
        .safeAreaInset(edge: .bottom) {
            bottomSafeAreaView()
                .background(.thinMaterial)
                .padding(.top, 10)
        }
        .animation(.easeInOut, value: vm.showPhotoPickerPreview)
        .fullScreenCover(isPresented: $vm.videoPlayerState.show) {
            if let player = vm.videoPlayerState.player {
                MediaPlayerView(player: player) {
                    vm.dismissMediaPlayer()
                }
            }
        }
        .environmentObject(voiceMessagePlayer)
    }
    
    private func bottomSafeAreaView() -> some View {
        VStack(spacing: 8) {
            if vm.showPhotoPickerPreview {
                MediaAttachmentPreview(mediaAttachment: vm.mediaAttachments) { action in 
                    vm.handelMediaAttachmentPreview(action)
                }
            }
            TextInputAreaView(textMessage: $vm.textMessage, isRecording: $vm.isRecordingVoiceMessage, elapsedTime: $vm.elapsedVoiceMessageTime, mediaSendButton: vm.disableSendButton) { action in 
                vm.handelTextInputArea(action)
            }
        }
    }
}

//MARK: ToolBar Items
extension ChatRoomView {
    
    private var channelTitle: String {
        let maxChar = 20
        let trailingChar = channel.title.count > maxChar ? "..." : ""
        let title = String(channel.title.prefix(maxChar) + trailingChar)
        return title
    }
    
    @ToolbarContentBuilder
    private func leadingNavItems() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
            }

            CircularProfileImageView(channel, size: .xSmall)
            Text(channelTitle)
                .font(.headline)
        }
    }
    
    @ToolbarContentBuilder
    private func tralingNavItems() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Image(systemName: "video")
            }
            Button {
                
            } label: {
                Image(systemName: "phone")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatRoomView(channel: .placeholder)
    }
}
