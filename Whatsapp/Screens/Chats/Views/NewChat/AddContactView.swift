//
//  AddContactView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 16/02/25.
//

import SwiftUI

struct AddContactView<Content: View>: View {
    private let user: UserItem
    private let tralingItem: Content
    
    init(user: UserItem, @ViewBuilder tralingItem: () -> Content = { EmptyView() }) {
        self.user = user
        self.tralingItem = tralingItem()
    }
    
    var body: some View {
        HStack {
            CircularProfileImageView(user.profileImageUrl, size: .xSmall)
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .font(.subheadline)
                
                Text(user.bioUnwrapped)
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
            
            tralingItem
        }
    }
}

#Preview {
    AddContactView(user: .placeholder)
}
