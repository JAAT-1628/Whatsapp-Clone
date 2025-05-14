//
//  MessageListView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 13/02/25.
//

import SwiftUI

struct MessageListView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MessageListController
    private var vm: ChatRoomViewModel
    
    init(_ vm: ChatRoomViewModel) {
        self.vm = vm
    }
    
    func makeUIViewController(context: Context) -> MessageListController {
        let messageListController = MessageListController(vm)
        return messageListController
    }
    
    func updateUIViewController(_ uiViewController: MessageListController, context: Context) { }
}

#Preview {
    MessageListView(ChatRoomViewModel(.placeholder))
}
