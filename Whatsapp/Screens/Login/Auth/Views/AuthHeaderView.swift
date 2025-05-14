//
//  AuthHeaderView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 15/02/25.
//

import SwiftUI

struct AuthHeaderView: View {
    var body: some View {
        HStack {
            Image(.whatsapp)
                .resizable()
                .frame(width: 40, height: 40)
            
            Text("WhatsApp")
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    AuthHeaderView()
}
