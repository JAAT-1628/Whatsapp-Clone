//
//  SettingsItemsView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 13/02/25.
//

import SwiftUI

struct SettingsItemsView: View {
    let item: SettingsItem
        
    var body: some View {
        HStack {
            iconImageView()
                .frame(width: 28, height: 26)
                .foregroundStyle(.white)
                .background(item.backgroundColor)
                .cornerRadius(6)
            
            Text(item.title)
                .font(.subheadline)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func iconImageView() -> some View {
        switch item.imageType {
        case .systemImage:
            Image(systemName: item.imageName)
        case .assetImage:
            Image(item.imageName)
                .renderingMode(.template)
                .padding(2)
        }
    }
}

#Preview {
    SettingsItemsView(item: .chats)
}
