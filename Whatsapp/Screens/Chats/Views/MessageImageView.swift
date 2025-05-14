//
//  MessageImageView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 14/02/25.
//

import SwiftUI
import Kingfisher

struct MessageImageView: View {
    let item: MessageItems
    
    var body: some View {
        HStack(alignment: .bottom) {
            if item.direction == .sent { Spacer() }
            
            if item.showGroupPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl, size: .mini)
            }
            
            HStack {
                if item.direction == .sent { shareButton() }
                imageTextView()
                    .overlay(alignment: item.reactionAnchor) {
                        ReactionView(message: item)
                            .offset(x: item.showGroupPartnerInfo ? 25 : 10, y: 18)
                    }
                if item.direction == .received { shareButton() }
            }
            if item.direction == .received { Spacer() }
        }
    }
    
    private func imageTextView() -> some View {
        VStack(alignment: .leading, spacing: 2) {
            KFImage(URL(string: item.thumbnailURL ?? ""))
                .resizable()
                .placeholder { ProgressView() }
                .scaledToFill()
                .frame(width: item.imageSize.width, height: item.imageSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(alignment: .bottomTrailing) {
                    textTimeStamp()
                        .padding(.horizontal)
                }
                .overlay {
                    Image(systemName: "play.fill")
                        .padding()
                        .imageScale(.large)
                        .background(Color.gray.opacity(0.8))
                        .clipShape(Circle())
                        .opacity(item.type == .video ? 1 : 0)
                }
            if !item.text.isEmptyOrWhiteSpace {
                Text(item.text)
                    .padding([.horizontal, .bottom], 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(width: item.imageSize.width)
            }
        }
        .padding(7)
        .background(item.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .applyTail(item.direction)
    }
    
    private func textTimeStamp() -> some View {
        HStack(spacing: 2) {
            Text(item.timeStamp.formatToTime)
                .font(.footnote)
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
    
    private func shareButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "arrowshape.turn.up.right.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
        }
    }
}

#Preview {
    MessageImageView(item: .sentPlaceholder)
}
