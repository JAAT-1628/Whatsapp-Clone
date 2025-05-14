//
//  MessageTextView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 13/02/25.
//

import SwiftUI

struct MessageTextView: View {
    var item: MessageItems
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            
            if item.showGroupPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl, size: .mini)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(item.text)
                    .font(.system(size: 15))
                textTimeStamp()
            }
            .padding(6)
            .background(item.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .applyTail(item.direction)
            .frame(maxWidth: .infinity, alignment: item.alignment)
            .padding(.leading, item.direction == .received ? 4 : 100)
            .padding(.trailing, item.direction == .received ? 100 : 4)
            .overlay(alignment: item.reactionAnchor) {
                ReactionView(message: item)
                    .offset(x: item.showGroupPartnerInfo ? 25 : 15, y: 18)
            }
        }
    }
    private func textTimeStamp() -> some View {
        HStack(spacing: 2) {
            Text(item.timeStamp.formatToTime)
                .font(.caption2)
                .foregroundStyle(.gray)
            if item.direction == .sent {
                Image(.seen)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 14, height: 18)
                    .foregroundStyle(Color(.systemBlue))
            }
        }
    }
}
struct TextTailView: View {
    var direction: MessageDirection
    
    var body: some View {
        Image(direction == .sent ? .outgoingTail : .incomingTail)
            .renderingMode(.template)
            .resizable()
            .frame(width: 16, height: 12)
            .offset(y: 4)
            .foregroundStyle(direction == .received ? .bubbleWhite : .bubbleGreen)
    }
}

#Preview {
    MessageTextView(item: .recivedPlaceholder)
}
