//
//  MessageAudioView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 15/02/25.
//

import SwiftUI
import AVKit

struct MessageAudioView: View {
    @EnvironmentObject private var voiceMessagePlayer: VoiceMessagePlayer
    private let item: MessageItems
    @State private var slider: Double = 0
    @State private var sliderRange: ClosedRange<Double>
    @State private var playbackState: VoiceMessagePlayer.PlaybackState = .stopped
    @State private var playbackTime = "00:00"
    @State private var isDragingSlider = false
    
    private var isCorrectVoiceMessage: Bool {
        return voiceMessagePlayer.currentURL?.absoluteString == item.audioURL
    }
    
    init(item: MessageItems) {
        self.item = item
        let audioDuration = item.audioDuration ?? 20
        self._sliderRange = State(wrappedValue: 0...audioDuration)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if item.showGroupPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl, size: .mini)
            }
            HStack {
                playButton()
                Slider(value: $slider, in: sliderRange) { editing in
                    isDragingSlider = editing
                    if !editing && isCorrectVoiceMessage {
                        voiceMessagePlayer.seek(to: slider)
                    }
                }
                .tint(.gray)
                if playbackState == .stopped {
                    Text(item.audioDurationInString)
                        .font(.callout)
                } else {
                    Text(playbackTime)
                        .font(.callout)
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(8)
            .overlay(textTimeStamp(),alignment: .bottomTrailing)
            .background(item.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .applyTail(item.direction)
            .frame(maxWidth: .infinity, alignment: item.alignment)
            .padding(.leading, item.direction == .received ? 10 : 100)
            .padding(.trailing, item.direction == .received ? 100 : 10)
            .overlay(alignment: item.reactionAnchor) {
                ReactionView(message: item)
                    .offset(x: item.showGroupPartnerInfo ? 25 : 10, y: 16)
            }
            .onReceive(voiceMessagePlayer.$playbackState) { state in
                observePlaybackState(state)
            }
            .onReceive(voiceMessagePlayer.$currentTime) { currentTime in
                guard voiceMessagePlayer.currentURL?.absoluteString == item.audioURL else { return }
                listen(to: currentTime)
            }
        }
    }
    private func playButton() -> some View {
        Button {
            handelPlayVoiceMessage()
        } label: {
            Image(systemName: playbackState.icon)
                .padding(12)
                .background(item.direction == .received ? .bubbleGreen : .whatsAppGray)
                .clipShape(Circle())
        }

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
        .padding(.trailing, 10)
    }
}

extension MessageAudioView {
    private func handelPlayVoiceMessage() {
        if playbackState == .stopped || playbackState == .paused {
            guard let audioURLString = item.audioURL, let audioMessageURL = URL(string: audioURLString) else { return }
            voiceMessagePlayer.playAudio(from: audioMessageURL)
        } else {
            voiceMessagePlayer.pauseAudio()
        }
    }
    
    private func observePlaybackState(_ state: VoiceMessagePlayer.PlaybackState) {
        switch state {
        case .stopped:
            playbackState = .stopped
            slider = 0
        case .playing, .paused:
            if isCorrectVoiceMessage {
                playbackState = state
            }
        }
    }
    
    private func listen(to currentTime: CMTime) {
        guard !isDragingSlider else { return }
        playbackTime = currentTime.seconds.formatElapsedTime
        slider = currentTime.seconds
    }
}

#Preview {
    MessageAudioView(item: .sentPlaceholder)
        .onAppear {
            let thumbImage = UIImage(systemName: "circle.fill")
            UISlider.appearance().setThumbImage(thumbImage, for: .normal)
        }
        .environmentObject(VoiceMessagePlayer())
}
