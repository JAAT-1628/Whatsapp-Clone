//
//  UpdatesTabView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 12/02/25.
//

import SwiftUI

struct UpdatesTabView: View {
    @State private var searchText = ""
    let currentUser: UserItem
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    StatusSectionHeader()
                } header: {
                    Text("Status")
                        .textCase(nil)
                        .font(.headline)
                }
                
                Section {
                    StatusSection(currentUser: currentUser)
                }
                
                Section {
                    RecentUpdates()
                } header: {
                    Text("Recent Updates")
                }
                
                Section {
                    ChannelListView()
                } header: {
                    HStack {
                        Text("Channels")
                            .textCase(nil)
                            .font(.headline)
                            .foregroundStyle(.black)
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(Color(.systemGray2))
                        }

                    }
                }
               
            }
            .listStyle(.grouped)
            .navigationTitle("Updates")
            .searchable(text: $searchText)
        }
    }
}

private struct StatusSectionHeader: View {
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "circle.dashed")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.green)
            
            (
                Text("Use Status to share photos, text and videos that disappear in 24 hours")
                +
                Text(" ")
                +
                Text("Status Privacy")
                    .bold()
                    .foregroundStyle(.blue)
            )
            .font(.subheadline)
            
            Image(systemName: "xmark")
                .bold()
            
            Spacer()
        }
    }
}

private struct StatusSection: View {
    let currentUser: UserItem
    
    var body: some View {
        HStack {
            CircularProfileImageView(currentUser.profileImageUrl, size: .small)
            VStack(alignment: .leading) {
                Text("My Status")
                    .font(.subheadline)
                
                Text("Add to my status")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
            Spacer()
            
            cameraButton()
            pencilButton()
        }
    }
    
    private func cameraButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "camera.fill")
                .padding(10)
                .background(Color(.systemGray5))
                .clipShape(Circle())
                .bold()
        }
    }
    
    private func pencilButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "pencil")
                .padding(10)
                .background(Color(.systemGray5))
                .clipShape(Circle())
                .bold()
        }
    }
}

private struct RecentUpdates: View {
    var body: some View {
        HStack {
            CircularProfileImageView(size: .small)
            VStack(alignment: .leading) {
                Text("JAAT")
                    .font(.subheadline)
                
                Text("2hr ago")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
        }
    }
}

private struct ChannelListView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Stay updated on topics that matter to you. Find channels to follow below")
                .font(.subheadline)
                .foregroundStyle(.gray)
            
            ScrollView(.horizontal,showsIndicators: false) {
                HStack {
                    ForEach(PublicChanelItemModel.placeholders) { item in
                            VStack {
                                CircularProfileImageView(item.imageUrl, size: .small)
                                Text(item.title)
                                    .font(.subheadline)
                                Button {
                                    
                                } label: {
                                    Text("Follow")
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 30)
                                        .background(Color.blue.opacity(0.3))
                                        .cornerRadius(20)
                                }
                            }
                            .padding()
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray))
                            }
                    }
                }
            }
            Button("Explore More") { }
                .tint(.green)
                .bold()
                .buttonStyle(.borderedProminent)
                .padding(.top)
        }
    }
}

#Preview {
    UpdatesTabView(currentUser: .placeholder)
}
