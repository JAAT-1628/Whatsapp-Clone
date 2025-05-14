//
//  ChatReactionView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 25/02/25.
//

import SwiftUI

struct EmojiReaction {
    let reaction: Reaction
    var isAnimating: Bool = false
    var opacity: CGFloat = 1
}

struct ChatReactionView: View {
    @State private var animateBackgroundView = false
    @State private var emojiState: [EmojiReaction] = [
        EmojiReaction(reaction: .like),
        EmojiReaction(reaction: .heart),
        EmojiReaction(reaction: .laugh),
        EmojiReaction(reaction: .shocked),
        EmojiReaction(reaction: .sad),
        EmojiReaction(reaction: .pray),
        EmojiReaction(reaction: .more)
    ]
    let message: MessageItems
    let onTapHandler: (_ selectedEmoji: Reaction) -> ()
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(emojiState.enumerated()), id: \.offset) { index, item in
                reactionButton(item, at: index)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(backgroundView())
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.2)) {
                animateBackgroundView = true
            }
        }
    }
    private func backgroundView() -> some View {
        Capsule()
            .fill(Color.contextMenuTint)
            .mask {
            Capsule()
                    .scaleEffect(animateBackgroundView ? 1 : 0, anchor: message.menueAnchor)
                    .opacity(animateBackgroundView ? 1 : 0)
        }
    }
    
    private var springAnimation: Animation {
        Animation.spring(
            response: 0.60,
            dampingFraction: 0.7,
            blendDuration: 0.06
        ).speed(4)
    }
    
    private func getAnimatingIndex(_ index: Int) -> Int {
        if message.direction == .sent {
            let reverseIndex = emojiState.count - 1 - index
            return reverseIndex
        } else {
            return index
        }
    }
    
    private func reactionButton(_ item: EmojiReaction, at index: Int) -> some View {
        Button {
            guard item.reaction != .more else { return }
            onTapHandler(item.reaction)
            Haptic.impact(.heavy)
        } label: {
            buttonBody(item, at: index)
                .scaleEffect(emojiState[index].isAnimating ? 1 : 0.01)
                .opacity(item.opacity)
                .onAppear {
                    let dyanmicIndex = getAnimatingIndex(index)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(springAnimation.delay(Double(dyanmicIndex) * 0.06)) {
                            emojiState[index].isAnimating = true
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    private func buttonBody(_ item: EmojiReaction, at index: Int) -> some View {
        if item.reaction == .more {
            Image(systemName: "plus")
                .imageScale(.large)
                .bold()
                .padding(4)
                .background(Color(.systemGray5))
                .clipShape(Circle())
        } else {
            Text(item.reaction.emoji)
                .font(.system(size: 30))
        }
    }
}

struct MessageMenuView: View {
    let message: MessageItems
    @State private var animateBackgroundView = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(MessageMenueAction.allCases) { action in
                buttonBody(action)
                    .foregroundStyle(action == .delete ? .red : .whatsAppBlack)
                    .frame(height: 45)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if action != .delete {
                    Divider()
                }
            }
        }
        .frame(width: message.imageWidth)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .scaleEffect(animateBackgroundView ? 1 : 0, anchor: message.menueAnchor)
        .opacity(animateBackgroundView ? 1 : 0)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.2)) {
                animateBackgroundView = true
            }
        }
    }
    private func buttonBody(_ action: MessageMenueAction) -> some View {
        Button {
            
        } label: {
            HStack {
                Text(action.rawValue.capitalized)
                Spacer()
                Image(systemName: action.systemImage)
            }
            .padding()
        }

    }
}

struct ReactionView: View {
    let message: MessageItems
    private var emojis: [String] {
        return message.reactions.map { $0.key }
    }
    private var emojisCount: Int {
        let stats = message.reactions.map { $0.value }
        return stats.reduce(0, +)
    }
    
    var body: some View {
        if message.hasReactions {
            HStack(spacing: 2) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                }
                if emojisCount > 1 {
                    Text(emojisCount.description)
                }
            }
            .font(.footnote)
            .padding(4)
            .padding(.horizontal, 2)
            .background(Capsule().fill(.ultraThinMaterial))
            .overlay {
                Capsule()
                    .stroke(message.backgroundColor, lineWidth: 1)
            }
            .shadow(color: message.backgroundColor, radius: 5, x: 0, y: 4)
        }
    }
}

#Preview {
    ChatReactionView(message: .sentPlaceholder) { _ in
        
    }
//    MessageMenuView(message: .recivedPlaceholder)
}
