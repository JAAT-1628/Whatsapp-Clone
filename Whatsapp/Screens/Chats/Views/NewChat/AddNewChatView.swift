//
//  AddNewChatView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 16/02/25.
//

import SwiftUI

struct AddNewChatView: View {
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = AddNewChatViewModel()
    
    var onCreate: (_ newChat: ChatItemModel) -> Void
    
    var body: some View {
        NavigationStack(path: $vm.navStack) {
            List {
                ForEach(CreateOptions.allCases) { item in
                    AddButtons(item: item)
                        .onTapGesture {
                            vm.navStack.append(.addGroupChatMembers)
                        }
                }
                
                Section {
                    ForEach(vm.users) { user in
                        AddContactView(user: user)
                            .onTapGesture {
                                vm.createDirectChat(user, completion: onCreate)
                            }
                    }
                } header: {
                    Text("Contacts on Whatsapp")
                        .textCase(nil)
                        .font(.subheadline)
                }
                if vm.isPaginatable {
                    loadUsers()
                }
            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search name or number")
            .navigationDestination(for: ChatCreatingRoutes.self) { route in
                destinationView(for: route)
            }
            .alert(isPresented: $vm.errorState.showError) {
                Alert(title: Text("Error!!"), message: Text(vm.errorState.errorMessage),
                      dismissButton: .default(Text("OK")))
            }
            .toolbar {
                tralingNavButton()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    vm.selectedChat.removeAll()
                }
            }
        }
    }
    
    private func loadUsers() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .task {
                await vm.fetchUsers()
            }
    }
    
    @ToolbarContentBuilder
    private func tralingNavButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.footnote)
                    .padding(4)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Circle())
            }
            
        }
    }
}

extension AddNewChatView {
    @ViewBuilder
    private func destinationView(for routes: ChatCreatingRoutes) -> some View {
        switch routes {
        case .addGroupChatMembers:
            NewGoupChatView(vm: vm)
        case .setUpNewGroupChat:
            SetupNewGroupChatView(vm: vm, onCreate: onCreate)
        }
    }
}

extension AddNewChatView {
    private struct AddButtons: View {
        let item: CreateOptions
        
        var body: some View {
            Button {
                
            } label: {
                buttonBody()
            }
        }
        
        private func buttonBody() -> some View {
            HStack {
                Image(systemName: item.imageName)
                    .font(.title3)
                    .frame(width: 35, height: 37)
                    .foregroundStyle(.green)
                
                Text(item.title)
                    .font(.subheadline)
            }
        }
    }
}

enum CreateOptions: String, Identifiable, CaseIterable {
    case newGroup = "New Group"
    case newContact = "New Contact"
    case newCommunity = "New Community"
    case ChatWithAi = "Chat with AIs"
    case newBroadcast = "New Broadcast"
    
    var id: String { rawValue }
    var title: String { rawValue }
    
    var imageName: String {
        switch self {
        case .newGroup:
            "person.2"
        case .newContact:
            "person.badge.plus"
        case .newCommunity:
            "person.3"
        case .ChatWithAi:
            "command.square"
        case .newBroadcast:
            "megaphone"
        }
    }
}

#Preview {
    AddNewChatView { chat in
        
    }
}
