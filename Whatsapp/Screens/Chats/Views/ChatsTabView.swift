//
//  ChatsTabView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 13/02/25.
//

import SwiftUI

struct ChatsTabView: View {
    @State private var searchText = ""
    @StateObject private var vm: ChatsTabViewModel
    
    init(_ currentUser: UserItem) {
        self._vm = StateObject(wrappedValue: ChatsTabViewModel(currentUser))
    }
    
    var body: some View {
        NavigationStack(path: $vm.navRoutes) {
            List {
                archiveButton()
                ForEach(vm.channels) { channel in
                    Button {
                        vm.navRoutes.append(.chatRoom(channel))
                    } label: {
                        ChatsSubView(channel: channel)
                    }
                }
                inboxFooterView()
            }
            .listStyle(.grouped)
            .navigationTitle("Chats")
            .searchable(text: $searchText)
            .toolbar {
                leadingNavItem()
                trailingNavItem()
            }
            .navigationDestination(for: ChannelTabRoutes.self) { route in
                destinationView(for: route)
            }
            .sheet(isPresented: $vm.showSheet) {
                AddNewChatView(onCreate: vm.onNewChannelCreation)
            }
            .navigationDestination(isPresented: $vm.navigateToChatRoom) {
                if let newChat = vm.newChannel {
                    ChatRoomView(channel: newChat)
                }
            }
        }
    }
}

extension ChatsTabView {
    
    @ViewBuilder
    private func destinationView(for route: ChannelTabRoutes) -> some View {
        switch route {
        case .chatRoom(let channel):
            ChatRoomView(channel: channel)
        }
    }
    
    @ToolbarContentBuilder
    private func leadingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {
                    
                } label: {
                    Label("Select Chats", systemImage: "checkmark.circle")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }

        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Image(.circle)
            }
            Button {
                
            } label: {
                Image(systemName: "camera")
            }
            Button {
                vm.showSheet = true
            } label: {
                Image(.plus )
            }
        }
    }
    
    private func archiveButton() -> some View {
        Button {
            
        } label: {
            Label("Archive", systemImage: "archivebox.fill")
                .font(.subheadline)
                .foregroundStyle(Color(.systemGray))
                .padding(.vertical, 5)
        }
    }
    
    private func inboxFooterView() -> some View {
        HStack {
            Image(systemName: "lock.fill")
            
            (
                Text("Your personal messages are ")
                +
                Text("end-to-end encrypted")
                    .foregroundStyle(.blue)
            )
        }
        .foregroundStyle(.gray)
        .font(.caption)
        .padding(.horizontal)
    }
}

#Preview {
    ChatsTabView(.placeholder)
}
