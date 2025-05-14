//
//  AdminMessageTextView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 19/02/25.
//

import SwiftUI

struct AdminMessageTextView: View {
    let channel: ChatItemModel
    
    var body: some View {
        VStack {
            if channel.isCreatedByMe {
                textView("You created this group. Tap to add\n members")
            } else {
                textView("\(channel.creatorName) created this group")
                textView("\(channel.creatorName) added you")
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func textView(_ text: String) -> some View {
        Text(text)
            .multilineTextAlignment(.center)
            .font(.footnote)
            .padding(8)
            .background(.bubbleWhite)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: Color(.systemGray4), radius: 6, x: 4, y: 3)
    }
}

#Preview {
    ZStack {
        Color.gray
        AdminMessageTextView(channel: .placeholder)
    }
}
