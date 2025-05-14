//
//  ChatCreationView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 19/02/25.
//

import SwiftUI

struct ChatCreationView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.gray : Color.yellow
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            (
                Text(Image(systemName: "lock.fill"))
                +
                Text("  Messages and calls are end-to-end encrypted, No one outside of this chat, Not even WhatsApp, can read or listen to them. ")
                +
                Text("read more")
                    .bold()
            )
        }
        .font(.footnote)
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(backgroundColor.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal, 30)
    }
}

#Preview {
    ChatCreationView()
}
