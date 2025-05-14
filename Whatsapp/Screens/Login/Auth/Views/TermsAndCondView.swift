//
//  TermsAndCondView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 15/02/25.
//

import SwiftUI

struct TermsAndCondView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(.starting)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                
                Text("Welcome to WhatsApp")
                    .font(.title)
                (
                    Text("Read our ")
                    +
                    Text("Privacy Policy ")
                        .foregroundStyle(.blue)
                    +
                    Text("Tap 'Agree and Continue' in accept the ")
                    +
                    Text("Terms and Conditions")
                        .foregroundStyle(.blue)
                )
                .font(.system(size: 16))
                .foregroundStyle(.gray)
                Spacer()
                
                NavigationLink {
                    LoginScreen()
                } label: {
                    Text("Agree and Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .clipShape(Capsule())
                }
            }
            .padding()
        }
    }
}

#Preview {
    TermsAndCondView()
}
