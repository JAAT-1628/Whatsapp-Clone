//
//  CommunitiesTabView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 13/02/25.
//

import SwiftUI

struct CommunitiesTabView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    Image(.communities)
                    
                    Group {
                        Text("Stay connected with a community")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Communities bring members together in topics based groups. Any community you're added to will appear here.")
                            .font(.callout)
                            .foregroundStyle(Color.gray)
                    }
                    .padding(.horizontal)
                    
                    Text("See Example Communities >")
                        .font(.headline)
                        .foregroundStyle(.green)
                    
                    Button {
                        
                    } label: {
                        Label("New community", systemImage: "plus")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.green)
                            .cornerRadius(10)
                            .padding(.horizontal, 25)
                            .padding(.vertical)
                    }

                }
            }
            .navigationTitle("Communities")
        }
    }
}

#Preview {
    CommunitiesTabView()
}
