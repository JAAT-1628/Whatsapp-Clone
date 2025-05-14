//
//  SettingsTabView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 13/02/25.
//

import SwiftUI
import PhotosUI

struct SettingsTabView: View {
    @State private var searchText = ""
    @StateObject private var vm: SettingsTabViewModel
    private var currentUser: UserItem
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        self._vm = StateObject(wrappedValue: SettingsTabViewModel(currentUser))
    }
    
    var body: some View {
        NavigationStack {
            List {
                SettingsProfileView(vm, currentUser)
                
                Section {
                    SettingsItemsView(item: .broadCastLists)
                    SettingsItemsView(item: .starredMessages)
                    SettingsItemsView(item: .linkedDevices)
                }
                
                Section {
                    SettingsItemsView(item: .account)
                    SettingsItemsView(item: .privacy)
                    SettingsItemsView(item: .chats)
                    SettingsItemsView(item: .notifications)
                    SettingsItemsView(item: .storage)
                }
                
                Section {
                    SettingsItemsView(item: .help)
                    SettingsItemsView(item: .tellFriend)
                }
                
                Section {
                    logOutButton()
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Settings")
            .searchable(text: $searchText)
            .toolbar {
                tralingSaveButton()
            }
            .alert("Update your Profile", isPresented: $vm.showUserInfoEditor) {
                TextField("Username", text: $vm.name)
                TextField("Bio", text: $vm.bio)
                Button("Update") { vm.updateUsernameBio() }
                Button("Cancel", role: .cancel) { }
                    
            } message: {
                Text("Enter your new username or bio")
            }
        }
    }
    
    @ToolbarContentBuilder
    private func tralingSaveButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                vm.uploadProfilePhoto()
            } label: {
                Text("Save")
                    .disabled(vm.disableSaveButton)
            }
        }
    }
    
    private func logOutButton() -> some View {
        Label("Log Out", systemImage: "figure.walk.circle")
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 45)
            .padding(.horizontal, 5)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(10)
            .font(.headline)
            .foregroundStyle(.red)
            .onTapGesture {
                Task {
                    try? await AuthManager.shared.logOut()
                }
            }
    }
}

private struct SettingsProfileView: View {
    @ObservedObject private var vm: SettingsTabViewModel
    private var currentUser: UserItem
    
    init(_ vm: SettingsTabViewModel, _ currentUser: UserItem) {
        self.vm = vm
        self.currentUser = currentUser
    }
    
    var body: some View {
        Section {
            HStack(alignment: .top) {
                profileImage()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(currentUser.username)
                        .font(.headline)
                    Text(currentUser.bioUnwrapped)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                .onTapGesture {
                    vm.showUserInfoEditor.toggle()
                }
                Spacer()
                Image(.qrcode)
                    .renderingMode(.template)
                    .foregroundStyle(.blue)
                    .padding(4)
                    .background(Color(.systemGray4))
                    .clipShape(Circle())
            }
            PhotosPicker(selection: $vm.selectPhotoItem, matching: .not(.videos)) {
                SettingsItemsView(item: .avatar)
            }
        }
    }
    @ViewBuilder
    private func profileImage() -> some View {
        if let profilePhoto = vm.profilePhoto {
            Image(uiImage: profilePhoto.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
        } else {
            CircularProfileImageView(currentUser.profileImageUrl, size: .medium)
        }
    }
}

#Preview {
    SettingsTabView(.placeholder)
}
