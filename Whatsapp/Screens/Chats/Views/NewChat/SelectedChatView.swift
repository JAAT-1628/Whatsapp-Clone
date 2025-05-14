//
//  SelectedChatView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 17/02/25.
//

import SwiftUI

struct SelectedChatView: View {
    let users: [UserItem]
    let onTapHandler: (_ user: UserItem) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(users) { item in
                    selectedChatView(item)
                }
            }
        }
    }
    
    private func selectedChatView(_ user: UserItem) -> some View {
        VStack {
            CircularProfileImageView(user.profileImageUrl, size: .medium)
                .overlay(alignment: .topTrailing) {
                    cancelButton(user)
                }
            
            Text(user.username)
        }
    }
    
    private func cancelButton(_ user: UserItem) -> some View {
        Button {
            onTapHandler(user)
        } label: {
            Image(systemName: "xmark")
                .foregroundStyle(.white)
                .padding(3)
                .background(Color(.systemGray2))
                .clipShape(Circle())
        }

    }
}

#Preview {
    SelectedChatView(users: UserItem.placeholders) { user in 
        
    }
}
