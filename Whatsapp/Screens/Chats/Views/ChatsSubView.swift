//
//  ChatsSubView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 13/02/25.
//

import SwiftUI

struct ChatsSubView: View {
    let channel: ChatItemModel
    
    var body: some View {
        HStack {
            CircularProfileImageView(channel, size: .small)
            
            VStack(alignment: .leading) {
                Text(channel.title)
                    .lineLimit(1)
                    .font(.subheadline)
                
                HStack(spacing: 4) {
                    if channel.lastMessageType != .text {
                        Image(systemName: channel.lastMessageType.iconName)
                            .imageScale(.small)
                    }
                    Text(channel.previewMessage)
                        .font(.footnote)
                }
                .foregroundStyle(.gray)
            }
            Spacer()
            Text(channel.lastMessageTimeStamp.dayOrTimeRepersentation)
                .font(.footnote)
                .foregroundStyle(.gray)
        }
        .overlay(alignment: .bottomTrailing) {
            if channel.unReadCount > 0 {
                badgeView(channel.unReadCount)
            }
        }
    }
    
    private func badgeView(_ count: Int) -> some View {
        Text(count.description)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(.white)
            .background(.badge)
            .clipShape(Capsule())
    }
}

#Preview {
    ChatsSubView(channel: .placeholder)
}
