//
//  BubbleView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 23/02/25.
//

import SwiftUI

struct BubbleView: View {
    let message: MessageItems
    let channel: ChatItemModel
    let isNewDay: Bool
    let showSenderName: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isNewDay {
                newDayTimeStampTextView()
                    .padding()
            }
            if showSenderName {
                senderNameTextView()
            }
            composeDyanmicBubbleView()
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, message.hasReactions ? 12 : 0)
    }
    @ViewBuilder
    private func composeDyanmicBubbleView() -> some View {
        switch message.type {
        case .text:
            MessageTextView(item: message)
        case .photo, .video:
            MessageImageView(item: message)
        case .audio:
            MessageAudioView(item: message)
        case .admin(let adminType):
            switch adminType {
            case .channelCreation:
                newDayTimeStampTextView()
                ChatCreationView()
                    .padding()
                if channel.isGroupChat {
                    AdminMessageTextView(channel: channel)
                }
            default:
                Text("UNKNOWN")
            }
        }
    }
    
    private func newDayTimeStampTextView() -> some View {
        Text(message.timeStamp.relativeDateString)
            .font(.caption)
            .bold()
            .padding(.vertical, 3)
            .padding(.horizontal)
            .background(.whatsAppGray)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
    }
    
    private func senderNameTextView() -> some View {
        Text(message.sender?.username ?? "Unknown")
            .font(.footnote)
            .foregroundStyle(.gray)
            .lineLimit(1)
            .padding(.bottom, 2)
            .padding(.leading, 20)
    }
}

#Preview {
    BubbleView(message: .sentPlaceholder, channel: .placeholder, isNewDay: false, showSenderName: false)
}
