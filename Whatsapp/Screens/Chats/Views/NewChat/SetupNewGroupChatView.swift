//
//  SetupNewGroupChatView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 17/02/25.
//

import SwiftUI

struct SetupNewGroupChatView: View {
    @State private var text = ""
    @ObservedObject var vm: AddNewChatViewModel
    var onCreate: (_ newChat: ChatItemModel) -> Void

    var body: some View {
        List {
            Section {
                groupName()
            }
            
            Section {
                Text("Disappearing Messages")
                Text("Group Permissions")
            }
            
            Section {
                SelectedChatView(users: vm.selectedChat) { user in
                    vm.handleItemSelection(user)
                }
            } header: {
                let count = vm.selectedChat.count
                Text("Members: \(count) / 12")
                    .font(.subheadline)
                    .textCase(nil)
            }
        }
        .navigationTitle("New Group")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            trailing()
        }
    }
    
    private func groupName() -> some View {
        HStack {
            Image(systemName: "camera")
                .padding(10)
                .foregroundStyle(.blue)
                .background(Color(.systemGray4))
                .clipShape(Circle())
            
            TextField("Group Name", text: $text)
                .padding(8)
                .background(Color(.systemGray5))
                .cornerRadius(10)
        }
    }
    
    @ToolbarContentBuilder
    private func trailing() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Create") {
                if vm.isDirectChannel {
                    guard let chatPartner = vm.selectedChat.first else { return }
                    vm.createDirectChat(chatPartner, completion: onCreate)
                } else {
                    vm.createGroupChat(text, completion: onCreate)
                }
            }
            .bold()
            .disabled(vm.selectedChat.isEmpty)
        }
    }
}

#Preview {
    NavigationStack {
        SetupNewGroupChatView(vm: AddNewChatViewModel()) { _ in
            
        }
    }
}
