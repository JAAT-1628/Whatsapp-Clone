//
//  TailModifier.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 13/02/25.
//

import SwiftUI

private struct TailModifier: ViewModifier {
    var direction: MessageDirection
    
    func body(content: Content) -> some View {
        content.overlay(alignment: direction == .received ? .bottomLeading : .bottomTrailing) {
            TextTailView(direction: direction)
        }
    }
}

extension View {
    func applyTail(_ direction: MessageDirection) -> some View {
        self.modifier(TailModifier(direction: direction))
    }
}
