//
//  MediaPlayerView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 20/02/25.
//

import SwiftUI
import AVKit

struct MediaPlayerView: View {
    let player: AVPlayer
    let dismiss: () -> ()
    
    var body: some View {
        VideoPlayer(player: player)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                cancelButton()
                    .padding()
            }
            .onAppear { player.play() }
    }
    private func cancelButton() -> some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .imageScale(.large)
                .padding(8)
                .background(.thinMaterial)
                .clipShape(Circle())
        }

    }
}

#Preview {
//    MediaPlayerView()
}
