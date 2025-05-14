//
//  MediaAttachmentPreview.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 20/02/25.
//

import SwiftUI

struct MediaAttachmentPreview: View {
    let mediaAttachment: [MediaAttachment]
    let actionHandler: (_ action: UserAction) -> ()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(mediaAttachment) { attachment in
                    if attachment.type == .audio(.stubURL, 0) {
                        audioAttachmentPreview(attachment)
                    } else {
                        imageView(attachment)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func imageView(_ attachment: MediaAttachment) -> some View {
        Button {
            
        } label: {
            Image(uiImage: attachment.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .cornerRadius(6)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    cancelButton(attachment)
                }
                .overlay {
                    playButton("play.fill", attachment: attachment)
                        .opacity(attachment.type == .video(UIImage(), .stubURL) ? 1 : 0)
                }
        }
    }
    
    private func cancelButton(_ attachment: MediaAttachment) -> some View {
        Button {
            actionHandler(.remove(attachment))
        } label: {
            Image(systemName: "xmark")
                .imageScale(.small)
                .padding(4)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .padding(2)
        }
    }
    
    private func playButton(_ image: String, attachment: MediaAttachment) -> some View {
        Button {
            actionHandler(.play(attachment))
        } label: {
            Image(systemName: image)
                .imageScale(.large)
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .padding(2)
        }
    }
    
    private func audioAttachmentPreview(_ attachment: MediaAttachment) -> some View {
        ZStack {
            LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0.7), .teal], startPoint: .topLeading, endPoint: .bottom)
            playButton("mic.fill", attachment: attachment)
        }
        .frame(width: 160, height: 80)
        .cornerRadius(6)
        .overlay(alignment: .topTrailing) {
            cancelButton(attachment)
        }
        .overlay(alignment: .bottomLeading) {
            Text(attachment.fileURL?.absoluteString ?? "Unknown")
                .lineLimit(1)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.3))
        }
    }
}

extension MediaAttachmentPreview {
    enum UserAction {
        case play(_ item: MediaAttachment)
        case remove(_ item: MediaAttachment)
    }
}

#Preview {
    MediaAttachmentPreview(mediaAttachment: []) { _ in
        
    }
}
