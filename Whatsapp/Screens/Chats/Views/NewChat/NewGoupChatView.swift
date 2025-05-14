//
//  NewGoupChatView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 17/02/25.
//

import SwiftUI

struct NewGoupChatView: View {
    @State private var searchText = ""
    @ObservedObject var vm: AddNewChatViewModel
    
    var body: some View {
        List {
            if vm.showSelectedUser {
                SelectedChatView(users: vm.selectedChat) { user in
                    vm.handleItemSelection(user)
                }
            }
            
            Section {
                ForEach(vm.users) { item in
                    Button {
                        vm.handleItemSelection(item)
                    } label: {
                        addGroup(item)
                    }

                }
            }
            if vm.isPaginatable {
                loadUsers()
            }
        }
        .animation(.easeInOut, value: vm.showSelectedUser)
        .searchable(text: $searchText, prompt: "search for name or number")
        .toolbar {
            principal()
            trailing()
        }
        
    }
    
    private func loadUsers() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .task {
                await vm.fetchUsers()
            }
    }
    
    private func addGroup(_ user: UserItem) -> some View {
        AddContactView(user: user) {
            Spacer()
            let isSelected = vm.isUserSelected(user)
            let imageName = isSelected ? "checkmark.circle.fill" : "circle"
            let foregroundStyle = isSelected ? Color.blue : Color(.systemGray4)
            Image(systemName: imageName)
                .foregroundStyle(foregroundStyle)
                .imageScale(.large)
        }
    }
}

extension NewGoupChatView {
    @ToolbarContentBuilder
    private func principal() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text("Add participants")
                
                let count = vm.selectedChat.count
                let maxCount = ChatConstants.maxGroupParticipants
                Text("\(count) / \(maxCount)")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailing() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Next") {
                vm.navStack.append(.setUpNewGroupChat)
            }
            .bold()
            .disabled(vm.selectedChat.isEmpty)
        }
    }
}

#Preview {
    NavigationStack {
        NewGoupChatView(vm: AddNewChatViewModel())
    }
}
