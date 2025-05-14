//
//  MainTabView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 12/02/25.
//

import SwiftUI

struct MainTabView: View {
    private let currentUser: UserItem
    
    init (_ currentUser: UserItem) {
        self.currentUser = currentUser
        makeTabBarOpaque()
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
    var body: some View {
        TabView {
            UpdatesTabView(currentUser: currentUser)
                .tabItem {
                    Image(systemName: Tabs.updates.icon)
                    Text(Tabs.updates.title)
                }
            CallsTabView()
                .tabItem {
                    Image(systemName: Tabs.calls.icon)
                    Text(Tabs.calls.title)
                }
            CommunitiesTabView()
                .tabItem {
                    Image(systemName: Tabs.communities.icon)
                    Text(Tabs.communities.title)
                }
            ChatsTabView(currentUser)
                .tabItem {
                    Image(systemName: Tabs.chat.icon)
                    Text(Tabs.chat.title)
                }
            SettingsTabView(currentUser)
                .tabItem {
                    Image(systemName: Tabs.settings.icon)
                    Text(Tabs.settings.title)
                }
        }
    }
    
    private func makeTabBarOpaque() {
        let apperance = UITabBarAppearance()
        apperance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = apperance
        UITabBar.appearance().scrollEdgeAppearance = apperance
    }
}

extension MainTabView {
     
    private enum Tabs: String {
        case updates, calls, communities, chat, settings
        
        fileprivate var title: String {
            rawValue.capitalized
        }
        
        fileprivate var icon: String {
            switch self {
            case .updates:
                "circle.dashed.inset.fill"
            case .calls:
                "phone"
            case .communities:
                "person.3"
            case .chat:
                "message.fill"
            case .settings:
                "gear"
            }
        }
    }
}

#Preview {
    MainTabView(.placeholder)
}
