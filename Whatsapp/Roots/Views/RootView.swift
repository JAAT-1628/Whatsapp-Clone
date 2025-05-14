//
//  RootView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 16/02/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = RootScreenModel()
    @State private var isSplashScreen = true
    var body: some View {
        switch viewModel.authState {
        case .pending:
            splashScreen()
            
        case .loggedIn(let loggedInUser):
            MainTabView(loggedInUser)
            
        case .loggedOut:
            LoginScreen()
        }
    }
    
    private func splashScreen() -> some View {
        VStack {
            Spacer()
            Image(.icon)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 170)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeOut) {
                            isSplashScreen = false
                        }
                    }
                }
            Spacer()
            
            Text("From")
                .font(.footnote)
                .foregroundStyle(.gray)
            Text("JAAT")
                .font(.subheadline)
                .bold()
        }
    }
}

#Preview {
    RootView()
}
