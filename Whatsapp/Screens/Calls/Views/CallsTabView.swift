//
//  CallsTabView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 13/02/25.
//

import SwiftUI

struct CallsTabView: View {
    @State private var searchText = ""
    @State private var callhistory = CallHistory.all
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    CreateCallLinkSection()
                }
                
                Section {
                    ForEach(0..<20) { _ in
                        RecentSection()
                    }
                } header: {
                    Text("Recent")
                        .textCase(nil)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Calls")
            .searchable(text: $searchText)
            .toolbar {
                leadingNavItem()
                trailingNavItem()
                principalNavItem()
            }
        }
    }
}

extension CallsTabView {
    @ToolbarContentBuilder
    private func leadingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Edit") { }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Image(systemName: "phone.arrow.up.right")
            }

        }
    }
    
    @ToolbarContentBuilder
    private func principalNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Picker("", selection: $callhistory) {
                ForEach(CallHistory.allCases) { items in
                    Text(items.rawValue.capitalized)
                        .tag(items)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 150)
            .background(Color(.systemGray5))
        }
    }
    
    private enum CallHistory: String, CaseIterable, Identifiable {
        case all, missed
        
         var id: String {
            rawValue
        }
    }
    
    private struct CreateCallLinkSection: View {
        var body: some View {
            HStack {
                Image(systemName: "link")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(Color.green)
                
                VStack(alignment: .leading) {
                    Text("Create Call Links")
                        .font(.subheadline)
                        .foregroundStyle(Color.green)
                    Text("Share a link for your WhatsApp call")
                        .font(.footnote)
                        .foregroundStyle(Color.gray)
                }
            }
        }
    }
    
    private struct RecentSection: View {
        var body: some View {
            HStack {
                CircularProfileImageView(size: .small)                
                VStack(alignment: .leading) {
                    Text("Choudhary")
                        .font(.subheadline)
                    HStack {
                        Image(systemName: "phone.arrow.up.right")
                        Text("Outgoing")
                    }
                    .font(.footnote)
                    .foregroundStyle(Color.gray)
                }
                Spacer()
                Text("Yesterday")
                    .foregroundStyle(Color.gray)
                    .font(.footnote)
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 18, height: 18)
            }
        }
    }
}

#Preview {
    CallsTabView()
}
